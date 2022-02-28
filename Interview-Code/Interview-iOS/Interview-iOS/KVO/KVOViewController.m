//
//  KVOViewController.m
//  Interview-iOS
//
//  Created by HF on 2022/2/25.
//

#import "KVOViewController.h"
#import "KVOPerson.h"
#import <objc/runtime.h>

@interface KVOViewController ()
@property (nonatomic, strong) KVOPerson *person;
@end

@implementation KVOViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.person = [KVOPerson new];
    self.person.name = @"张三";
    
    [self testIMP];
}

- (void)testObject_getClass {
    HFLog(@"KVO之前: %@", object_getClass(self.person));
    [self.person addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
    HFLog(@"KVO之后: %@", object_getClass(self.person));
}

- (void)testIMP {
    HFLog(@"KVO之前: %p", [self.person methodForSelector:@selector(setName:)]);
    [self.person addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
    HFLog(@"KVO之前: %p", [self.person methodForSelector:@selector(setName:)]);
}

- (void)dealloc {
    [self.person removeObserver:self forKeyPath:@"name"];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    unsigned int count;
    Method *methods = class_copyMethodList(object_getClass(self.person), &count);
    for (int i = 0; i < count; i++) {
        Method method = methods[i];
        SEL selector = method_getName(method);
        NSString *name = NSStringFromSelector(selector);
        HFLog(@"method_getName:%@",name);
    }
    self.person.name = @"李四";
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    HFLog(@"监听到%@的属性值%@发生改变 - %@", object, keyPath, change);
}

@end
