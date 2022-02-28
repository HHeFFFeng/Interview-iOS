//
//  KVCPerson.m
//  Interview-iOS
//
//  Created by HF on 2022/2/25.
//

#import "KVCPerson.h"

@interface KVCPerson()
@property (nonatomic, copy) NSString *name;
@end

@implementation KVCPerson


// 如果返回NO，直接关掉当前类的KVO
+ (BOOL)accessInstanceVariablesDirectly {
    return YES;
}

// 赋值未找到
- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    HFLog(@"setValue:forUndefinedKey: %@", key);
}

// 取值未找到
- (id)valueForUndefinedKey:(NSString *)key {
    HFLog(@"valueForUndefinedKey: %@", key);
    return nil;
}

@end
