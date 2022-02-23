//
//  HFAutoReleasePool.m
//  Interview-iOS
//
//  Created by HF on 2022/2/23.
//

#import "HFAutoReleasePool.h"

@implementation HFAutoReleasePool

struct __AtAutoreleasePool {
    __AtAutoreleasePool() {
        atautoreleasepoolobjc =objc_autoreleasePoolPush();
    }
    
    ~__AtAutoreleasePool() {
        objc_autoreleasePoolPop(atautoreleasepoolobj);
    }
    
    void * atautoreleasepoolobj;
};

- (void)testReleasePool {
    {
        __AtAutoreleasePool __AtAutoreleasePool;
        NSObject *obj = 
    }
}

@end
