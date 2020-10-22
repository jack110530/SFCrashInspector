//
//  SelectorCrashTestVC.m
//  TestDemo
//
//  Created by 黄山锋 on 2020/10/16.
//  Copyright © 2020 SFTeam. All rights reserved.
//

#import "SelectorCrashTestVC.h"
#import "Person.h"

@interface SelectorCrashTestVC ()
@end

@implementation SelectorCrashTestVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"SelectorCrashTestVC";
    NSArray *titles = @[@"找不到对象方法",
                        @"找不到类方法"];
    [self addBtnsWithTitles:titles];
    
}
// MARK: test
- (void)test0 {
    // 找不到对象方法
    Person *p = [[Person alloc]init];
    [p testInstanceFunc];
}
- (void)test1 {
    // 找不到类方法
    [Person testClassFunc];
}


@end
