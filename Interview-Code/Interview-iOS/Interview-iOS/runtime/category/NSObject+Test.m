//
//  NSObject+Test.m
//  Interview-iOS
//
//  Created by HF on 2022/3/10.
//

#import "NSObject+Test.h"
#import <objc/runtime.h>

@implementation NSObject (Test)

+ (void)outputMyPropertyList {
    unsigned int count;
    objc_property_t *properyList = class_copyPropertyList([self class], &count);
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < count; i++) {
        [array addObject: [NSString stringWithUTF8String: property_getName(properyList[i])]];
    }
//    HFLog(@"%@ propery list: %@", [self class], array);
}

@end
