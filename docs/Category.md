# Category

### OC示例
创建 HFPerson，HFPerson (Test) 

**HFPerson+Test.h** 文件
```objc
@interface HFPerson (Test)
@property (nonatomic, assign) int age;
@end
```
**HFPerson+Test.m** 文件
```objc
#import "HFPerson+Test.h"
#import <objc/runtime.h>

@implementation HFPerson (Test)
- (void)setAge:(int)age {
    objc_setAssociatedObject(self, @selector(age), @(age), OBJC_ASSOCIATION_ASSIGN);
}

- (int)age {
    return [objc_getAssociatedObject(self, @selector(age)) intValue];
}
@end
```

### 编译后的C++代码
```c++
// HFPerson (Test)
static struct _category_t _OBJC_$_CATEGORY_HFPerson_$_Test __attribute__ ((used, section ("__DATA,__objc_const"))) = 
{
	"HFPerson",
	0, // &OBJC_CLASS_$_HFPerson,
	(const struct _method_list_t *)&_OBJC_$_CATEGORY_INSTANCE_METHODS_HFPerson_$_Test,
	0, // 如果声明了类方法，也会放到这里
	0,
	(const struct _prop_list_t *)&_OBJC_$_PROP_LIST_HFPerson_$_Test,
};

// Category的底层结构
struct _category_t {
    const char *name;
    classref_t *cls;
    struct method_list_t *instanceMethods;
    struct method_list_t *classMethods;
    struct protocol_list_t *protocols;
    struct property_list_t *instanceProperties;
};

// 实例方法列表，也是个结构体
static struct /*_method_list_t*/ {
	unsigned int entsize;  // sizeof(struct _objc_method)
	unsigned int method_count;
	struct _objc_method method_list[2];
} _OBJC_$_CATEGORY_INSTANCE_METHODS_HFPerson_$_Test __attribute__ ((used, section ("__DATA,__objc_const"))) = {
	sizeof(_objc_method),
	2,
	{{(struct objc_selector *)"setAge:", "v20@0:8i16", (void *)_I_HFPerson_Test_setAge_},
	{(struct objc_selector *)"age", "i16@0:8", (void *)_I_HFPerson_Test_age}}
};

// 属性列表，也是个结构体
static struct /*_prop_list_t*/ {
	unsigned int entsize;  // sizeof(struct _prop_t)
	unsigned int count_of_properties;
	struct _prop_t prop_list[1];
} _OBJC_$_PROP_LIST_HFPerson_$_Test __attribute__ ((used, section ("__DATA,__objc_const"))) = {
	sizeof(_prop_t),
	1,
	{{"age","Ti,N"}}
};

static void OBJC_CATEGORY_SETUP_$_HFPerson_$_Test(void ) {
	_OBJC_$_CATEGORY_HFPerson_$_Test.cls = &OBJC_CLASS_$_HFPerson;
}
#pragma section(".objc_inithooks$B", long, read, write)
__declspec(allocate(".objc_inithooks$B")) static void *OBJC_CATEGORY_SETUP[] = {
	(void *)&OBJC_CATEGORY_SETUP_$_HFPerson_$_Test,
};
static struct _category_t *L_OBJC_LABEL_CATEGORY_$ [1] __attribute__((used, section ("__DATA, __objc_catlist,regular,no_dead_strip")))= {
	&_OBJC_$_CATEGORY_HFPerson_$_Test,
};
static struct IMAGE_INFO { unsigned version; unsigned flag; } _OBJC_IMAGE_INFO = { 0, 2 };
```
可以看出：

1. 编译器生成了实例方法列表(结构体)`_OBJC_$_CATEGORY_INSTANCE_METHODS_HFPerson_$_Test`和属性列表(结构体)`_OBJC_$_PROP_LIST_HFPerson_$_Test`，还有一个需要注意到的事实就是category的名字用来给各种列表以及后面的category结构体本身命名，而且有static来修饰，所以在同一个编译单元里我们的category名不能重复，否则会出现编译错误
2. 编译器生成了category本身`_OBJC_$_CATEGORY_HFPerson_$_Test`，并用前面生成的列表来初始化category本身
3. 最后，编译器在DATA段下的objc_catlist section里保存了一个大小为1的category_t的数组L_OBJC_LABELCATEGORY$（当然，如果有多个category，会生成对应长度的数组），用于运行期category的加载

### 如何加载
#### _objc_init入口(objc-os.mm)
`Objective-C`的运行是依赖`OC`的`runtime`的，而`OC`的`runtime`和其他系统库一样，是`OS X`和`iOS`通过`dyld`动态加载的，对于`OC`运行时，入口方法如下(objc-os.mm文件):
```c++
void _objc_init(void)
{
    static bool initialized = false;
    if (initialized) return;
    initialized = true;
    
    // fixme defer initialization until an objc-using image is found?
    // 读取影响运行时的环境变量。如果需要，还可以打印环境变量帮助
    environ_init();
    // 关于线程key的绑定，比如：线程数据的析构函数
    tls_init();
    // 运行C++静态构造函数。在dyld调用我们的静态构造函数之前，libc 会调用 _objc_init()
    static_init();
    // runtime运行时环境初始化
    runtime_init();
    // libobjc异常处理系统初始化
    exception_init();
    // 缓存条件初始化
    cache_init();
    // 启动回调机制。通常不会做什么，因为所有的初始化都是惰性的
    _imp_implementationWithBlock_init();
    /*
     _dyld_objc_notify_register -- dyld 注册的地方
         - 仅供objc运行时使用
         - 注册处理程序，以便在映射、取消映射 和初始化objc镜像文件时使用，dyld将使用包含objc_image_info的镜像文件数组，回调 mapped 函数
     map_images: dyld将image镜像文件加载进内存时，会触发该函数
     load_images: dyld初始化image会触发该函数
     unmap_image: dyld将image移除时会触发该函数
     */
    _dyld_objc_notify_register(&map_images, load_images, unmap_image);

#if __OBJC2__
    didCallDyldNotifyRegister = true;
#endif
}
```
* 深入理解还得明白[dyld加载过程](https://juejin.cn/post/6844904040149729294)
* 在`_dyld_objc_notify_register`函数的`map_images`最终会调用`objc-runtime-new.mm`里面的`_read_images`函数，而在`_read_images`函数中有以下的代码片段：

#### _read_images(...)函数(objc-runtime-new.mm)
```c++
// Discover categories. Only do this after the initial category
// attachment has been done. For categories present at startup,
// discovery is deferred until the first load_images call after
// the call to _dyld_objc_notify_register completes. rdar://problem/53119145
if (didInitialAttachCategories) {
    for (EACH_HEADER) {
        load_categories_nolock(hi);
    }
}
```
* 进一步调用`load_categories_nolock`函数


#### load_categories_nolock(...)函数(objc-runtime-new.mm)
```c++
static void load_categories_nolock(header_info *hi) {
    bool hasClassProperties = hi->info()->hasCategoryClassProperties();

    size_t count;
    // C++ 闭包 [&](category_t * const *catlist) {};
    auto processCatlist = [&](category_t * const *catlist) {
        for (unsigned i = 0; i < count; i++) {
            category_t *cat = catlist[i];
            Class cls = remapClass(cat->cls);
            locstamped_category_t lc{cat, hi};

            if (!cls) {
                // Category's target class is missing (probably weak-linked).
                // Ignore the category.
                if (PrintConnecting) {
                    _objc_inform("CLASS: IGNORING category \?\?\?(%s) %p with "
                                 "missing weak-linked target class",
                                 cat->name, cat);
                }
                continue;
            }

            // Process this category.
            if (cls->isStubClass()) { // 加载rootClass
                // Stub classes are never realized. Stub classes
                // don't know their metaclass until they're
                // initialized, so we have to add categories with
                // class methods or properties to the stub itself.
                // methodizeClass() will find them and add them to
                // the metaclass as appropriate.
                if (cat->instanceMethods ||
                    cat->protocols ||
                    cat->instanceProperties ||
                    cat->classMethods ||
                    cat->protocols ||
                    (hasClassProperties && cat->_classProperties))
                {
                    objc::unattachedCategories.addForClass(lc, cls);
                }
            } else {
                // First, register the category with its target class.
                // Then, rebuild the class's method lists (etc) if
                // the class is realized.
                if (cat->instanceMethods ||  cat->protocols
                    ||  cat->instanceProperties)
                { // 若是实例方法，协议，实例属性
                    if (cls->isRealized()) {
                        attachCategories(cls, &lc, 1, ATTACH_EXISTING);
                    } else {
                        objc::unattachedCategories.addForClass(lc, cls);
                    }
                }

                if (cat->classMethods  ||  cat->protocols
                    ||  (hasClassProperties && cat->_classProperties))
                { // 若是类方法，协议，类属性
                    if (cls->ISA()->isRealized()) {
                        attachCategories(cls->ISA(), &lc, 1, ATTACH_EXISTING | ATTACH_METACLASS);
                    } else {
                        objc::unattachedCategories.addForClass(lc, cls->ISA());
                    }
                }
            }
        }
    };
    
    // 执行闭包函数，参数为catlist和catlist2
    processCatlist(_getObjc2CategoryList(hi, &count));
    processCatlist(_getObjc2CategoryList2(hi, &count));
}
```
* 如果是rootClass，调用`objc::unattachedCategories.addForClass(lc, cls);`添加分类的实例方法，协议，实例属性，类方法，类属性
* 否则，调用`attachCategories`添加分类的实例方法，协议，实例属性，类方法，类属性


#### attachCategories(...)函数(objc-runtime-new.mm)
```c++
static void
attachCategories(Class cls, const locstamped_category_t *cats_list, uint32_t cats_count,
                 int flags)
{
    if (slowpath(PrintReplacedMethods)) {
        printReplacements(cls, cats_list, cats_count);
    }
    if (slowpath(PrintConnecting)) {
        _objc_inform("CLASS: attaching %d categories to%s class '%s'%s",
                     cats_count, (flags & ATTACH_EXISTING) ? " existing" : "",
                     cls->nameForLogging(), (flags & ATTACH_METACLASS) ? " (meta)" : "");
    }

    /*
     * Only a few classes have more than 64 categories during launch.
     * This uses a little stack, and avoids malloc.
     *
     * Categories must be added in the proper order, which is back
     * to front. To do that with the chunking, we iterate cats_list
     * from front to back, build up the local buffers backwards,
     * and call attachLists on the chunks. attachLists prepends the
     * lists, so the final result is in the expected order.
     */
    constexpr uint32_t ATTACH_BUFSIZ = 64;
    method_list_t   *mlists[ATTACH_BUFSIZ]; // 方法列表
    property_list_t *proplists[ATTACH_BUFSIZ]; // 属性列表
    protocol_list_t *protolists[ATTACH_BUFSIZ]; // 协议列表

    uint32_t mcount = 0;
    uint32_t propcount = 0;
    uint32_t protocount = 0;
    bool fromBundle = NO;
    bool isMeta = (flags & ATTACH_METACLASS);
    // rwe 其实就是类对象里面的数据class_rw_t
    auto rwe = cls->data()->extAllocIfNeeded();

    for (uint32_t i = 0; i < cats_count; i++) {
        auto& entry = cats_list[i];
        // 取出分类方法列表，从0开始取，也就是从Compil Sources列表 从上往下 去取
        // 继续往后看会发现，mlists[ATTACH_BUFSIZ - ++mcount] = mlist, mlists中 由后往前 放
        // 最终，如果有同名的方法，后编译的先执行
        method_list_t *mlist = entry.cat->methodsForMeta(isMeta);
        if (mlist) {
            if (mcount == ATTACH_BUFSIZ) {
                prepareMethodLists(cls, mlists, mcount, NO, fromBundle);
                rwe->methods.attachLists(mlists, mcount);
                mcount = 0;
            }
            mlists[ATTACH_BUFSIZ - ++mcount] = mlist;
            fromBundle |= entry.hi->isBundle();
        }
        // 取出分类属性列表
        property_list_t *proplist =
            entry.cat->propertiesForMeta(isMeta, entry.hi);
        if (proplist) {
            if (propcount == ATTACH_BUFSIZ) {
                rwe->properties.attachLists(proplists, propcount);
                propcount = 0;
            }
            proplists[ATTACH_BUFSIZ - ++propcount] = proplist;
        }
        // 取出分类协议列表
        protocol_list_t *protolist = entry.cat->protocolsForMeta(isMeta);
        if (protolist) {
            if (protocount == ATTACH_BUFSIZ) {
                rwe->protocols.attachLists(protolists, protocount);
                protocount = 0;
            }
            protolists[ATTACH_BUFSIZ - ++protocount] = protolist;
        }
    }
        
    if (mcount > 0) {
        prepareMethodLists(cls, mlists + ATTACH_BUFSIZ - mcount, mcount, NO, fromBundle);
        // 将所有分类的实例方法 附加到 类对象方法列表中
        rwe->methods.attachLists(mlists + ATTACH_BUFSIZ - mcount, mcount);
        if (flags & ATTACH_EXISTING) flushCaches(cls);
    }
    // 将所有分类的属性 附加到 类对象属性列表中
    rwe->properties.attachLists(proplists + ATTACH_BUFSIZ - propcount, propcount);
    // 将所有分类的协议 附加到 类对象协议列表中
    rwe->protocols.attachLists(protolists + ATTACH_BUFSIZ - protocount, protocount);
}
```
* 按照Compile Sources中的先后编译顺序，***倒序***放入对应的列表中，如果某个类的多个分类中有同名的方法，后编译的先执行


#### attachLists(...)函数(objc-runtime-new.mm)
```c++
void attachLists(List* const * addedLists, uint32_t addedCount) {
    if (addedCount == 0) return;

    if (hasArray()) {
        // many lists -> many lists
        uint32_t oldCount = array()->count;
        uint32_t newCount = oldCount + addedCount;
        setArray((array_t *)realloc(array(), array_t::byteSize(newCount)));
        array()->count = newCount;
        //array()->lists:原来类对象的方法列表
        //内存移动
        memmove(array()->lists + addedCount,
                array()->lists, 
                oldCount * sizeof(array()->lists[0]));
        //addedLists:所有分类的方法列表
        //内存拷贝
        memcpy(array()->lists,
               addedLists, 
               addedCount * sizeof(array()->lists[0]));
    }
    else if (!list  &&  addedCount == 1) {
        // 0 lists -> 1 list
        list = addedLists[0];
    } 
    else {
        // 1 list -> many lists
        List* oldList = list;
        uint32_t oldCount = oldList ? 1 : 0;
        uint32_t newCount = oldCount + addedCount;
        setArray((array_t *)malloc(array_t::byteSize(newCount)));
        array()->count = newCount;
        if (oldList) array()->lists[addedCount] = oldList;
        memcpy(array()->lists, addedLists, 
               addedCount * sizeof(array()->lists[0]));
    }
}
```
* 将分类数据，插入到类的原来数据的前面


#### 大概流程如下：

1. 通过`Runtime`加载某个类的所有`Category`数据
2. 把所有`Category`的方法，属性，协议数据，合并到一个大数组中
3. 先参与编译的`Category`数据，会放在数组的后面
4. 将合并后的分类数据（方法，属性，协议），插入到类原来数据的前面

#### 重要代码
```c++
//array()->lists:原来类对象的方法列表
//内存移动
memmove(array()->lists + addedCount, array()->lists,  oldCount * sizeof(array()->lists[0]));
//addedLists:所有分类的方法列表
 //内存拷贝
memcpy(array()->lists, addedLists, addedCount * sizeof(array()->lists[0]));
```
#### memmove和memcpy的区别？
* memmove会根据内存大小，移动方向，数量来移动内存；
* memcpy是按照一定规则一个地址一个地址拷贝。
* memmove能保证原数据完整性，内部移动最好不要使用memcpy，外部内存移动可以使用。

### 面试:
#### Q: Category有哪些用途：
```
1. 给已经存在的类添加方法，协议，属性
2. 把类的实现分开在不同的文件里
```
#### Q: Category的实现原理？ 
```
Category实际上是一个category_t的结构体，在运行期，Category的数据(实例方法，类方法，协议，属性)都被以倒序插入到原有类的数据的前面。
a). 其中 倒序 是通过 lists[ATTACH_BUFSIZ - ++mcount] = list;
b). 插入到原有类数据的前面 是通过 mememove 和 memcpy 实现;
```
#### Q: Category能否添加成员变量吗？能否添加属性吗？
```
1. Category的结构决定了不能添加成员变量，其结构体内没有容纳Ivar的数据结构
2. 可以添加属性，系统会给我们声明setter和getter方法，但是并没有实现，所以实际上来说是不能直接添加属性，但是可以通过Runtime的 objc_setAssociatedObject 和 objc_getAssociatedObject 这两个API来间接实现
```
#### Q: 如果ClassA和它的ClassA(CategoryOne)，ClassA(CategoryTwo)都实现了某个方法，那么最终会如何调用?
![-w600](media/16387749069310/16389540761030.jpg)
#### Q: Category 和 Class Extension 有什么区别？

| 区别    | Category           | Extension           |
| :----: | :----: | :----: |
| 生效时机 | 运行时           | 编译时             |
| 添加属性 | 可以</br>（只声明setter/getter，未实现）| 可以                     |
| 添加方法 | 可以</br>（通常将一类方法单独放在一个文件里面）| 可以</br>(通常在.m文件中实现) |
| 示例 | @interface ClassName (category)</br> @end</br>@implementation</br>@end| @interface ClassName()</br>@end |



### 动态绑定
如上分析，我们知道在`category`里面是无法为`category`添加实例变量的。但是我们很多时候需要在`category`中添加和对象关联的值，这个时候可以求助关联对象来实现：
#### 示例
```objc
#import "HFPerson+Test.h"
#import <objc/runtime.h>

@implementation HFPerson (Test)

- (void)setAge:(int)age {
    objc_setAssociatedObject(self, @selector(age), @(age), OBJC_ASSOCIATION_ASSIGN);
}

- (int)age {
    return [objc_getAssociatedObject(self, @selector(age)) intValue];
}
@end
```


#### C++代码
```c++
static void _I_HFPerson_Test_setAge_(HFPerson * self, SEL _cmd, int age) {
    objc_setAssociatedObject(self, sel_registerName("age"), ((NSNumber *(*)(Class, SEL, int))(void *)objc_msgSend)(objc_getClass("NSNumber"), sel_registerName("numberWithInt:"), (int)(age)), OBJC_ASSOCIATION_ASSIGN);
}



static int _I_HFPerson_Test_age(HFPerson * self, SEL _cmd) {
    return ((int (*)(id, SEL))(void *)objc_msgSend)((id)objc_getAssociatedObject(self, sel_registerName("age")), sel_registerName("intValue"));
}
```
其中的`objc_setAssociatedObject(...)`函数，进一步会调用`_object_set_associative_reference(...)`
```c++
void _object_set_associative_reference(id object, void *key, id value, uintptr_t policy) {
    // retain the new value (if any) outside the lock.
    ObjcAssociation old_association(0, nil);
    id new_value = value ? acquireValue(value, policy) : nil;
    {
        AssociationsManager manager;
        AssociationsHashMap &associations(manager.associations());
        disguised_ptr_t disguised_object = DISGUISE(object);
        if (new_value) {
            // break any existing association.
            AssociationsHashMap::iterator i = associations.find(disguised_object);
            if (i != associations.end()) {
                // secondary table exists
                ObjectAssociationMap *refs = i->second;
                ObjectAssociationMap::iterator j = refs->find(key);
                if (j != refs->end()) {
                    old_association = j->second;
                    j->second = ObjcAssociation(policy, new_value);
                } else {
                    (*refs)[key] = ObjcAssociation(policy, new_value);
                }
            } else {
                // create the new association (first time).
                ObjectAssociationMap *refs = new ObjectAssociationMap;
                associations[disguised_object] = refs;
                (*refs)[key] = ObjcAssociation(policy, new_value);
                _class_setInstancesHaveAssociatedObjects(_object_getClass(object));
            }
        } else {
            // setting the association to nil breaks the association.
            AssociationsHashMap::iterator i = associations.find(disguised_object);
            if (i !=  associations.end()) {
                ObjectAssociationMap *refs = i->second;
                ObjectAssociationMap::iterator j = refs->find(key);
                if (j != refs->end()) {
                    old_association = j->second;
                    refs->erase(j);
                }
            }
        }
    }
    // release the old value (outside of the lock).
    if (old_association.hasValue()) ReleaseValue()(old_association);
}
```
我们可以看到所有的关联对象都由AssociationsManager管理，而AssociationsManager定义如下：
```c++
class AssociationsManager {
    static OSSpinLock _lock;
    static AssociationsHashMap *_map; // associative references:  object pointer -> PtrPtrHashMap.
public:
    AssociationsManager()   { OSSpinLockLock(&_lock); }
    ~AssociationsManager()  { OSSpinLockUnlock(&_lock); }
    
    AssociationsHashMap &associations() {
        if (_map == NULL)
            _map = new AssociationsHashMap();
        return *_map;
    }
}
```
AssociationsManager里面是由一个静态AssociationsHashMap来存储所有的关联对象的。这相当于把所有对象的关联对象都存在一个全局map里面。而map的的key是这个对象的指针地址（任意两个不同对象的指针地址一定是不同的），而这个map的value又是另外一个AssociationsHashMap，里面保存了关联对象的kv对。

而在对象的销毁逻辑里面，见objc-runtime-new.mm:
```c++
void *objc_destructInstance(id obj) 
{
    if (obj) {
        Class isa_gen = _object_getClass(obj);
        class_t *isa = newcls(isa_gen);

        // Read all of the flags at once for performance.
        bool cxx = hasCxxStructors(isa);
        bool assoc = !UseGC && _class_instancesHaveAssociatedObjects(isa_gen);

        // This order is important.
        if (cxx) object_cxxDestruct(obj);
        if (assoc) _object_remove_assocations(obj);
        
        if (!UseGC) objc_clear_deallocating(obj);
    }

    return obj;
}
```
嗯，`runtime`的销毁对象函数`objc_destructInstance`里面会判断这个对象有没有关联对象，如果有，会调用`_object_remove_assocations`做关联对象的清理工作。