//
//  OCViewController.m
//  Interview-iOS
//
//  Created by HF on 2022/2/24.
//

#import "OCViewController.h"
#import "OCStudent.h"
#import "OCPerson.h"
#import <objc/runtime.h>

@interface OCViewController ()

@end

@implementation OCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    OCStudent *stu = [[OCStudent alloc] init];
    stu->_name = @"li";
    
    // MARK: - OCStudent在.cpp中的结构
    /* 在.cpp中可发现OCStudent的结构如下：
     struct OCStudent_IMPL {
         struct NSObject_IMPL NSObject_IVARS;
         NSString *_name;
         int _age;
     };
     */
    
    {
        // 打印地址是一样的
        HFLog(@"%p", stu.superclass);
        HFLog(@"%p", [NSObject class]);
    }
    
    // MARK: - OCStudent没有实现的类方法read，最终调用NSObject的实例方法
    {
        [OCStudent read];
    }
    
    // MARK: - super & self
    {
        // self: 指针，消息接收者是self，从该类的方法列表中开始查找
        // super: 编译器修饰符，消息接收者也是self， 从该类的父类中开始查找
        HFLog(@"%p", [self class]);
        HFLog(@"%p", [super class]);
        [stu testA];
    }
    
    OCPerson *person = [[OCPerson alloc] init];
    person.nickName = @"CC";
    NSLog(@"%lu", sizeof(person));
    
    NSLog(@"%lu", class_getInstanceSize([OCPerson class]));
}


@end
