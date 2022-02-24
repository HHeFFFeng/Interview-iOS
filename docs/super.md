# super & self

### 面试题
```objc
@interface HFPerson : NSObject
- (void)run;
@end

@implementation HFPerson
- (void)run {
    NSLog(@"%s", __func__);
}
@end

@interface HFStudent : HFPerson
@end

@implementation HFStudent
- (instancetype)init {
    if (self = [super init]) {
        NSLog(@"[self class] == %@", [self class]);
        NSLog(@"[self superclass] == %@", [self superclass]);
        NSLog(@"~~~~~~~~~~~~");
        NSLog(@"[super class] == %@", [super class]);
        NSLog(@"[super superclass] == %@", [super superclass]);
    }
    return self;
}

- (void)run {
    [super run];
}
@end
```
打印结果:
```objc
2022-01-13 00:22:33.378902+0800 KCObjcBuild[20002:887033] [self class] == HFStudent
2022-01-13 00:22:33.380429+0800 KCObjcBuild[20002:887033] [self superclass] == HFPerson
2022-01-13 00:22:33.380624+0800 KCObjcBuild[20002:887033] ~~~~~~~~~~~~
2022-01-13 00:22:33.380709+0800 KCObjcBuild[20002:887033] [super class] == HFStudent
2022-01-13 00:22:33.380855+0800 KCObjcBuild[20002:887033] [super superclass] == HFPerson
```

### 本质
```objc
- (void)run {
    [super run];
}
```
转为`c++`代码：
```c
struct objc_super {
    __unsafe_unretained _Nonnull id receiver; // 消息接收者
    __unsafe_unretained _Nonnull Class super_class; // 消息接收者的父类，也是消息查找的起点...
}

static void _I_HFStudent_run(HFStudent * self, SEL _cmd) {
    objc_msgSendSuper(
                      (__rw_objc_super){
                          (id)self,
                          (id)class_getSuperclass(objc_getClass("HFStudent"))
                      },
                      sel_registerName("run")
                      );
}
```
`[super message]`的底层实现：</br>
1. objc_msgSendSuper(self, 方法名)，通过当前类找到他父类
2. 消息接收者依然是当前子类对象
3. 消息发送时从父类开始查找
