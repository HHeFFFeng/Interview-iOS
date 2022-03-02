//
//  RuntimeViewController.m
//  Interview-iOS
//
//  Created by HF on 2022/3/1.
//

#import "RuntimeViewController.h"
#import "RTPerson.h"

@interface RuntimeViewController ()
@property (nonatomic, strong) RTPerson *person;
@end

@implementation RuntimeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self testUnion];
}

// MARK: - 共用体
- (void)testUnion {
    // <arm64, isa是个 指针
    // >arm64, isa是一个 共用体
     
    // 需求：以最小的消耗给Person设置高、富、帅属性
    // 共用体实现
    
    // char _tallRichHandsome;
    // 标志位直接用 二进制 表示
    self.person = [RTPerson new];
    self.person.tall = YES;
    self.person.handsome = YES;
    HFLog(@"high: %d, rich: %d, handsome: %d", _person.isTall, _person.isRich, _person.isHandsome);
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.person.tall = NO;
    self.person.rich = YES;
    HFLog(@"high: %d, rich: %d, handsome: %d", _person.isTall, _person.isRich, _person.isHandsome);
}

@end
