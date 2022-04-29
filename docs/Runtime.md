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
动态创建一个类（参数：父类，类名，额外的内存空间）
Class objc_allocateClassPair(Class superclass, const char *name, size_t extraBytes)
```
void objc_registerClassPair(Class cls) 
```
void objc_disposeClassPair(Class cls)
```
Class object_getClass(id obj)
```
Class object_setClass(id obj, Class cls)
```
BOOL object_isClass(id obj)
```
BOOL class_isMetaClass(Class cls)
```
Class class_getSuperclass(Class cls)
```

#### 成员变量
获取一个实例变量信息
Ivar class_getInstanceVariable(Class cls, const char *name)
```
Ivar *class_copyIvarList(Class cls, unsigned int *outCount)
```
void object_setIvar(id obj, Ivar ivar, id value)
```
BOOL class_addIvar(Class cls, const char * name, size_t size, uint8_t alignment, const char * types)
```
const char *ivar_getName(Ivar v)
```
获取一个属性
objc_property_t class_getProperty(Class cls, const char *name)
```
objc_property_t *class_copyPropertyList(Class cls, unsigned int *outCount)
```

BOOL class_addProperty(Class cls, const char *name, const objc_property_attribute_t *attributes,
```
void class_replaceProperty(Class cls, const char *name, const objc_property_attribute_t *attributes,
```
const char *property_getName(objc_property_t property)
```
获得一个实例方法、类方法
Method class_getInstanceMethod(Class cls, SEL name)
```
IMP class_getMethodImplementation(Class cls, SEL name) 
```
Method *class_copyMethodList(Class cls, unsigned int *outCount)
```
BOOL class_addMethod(Class cls, SEL name, IMP imp, const char *types)
```
IMP class_replaceMethod(Class cls, SEL name, IMP imp, const char *types)
```

SEL method_getName(Method m)
```
const char *sel_getName(SEL sel)
```
IMP imp_implementationWithBlock(id block)
```