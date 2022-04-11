//
//  BlockViewController.m
//  Interview-iOS
//
//  Created by HF on 2022/3/1.
//

#import "BlockViewController.h"
#import <objc/runtime.h>

@interface BlockViewController ()

@end

@implementation BlockViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self testType];
}

// MARK: - Block类型
- (void)testType {
    {
        void(^block1)(void) = ^{
            HFLog(@"全局block");
        };
        HFLog(@"%@", block1);
    }
    
    {
        int a = 1;
        void(^block2)(void) = ^{
            HFLog(@"stackblock, %d", a);
        };
        HFLog(@"%@", block2);
    }
    
    {
        int a = 1;
        HFLog(@"%@", ^{
            printf("hh, %d", a);
        });
    }
}

@end
