# 对象
### alloc流程
```objc
int main(int argc, const char * argv[]) {
    @autoreleasepool {

        HFPerson *p = [HFPerson alloc];
        HFPerson *p1 = [p init];
        HFPerson *p2 = [p init];
        
        NSLog(@"p: %@, p1: %@, p2: %@", p, p1, p2);
    }
    return 0;
}
打印：
p: <HFPerson: 0x10070db90>, p1: <HFPerson: 0x10070db90>, p2: <HFPerson: 0x10070db90>
```

![](media/16502633941954.jpg)


#### 1. objc_alloc
```c++
// Calls [cls alloc].
id objc_alloc(Class cls) {
=>    return callAlloc(cls, true/*checkNil*/, false/*allocWithZone*/);
}
```
#### 2. callAlloc
```c++
// Call [cls alloc] or [cls allocWithZone:nil], with appropriate
// shortcutting optimizations.

// cooci 2021.01.05
// KC 重磅提示 这里是核心方法
static ALWAYS_INLINE id
callAlloc(Class cls, bool checkNil, bool allocWithZone=false)
{
#if __OBJC2__
    if (slowpath(checkNil && !cls)) return nil;
    if (fastpath(!cls->ISA()->hasCustomAWZ())) {
    =>    return _objc_rootAllocWithZone(cls, nil);
    }
#endif

    // No shortcuts available.
    if (allocWithZone) {
        return ((id(*)(id, SEL, struct _NSZone *))objc_msgSend)(cls, @selector(allocWithZone:), nil);
    }
    return ((id(*)(id, SEL))objc_msgSend)(cls, @selector(alloc));
}
```
`hasCustomAWZ()`：判断当前类是否重写了allocWithZone方法。</br>
`fastpath(x)`和`slowpath(x)`是用于编译器优化的两个宏定义。
```c++
//fastpath(x)表示x很可能为true，大概率会执行
#define fastpath(x) (__builtin_expect(bool(x), 1))
//slowpath(x)表示x很可能为false，大概率不执行。
#define slowpath(x) (__builtin_expect(bool(x), 0))
```
通过这两个指令，编译器在编译过程中，会将可能性更大的代码紧跟着前面的代码，从而减少代码读取时指令跳转带来的性能上的下降。</br>
`callAlloc`方法里主要判断当前类是否有重写`allocWithZone`方法，如果有，就调用`allocWithZone`，若没有，就调用`objc_rootAllocWithZone`。因此，如果存在单例类，就需要重写`allocWithZone`，确保实例化的一定是单例对象。

#### 3. _objc_rootAllocWithZone
```c++
id _objc_rootAllocWithZone(Class cls, malloc_zone_t *zone __unused)
{
    // allocWithZone under __OBJC2__ ignores the zone parameter
    return _class_createInstanceFromZone(cls, 0, nil,
                                         OBJECT_CONSTRUCT_CALL_BADALLOC);
}
```

#### 4. _class_createInstanceFromZone
```c++
static ALWAYS_INLINE id
_class_createInstanceFromZone(Class cls, size_t extraBytes, void *zone,
                              int construct_flags = OBJECT_CONSTRUCT_NONE,
                              bool cxxConstruct = true,
                              size_t *outAllocatedSize = nil)
{
    ASSERT(cls->isRealized());

    // Read class's info bits all at once for performance
    bool hasCxxCtor = cxxConstruct && cls->hasCxxCtor();
    bool hasCxxDtor = cls->hasCxxDtor();
    bool fast = cls->canAllocNonpointer();
    size_t size;
    
    // 1.计算需要申请的内存空间大小
    size = cls->instanceSize(extraBytes);
    if (outAllocatedSize) *outAllocatedSize = size;

    // 2.为对象分配内存空间，并返回内存地址
    id obj;
    if (zone) {
        obj = (id)malloc_zone_calloc((malloc_zone_t *)zone, 1, size);
    } else {
        // zone一般为nil，所以会在这里开辟内存
        obj = (id)calloc(1, size);
    }
    
    // 此刻如果打印 obj，会发现:
    // 0x000000010135f910 仅仅只是一个地址，和传入的 cls 暂时没有任何关系
    if (slowpath(!obj)) {
        if (construct_flags & OBJECT_CONSTRUCT_CALL_BADALLOC) {
            return _objc_callBadAllocHandler(cls);
        }
        return nil;
    }
    
    // 3.将类和开辟的内存空间关联起来, 初始化实例的isa_t isa指针
    if (!zone && fast) {
    =>    obj->initInstanceIsa(cls, hasCxxDtor);
    } else {
        // Use raw pointer isa on the assumption that they might be
        // doing something weird with the zone or RR.
        obj->initIsa(cls);
    }

    if (fastpath(!hasCxxCtor)) {
        return obj;
    }

    construct_flags |= OBJECT_CONSTRUCT_FREE_ONFAILURE;
    return object_cxxConstructFromClass(obj, cls, construct_flags);
}
```
`hasCxxCtor()`：当前class或者superclass是否有.cxx_construct 构造方法的实现。</br>
`hasCxxDtor()`：该对象是否有 C++ 或者 Objc 的析构器，如果有析构函数，则需要做析构逻辑，如果没有，  则可以更快的释放对象。</br>
`canAllocNonpointer()`：表示是否对 isa 指针开启指针优化。0：纯isa指针；1：不⽌是类对象地址，isa 中还包含了类信息、对象的引⽤计数等。</br>
`zone`：在iOS8之后，iOS就不再通过zone来申请内存空间了，所以zone传参为nil。</br>
##### 计算所需内存大小的具体实现：
`cls->instanceSize(extraBytes)`是进行内存对齐得到的实例大小，里面的流程分别如下：
```c++
size_t instanceSize(size_t extraBytes) {
    size_t size = alignedInstanceSize() + extraBytes;
    // CF requires all objects be at least 16 bytes.
    if (size < 16) size = 16;
    return size;
}
    
uint32_t alignedInstanceSize() {
    return word_align(unalignedInstanceSize());
}
    
uint32_t unalignedInstanceSize() {
    assert(isRealized());
    return data()->ro->instanceSize;
}
    
// 字节对齐 - 旧版写法: 8的倍数
static inline uint32_t word_align(uint32_t x) {
    return (x + WORD_MASK) & ~WORD_MASK;
}

// 字节对齐 - 新写法: 16的倍数
static inline size_t align16(size_t x) {
    return (x + size_t(15)) & ~size_t(15);
}


#ifdef __LP64__
#   define WORD_MASK 7UL
#else
#   define WORD_MASK 3UL
#endif
```
##### 初始化`isa_t isa`的具体实现:
```c++
inline void 
objc_object::initIsa(Class cls, bool nonpointer, UNUSED_WITHOUT_INDEXED_ISA_AND_DTOR_BIT bool hasCxxDtor)
{ 
    ASSERT(!isTaggedPointer()); 
    
    isa_t newisa(0);

    if (!nonpointer) {
        newisa.setClass(cls, this);
    } else {
        ASSERT(!DisableNonpointerIsa);
        ASSERT(!cls->instancesRequireRawIsa());

        newisa.bits = ISA_MAGIC_VALUE; 
        // isa.magic is part of ISA_MAGIC_VALUE 表示 当前对象不再只是一个内存空间，已经被初始化。
        // isa.nonpointer is part of ISA_MAGIC_VALUE：表示 newisa 不止包含了类对象地址，还包含了是否有析构函数、对象的引⽤计数等其他信息。
#   if ISA_HAS_CXX_DTOR_BIT
        newisa.has_cxx_dtor = hasCxxDtor;
#   endif
        newisa.setClass(cls, this);
#endif
        newisa.extra_rc = 1;
    }

    isa = newisa;
}

inline void
isa_t::setClass(Class newCls, UNUSED_WITHOUT_PTRAUTH objc_object *obj)
{
    // 删掉相关环境判断条件，最终只执行这一句
    // 将类对象地址右移3位，然后赋值给 shiftcls 成员。
    shiftcls = (uintptr_t)newCls >> 3;
}
```
* 为什么要强转成uintptr_t类型？</br>
uintptr_t是unsigned long类型，由于机器只能识别0 、1这两种数字，即二进制数据，所以将地址存储在内存空间时需要先转换为uintptr_t类型。

* 为什么要右移3位？</br>
地址转换为64位二进制数后，其低3位和高位均是0，所以为了优化内存，可以舍掉这些0 ，只保留中间部分有值的位。

#### alloc总结
一般在这里就完成了对象的实例化，主要经过了三个步骤：
* `cls->instanceSize`：计算需要申请的内存空间大小，最少16字节。
* `calloc`：为对象分配内存空间，并返回内存地址。
* `initInstanceIsa`：初始化`isa_t isa`(其中包含 否有析构函数、对象的引⽤计数等其他信息)，通过它将当前类和开辟的内存空间关联起来。

### init方法
```c++
- (id)init {
    return _objc_rootInit(self);
}

id _objc_rootInit(id obj)
{
    // In practice, it will be hard to rely on this function.
    // Many classes do not properly chain -init calls.
    return obj;
}
```
`init`方法其实没作其他处理，直接返回对象自身。</br>
系统采用工厂设计模式提供了一个构造方法，让开发者重写`init`作相关初始化操作。

### new方法
```c++
+ (id)new {
    return [callAlloc(self, false/*checkNil*/) init];
}
```
`[NSObject new]`方法等同于`[[NSObject alloc] init]`，先调用`callAlloc`方法，再调用`init`方法。这两者的区别在于，采用`[alloc init]`方式可以灵活拓展，比如实现`initWithXXX`这种自定义的`init`方法，而采用`new`方式只能重写父类的`init`方法。

### 对象开辟内存的影响因素
#### 当 HFPerson 类中有1个属性 name 时
.h
```objc
@interface HFPerson : NSObject
@property (nonatomic, copy) NSString *name;
//@property (nonatomic, copy) NSString *nickName;
@end
```
打印size为16

![](media/16502674442776.jpg)


#### 当 HFPerson 类中有2个属性 name, nickName 时
.h
```objc
@interface HFPerson : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *nickName;
@end
```
打印size为32
![](media/16502676341067.jpg)

#### 分析 person 实例对象的内存结构
![](media/16502686414657.jpg)

### 

### 访问类信息
通过以上分析，我们知道 isa 的成员 shiftcls 存有类对象地址，那如何通过 isa 访问到类对象的? </br>
```c++
#import <objc/runtime.h>

Class object_getClass(id obj)
{
    if (obj) return obj->getIsa();
    else return Nil;
}

.
.
.

inline Class
isa_t::getClass(MAYBE_UNUSED_AUTHENTICATED_PARAM bool authenticated) {
    uintptr_t clsbits = bits;
    clsbits &= ISA_MASK;
    return (Class)clsbits;
}
```

### note:
1. 符号断点 </br>
通过符号断点我们可以定位到指定的方法。
2. 三种探索源码的方式：
    1. 符号断点
    2. `control` + `step into`
    3. `debug` - `Always Show Disassembly`
3. 编译器优化
