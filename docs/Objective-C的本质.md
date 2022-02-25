# Objective-C的本质
### Objective-C 代码的底层实现
```c++
都是 C/C++代码
```
### Objective-C 如何转成计算机所认识的语言
```
Objective-C ——> C/C++ ——> 汇编语言 ——> 机器语言
```
* **.h** ：头文件。头文件包含类，类型，函数和常数的声明。 
* **.m** ：源代码文件。这是典型的源代码文件扩展名，可以包含Objective-C和C代码。 
* **.mm** ：源代码文件。带有这种扩展名的源代码文件，除了可以包含Objective-C和C代码以外还可以包含C++代码。仅在你的Objective-C代码中确实需要使用C++类或者特性的时候才用这种扩展名

* **.cpp**：只能编译C++ 

### Objective-C 的对象、类主要是基于 C\C++ 的什么数据结构实现的
```
结构体
```### 通过以下命令可将 Objective-C 代码转换为 C\C++ 代码```c++
// xcrun: Xcode run
// iphoneos: 指定平台为 iPhone OS
// arm64: 处理器架构，模拟器32位处理器测试需要i386架构，模拟器64位处理器测试需要x86_64架构，真机32位处理器需要armv7,或者armv7s架构，真机64位处理器需要arm64架构，现在一般都是64位的机器
// 输入出的CPP文件：C++（C plus plus）文件，因为 C++ 包含 C，所以最好输出 C++ 代码

xcrun  -sdk  iphoneos  clang  -arch  arm64  -rewrite-objc  OC源文件  -o  输出的CPP文件
```

### NSObject 在 C++ 中的结构:
```c++
struct NSObject_IMPL {
	Class isa;
};
其中
Class：typedef struct objc_class *Class，可发现 isa 是指向 结构体 的指针
```
声明一个OCStudent类:
```objc
@interface OCStudent : NSObject
{
    @public
    NSString *_name;
    int _age;
}
@end
```
对应 C++ 中的结构：
```c++
struct OCStudent_IMPL {
	struct NSObject_IMPL NSObject_IVARS;
	NSString *_name;
	int _age;
};
```


### 获取 NSObject 对象占用了多少内存
``` c++
NSObject *obj = [[NSObject alloc] init];

创建一个实例对象，至少需要的内存大小：
#import <objc/runtime.h>class_getInstanceSize([NSObject class]); >> 8

创建一个实例对象，实际分配的内存大小：
#import <malloc/malloc.h>malloc_size((__bridge const void *)obj); >> 16

这里为什么实际分配的大小是 16 呢？
>> 因为在源码中的实现逻辑是这样的
>> if size < 16 { size = 16 };
```

### Objective-C 中的对象，主要分三类
* instance对象（实例对象）
* class对象（类对象）
* meta-class对象（元类对象）

![isa-w600](https://github.com/HHeFFFeng/Interview-iOS/blob/main/docs/media/16383263208604/16384230173802.jpg)

### isa 和 superclass

![isa_and_superclass-w600](https://github.com/HHeFFFeng/Interview-iOS/blob/main/docs/media/16383263208604/16384236128080.jpg)

### class方法，object_getClass 和 objc_getClass 三者的区别
####  `class`方法

`class`方法无论是类对象还是实例对象都可以调用，可以嵌套，返回永远是自身的类对象。如：
```swift
Person *p = [[Person alloc]init];
Class *pClass == [p class] == [ [p class]class] == [[ [p class]class]class] == [Person class]
```

####  `object_getClass`方法

`object_getClass`和`class`同样可以嵌套，但是`object_getClass`得到的是他的 isa 指向的地址。如：
```swift
Person *p = [[Person alloc] init];     
p -> [Person class] -> PersonMetaClass -> RootMetaClass -> RootMetaClass
// 意思是： p 的 isa 指向 [Person class] , [Person class] 的 isa 指向 PersonMetaClass, PersonMetaClass应该指向基类的metaClass，基类metaClass指向他自己
```

####  `objc_getClass`方法

`objc_getClass`无法嵌套，因为参数 是`char`类型，效果和`class`相同(因为不能嵌套，所以和`class`可以认为是相同的)
