//
//  AutoReleasePoolViewController.m
//  Interview-iOS
//
//  Created by HF on 2022/2/23.
//

#import "AutoReleasePoolViewController.h"

extern int _objc_rootRetainCount(id);
extern void _objc_autoreleasePoolPrint(void);

@interface AutoReleasePoolViewController ()

@property (nonatomic, strong) NSObject *obj;

@end

@implementation AutoReleasePoolViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    NSObject *obj1 = [[NSObject alloc] init];
    HFLog(@"obj1: %d", _objc_rootRetainCount(obj1));
    
    self.obj = obj1;
    HFLog(@"obj1: %d", _objc_rootRetainCount(obj1));
    
    HFLog(@"%@", [NSRunLoop mainRunLoop]);
}

@end
