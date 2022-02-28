//
//  NSKVONotifying_KVOPerson.m
//  Interview-iOS
//
//  Created by HF on 2022/2/25.
//

#import "NSKVONotifying_KVOPerson.h"

@implementation NSKVONotifying_KVOPerson

void _NSSetObjectValueAndNotify() {
    [self willChangeValueForKey:@"name"];
    [super setName:name];
    [self didChangeValueForKey:@"name"];
}

- (void)setName:(NSString *)name {
    _NSSetObjectValueAndNotify()
}

- (Class)class {
    return [KVOPerson class];
}

- (void)dealloc {
    // 收尾工作
}

- (void)_isKVOA {
    // 判断当前类是否是KVO动态生成的
}

@end
