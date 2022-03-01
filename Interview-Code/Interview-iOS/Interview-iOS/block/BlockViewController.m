//
//  BlockViewController.m
//  Interview-iOS
//
//  Created by HF on 2022/3/1.
//

#import "BlockViewController.h"

@interface BlockViewController ()

@end

@implementation BlockViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    ^{
        HFLog(@"block");
    }();
    

}


@end
