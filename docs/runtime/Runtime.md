# Runtime

### 介绍
>OC是一门动态性比较强的编程语言，允许很多操作推迟到程序运行时再进行</br>
>OC的动态性就是由Runtime库来支撑和实现的，Runtime是一套C语言的API，封装了很多动态性相关的函数</br>
>平时编写的OC代码，底层都是转换成了Runtime API进行调用</br>

**具体应用:**
* 利用关联对象（AssociatedObject）给分类添加属性
* 遍历类的所有成员变量（修改textfield的占位文字颜色、字典转模型、自动归档解档）
* 交换方法实现（交换系统的方法）
* 利用消息转发机制解决方法找不到的异常问题


### 实例对象 的数据结构
在`arm64`架构之前，`isa`就是一个普通的指针，存着`Class`，`Meta-Class`对象的内存地址</br>
在`arm64`架构之后，对`isa`进行了优化，变成了下面这种`union`共用体结构，还是用`位域`存储着更多的信息，如 是否优化过，是否有关联对象，Class对象指针等等，具体如下所示:
```c++
struct objc_object {
    isa_t isa;
}

union isa_t {
    uintptr_t bits;
    Class cls;
    
    struct {
        uintptr_t nonpointer        : 1;  // 是否优化过，使用位域存储更多的信息                                       
        uintptr_t has_assoc         : 1;  // 是否设置过关联对象                                   
        uintptr_t has_cxx_dtor      : 1;  // 是否有C++的析构函数，如果没有，释放更快                                     
        uintptr_t shiftcls          : 33; // 存储着Class, Meta-Class对象的内存地址
        uintptr_t magic             : 6;  // 对象是否完成初始化                                     
        uintptr_t weakly_referenced : 1;  // 是否被弱引用指向过，如果没有，释放时更快                                     
        uintptr_t unused            : 1;  //                                      
        uintptr_t has_sidetable_rc  : 1;  // 引用计数是否过大无法存储在isa中，如果为1，那么引用计数会存在一个叫 SideTable 的类的属性中                                    
        uintptr_t extra_rc          : 19  // 存的值 = 引用计数 - 1
    };
};
```

### 类对象 的数据结构
![objc_class-w800](https://github.com/HHeFFFeng/Interview-iOS/blob/main/docs/runtime/media/WX20220302-170556%402x.png)



##### objc_class 结构
```c++
struct objc_class : objc_object {
    Class isa;
    Class superclass;
    
    cache_t cache;
    class_data_bits_t bits;
    
    class_rw_t *data() const {
        return (class_rw_t *)(bits & FAST_DATA_MASK);
    }
}
```
##### class_rw_t 结构
存放类中的`属性`、`方法`和`遵循的协议`等信息
```c++
struct class_rw_t {
    uint32_t flags;
    uint32_t version;
    
    const class_ro_t *ro; 
    /*
     这三个都是二维数组，是可读可写的，包含了类的初始内容、分类的内容。
     其中 method_array_t 存放类似这种结构：[method_list_t<method_t>,
                                        method_list_t<method_t>,
                                        method_list_t<method_t>]
     */
    method_array_t methods; // 方法列表（类对象存放对象方法，元类对象存放类方法）
    property_array_t properties; // 属性列表
    protocol_array_t protocols; //协议列表
}
```

##### class_ro_t 结构
存放类的初始信息
```c++
struct class_ro_t {
    uint32_t flags;
    uint32_t instanceStart;
    uint32_t instanceSize;
    uint32_t reserved;

    const uint8_t * ivarLayout;

    const char * name;
    /* 这三个都是一维数组 */
    method_list_t * baseMethodList; // 初始方法，存放method_t类型的数据
    protocol_list_t * baseProtocols; // 初始协议
    const ivar_list_t * ivars; // 成员变量

    const uint8_t * weakIvarLayout;
    property_list_t *baseProperties;
}
```

##### method_t 结构
```c++
struct method_t {
    SEL name; // 函数名
    const char *types; // type encoding 编码(返回类型，参数类型)
    IMP imp; // 函数地址
}
```
`SEL`: 方法/函数名，一般叫选择器，底层结构类似`char *`，可以通过`@selector()`和`sel_registerName()`获得，不同类中的相同名字的方法，所对应的方法选择器是相同的</br>

`types`: 比如声明一个`-(void)test;`方法，对应的types大概是`v16@0:8`,其中16表示所有参数占用的空间大小，后面的0，8表示参数起始位置。`@`和`:`是两个默认的参数`(id)self`和`(SEL)_cmd`</br>

`IMP`: 函数的地址，代表函数的具体实现</br>
```c++
typedef id _Nullable (*IMP)(id _Nonnull, SEL _Nonnull, ...); 
```

##### Type Encoding
![-w600](https://github.com/HHeFFFeng/Interview-iOS/blob/main/docs/runtime/media/16413706237683.jpg)


#### 方法缓存 cache
##### 数据结构
在`objc_class`内部有个结构体`cache_t`，里面就缓存着曾用过的方法</br>
```c++
// 看到这种结构就该联想到 散列表
struct cache_t {
    struct bucket_t *_buckets; // 散列表
    mask_t _mask; // total = _mask + 1
    mask_t _occupied; // 已缓存的方法数量
}

struct bucket_t {
    SEL _key;
    IMP _imp;
}
```
##### 存储的形式
* 以 `散列表(哈希表)` 的方式存储
##### 查找过程
1. 判断receiver是否为nil，也就是objc_msgSend的第一个参数self，也就是要调用的那个方法所属对象
2. 从缓存里寻找，找到了则分发，否则
3. 利用objc-class.mm中_class_lookupMethodAndLoadCache3（为什么有个这么奇怪的方法。本文末尾会解释）方法去寻找selector
    1. 如果支持GC，忽略掉非GC环境的方法（retain等）
    2. 从本class的method list寻找selector，如果找到，填充到缓存中，并返回selector，否则
    3. 寻找父类的method list，并依次往上寻找，直到找到selector，填充到缓存中，并返回selector，否则
    4. 调用_class_resolveMethod，如果可以动态resolve为一个selector，不缓存，方法返回，否则
    5. 转发这个selector，否则
4. 报错，抛出异常

### 听课笔记
* 动态性，相比C语言，OC可以在编译后动态改变它本身的一些特性
* 位域 `:`
* 一个字节(`byte`) = 8位
* 掩码 `MASK`
* `<<` `|` `&` `~` 位运算
* 变量大小按`字节byte`为单位分配
* LLDB (Low Lever Debug)，是默认内置于XCode的动态调试工具
* class 和 meta-class 最后三位永远是 0
* `union isa_t`
* 元类对象 是一种特殊的 类对象
* `class_ro_t` 包含哪些信息
* `class_rw_t` 包含哪些信息
* type encoding
* struct method_t { SEL name, const char *types, IMP imp }
* objc_class 中的 cache
