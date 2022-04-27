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