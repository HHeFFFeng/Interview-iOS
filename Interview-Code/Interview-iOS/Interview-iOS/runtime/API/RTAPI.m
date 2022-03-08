//
//  RTAPI.m
//  Interview-iOS
//
//  Created by HF on 2022/3/8.
//

#import "RTAPI.h"
#import <objc/runtime.h>

@interface APIPerson : NSObject
{
    NSString *_name;
    int _age;
    int gender;
    NSString *_address;
}

@property (nonatomic, assign) float height;

- (void)run;

@end

@implementation APIPerson

- (void)run {
    HFLog(@"run");
}

@end

@interface RTAPI()

@end

@implementation RTAPI


// 创建类 & 注册类
- (void)testCreateClass {
    char * clsName = "RTTestClass";
    
    Class aCls = objc_allocateClassPair([NSObject class], clsName, 0);
    
    objc_registerClassPair(aCls);
    
    id objc = [aCls new];
    
    objc_disposeClassPair(aCls);
    
    HFLog(@"~~~~%@", objc);
}

// MARK: - 设置isa指向的class
- (void)testChangeISAClass {
    APIPerson *person = [APIPerson new];
    [person run];
    
    object_setClass(person, [RTAPI class]);
    [person run];
}

// MARK: - 判断OC对象是否为一个class
- (void)testObjectIsClass {
    APIPerson *person = [APIPerson new];
    HFLog(@"%d", object_isClass(person));
}

// MARK: - 获取一个实例变量信息
- (void)testGetInstanceVariable {
    Ivar ivar = class_getInstanceVariable([APIPerson class], "_name");
    
    // 获取 成员变量名
    HFLog(@"ivar.name: %s", ivar_getName(ivar));
    // 获取 成员变量 类型编码
    HFLog(@"ivar.type encoding: %s", ivar_getTypeEncoding(ivar));
}

// MARK: - 获取成员变量列表
- (void)testCopyIvarList {
    unsigned int count;
    Ivar *ivars = class_copyIvarList([APIPerson class], &count);
    for (int i = 0; i < count; i++) {
        Ivar ivar = ivars[i];
        HFLog(@"name: %s, type_encoding: %s", ivar_getName(ivar), ivar_getTypeEncoding(ivar));
    }
}

- (void)run {
    HFLog(@"run")
}

@end
