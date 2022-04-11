//
//  AOObject+Category.m
//  Interview-iOS
//
//  Created by HF on 2022/4/11.
//

#import "AOObject+Category.h"
#import <objc/runtime.h>

@implementation AOObject (Category)

- (void)setNum:(int)num {
    objc_setAssociatedObject(self, @selector(num), @(num), OBJC_ASSOCIATION_ASSIGN);
}

- (int)num {
    return [objc_getAssociatedObject(self, @selector(num)) intValue];
}

@end
