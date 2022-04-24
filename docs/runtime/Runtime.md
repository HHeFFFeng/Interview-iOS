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

### 类对象 的数据结构
![objc_class-w800](media/WX20220302-170556%402x.png)



##### objc_class 结构

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
`SEL`: </br>
方法/函数名，一般叫选择器，底层结构类似`char *`，可以通过`@selector()`和`sel_registerName()`获得，不同类中的相同名字的方法，所对应的方法选择器是相同的</br>

`types`: </br>
比如声明一个`-(void)test;`方法，对应的types大概是`v16@0:8`,其中16表示所有参数占用的空间大小，后面的0，8表示参数起始位置。`@`和`:`是两个默认的参数`(id)self`和`(SEL)_cmd`，可通过`@encode(type-name)`验证

`IMP`: </br>
函数的地址，代表函数的具体实现</br>
`typedef id _Nullable (*IMP)(id _Nonnull, SEL _Nonnull, ...);`

##### Type Encoding
![type_encoding-w600](media/16413706237683.jpg)


### 方法缓存 cache
#### 数据结构
在`objc_class`内部有个结构体`cache_t`，里面就缓存着曾用过的方法</br>
```c++
// 看到这种结构就该联想到 散列表
struct cache_t {
    struct bucket_t *_buckets; // 散列表, [...bucket_t、bucket_t、bucket_t...]
    mask_t _mask; // _mask = _buckets.length - 1
    mask_t _occupied; // 已缓存的方法数量
}

struct bucket_t {
    SEL _key;
    IMP _imp;
}
```
#### 存储的形式
`散列表(哈希表)` 的方式存储，以空间换时间
#### 表格大概如下
| 索引i  | bucket_t                                   |
|-----|----------------------------------------|
| 0   | NULL                                   |
| 1   | NULL                                   |
| 2   | bucket_t(_key = @selector(test), _imp) |
| 3   | NULL                                   |
| 4   | NULL                                   |
| ... | ...                                    |

#### 原理
例如: `[objc test]`

##### 散列表 取值过程：
1. 调动方法`@selector(test)`
2. 用传入的`SEL`和`_mask`按位与`&`得到索引`i`
3. 根据索引`i`找到`bucket_t`，判断其中的`SEL`与传入的`SEL`是否相同
    1. 是，返回该`SEL`对应的`_iml`
    2. 否，检查索引`i-1`，继续比较`SEL`，以此类推，如果索引<0，则使索引=_mask-1，直到找到`_imp`


##### 散列表 存值过程：
1. 调用方法`@selector(test)`
2. 初始时，为对象的`cache_t`分配一定的空间，`cache_t`下的`_mask`值为`散列表`的长度 - 1
3. 用传入的`SEL`和`_mask`按位与`&`得到索引`i`(这样得到的`i`也一定小于 <= `_mask`)
4. 检查索引`i`对应的空间是否为`NULL`
    1. 是，将这个`bucket_t(@selector(test), _imp`缓存在索引`i`对应的空间
    2. 否，检查索引`i-1`对应的空间是否为`NULL`，以此类推，如果索引<0，则使索引=_mask-1，并检查对应的空间是否为`NULL`，直到找到索引空间为`NULL`的再缓存

### API
#### 类
动态创建一个类（参数：父类，类名，额外的内存空间）```c
Class objc_allocateClassPair(Class superclass, const char *name, size_t extraBytes)
```注册一个类（要在类注册之前添加成员变量）```c
void objc_registerClassPair(Class cls) 
```销毁一个类```c
void objc_disposeClassPair(Class cls)
```获取isa指向的Class```c
Class object_getClass(id obj)
```设置isa指向的Class```c
Class object_setClass(id obj, Class cls)
```判断一个OC对象是否为Class```c
BOOL object_isClass(id obj)
```判断一个Class是否为元类```c
BOOL class_isMetaClass(Class cls)
```获取父类```c
Class class_getSuperclass(Class cls)
```

#### 成员变量
获取一个实例变量信息```c
Ivar class_getInstanceVariable(Class cls, const char *name)
```拷贝实例变量列表（最后需要调用free释放）```c
Ivar *class_copyIvarList(Class cls, unsigned int *outCount)
```设置和获取成员变量的值```c
void object_setIvar(id obj, Ivar ivar, id value)id object_getIvar(id obj, Ivar ivar)
```动态添加成员变量（已经注册的类是不能动态添加成员变量的）```c
BOOL class_addIvar(Class cls, const char * name, size_t size, uint8_t alignment, const char * types)
```获取成员变量的相关信息```c
const char *ivar_getName(Ivar v)const char *ivar_getTypeEncoding(Ivar v)
```#### 属性
获取一个属性```c
objc_property_t class_getProperty(Class cls, const char *name)
```拷贝属性列表（最后需要调用free释放）```c
objc_property_t *class_copyPropertyList(Class cls, unsigned int *outCount)
```
动态添加属性```c
BOOL class_addProperty(Class cls, const char *name, const objc_property_attribute_t *attributes,                  unsigned int attributeCount)
```动态替换属性```c
void class_replaceProperty(Class cls, const char *name, const objc_property_attribute_t *attributes,                      unsigned int attributeCount)
```获取属性的一些信息```c
const char *property_getName(objc_property_t property)const char *property_getAttributes(objc_property_t property)
```#### 方法
获得一个实例方法、类方法```c
Method class_getInstanceMethod(Class cls, SEL name)Method class_getClassMethod(Class cls, SEL name)
```方法实现相关操作```c
IMP class_getMethodImplementation(Class cls, SEL name) IMP method_setImplementation(Method m, IMP imp)void method_exchangeImplementations(Method m1, Method m2) 
```拷贝方法列表（最后需要调用free释放）```c
Method *class_copyMethodList(Class cls, unsigned int *outCount)
```动态添加方法```c
BOOL class_addMethod(Class cls, SEL name, IMP imp, const char *types)
```动态替换方法```c
IMP class_replaceMethod(Class cls, SEL name, IMP imp, const char *types)
```
获取方法的相关信息（带有copy的需要调用free去释放）```c
SEL method_getName(Method m)IMP method_getImplementation(Method m)const char *method_getTypeEncoding(Method m)unsigned int method_getNumberOfArguments(Method m)char *method_copyReturnType(Method m)char *method_copyArgumentType(Method m, unsigned int index)
```选择器相关```c
const char *sel_getName(SEL sel)SEL sel_registerName(const char *str)
```用block作为方法实现```c
IMP imp_implementationWithBlock(id block)id imp_getBlock(IMP anImp)BOOL imp_removeBlock(IMP anImp)
```