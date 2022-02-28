//
//  KVCViewController.m
//  Interview-iOS
//
//  Created by HF on 2022/2/25.
//

#import "KVCViewController.h"
#import "KVCPerson.h"

@interface KVCViewController ()
@property (nonatomic, strong) KVCPerson *person;
@end

@implementation KVCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.person = [KVCPerson new];
    // setvalue for 属性
    [self.person setValue:@"张三" forKey:@"name"];
    
    // setvalue for ivar
    [self.person setValue:@18 forKey:@"age"];
    
    // setvalue for nil
    [self.person setValue:@3 forKey:@"books"];
    
    // 给成员变量添加KVO监听
    [self.person addObserver:self forKeyPath:@"age" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self kvcSet];
}

- (void)getValueFromKVC {
    // getValue
    NSString *name = [self.person valueForKey:@"name"];
    NSNumber *age = [self.person valueForKey:@"age"];
    NSNumber *books = [self.person valueForKey:@"books"];
    
    
    HFLog(@"name: %@", name);
    HFLog(@"age: %@", age);
    HFLog(@"books: %@", books);
}

- (void)triggerKVCViaKVC {
    [self.person setValue:@1 forKey:@"age"];
}

- (void)triggerKVCViaAssign {
    self.person->_age = 2;
}

- (void)kvcSet {
    NSArray* arrStr = @[@"english",@"franch",@"chinese"];
    NSArray* arrCapStr = [arrStr valueForKey:@"capitalizedString"];
    for (NSString* str  in arrCapStr) {
        HFLog(@"%@",str);
    }
    NSArray* arrCapStrLength = [arrStr valueForKeyPath:@"capitalizedString.length"];
    for (NSNumber* length  in arrCapStrLength) {
        HFLog(@"%ld",(long)length.integerValue);
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    HFLog(@"change: %@", change);
}

@end
