//
//  KvcCrashTestVC.m
//  TestDemo
//
//  Created by 黄山锋 on 2020/10/16.
//  Copyright © 2020 SFTeam. All rights reserved.
//

#import "KvcCrashTestVC.h"
#import "Person.h"

@interface KvcCrashTestVC ()

@end

@implementation KvcCrashTestVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"KvcCrashTestVC";
    NSArray *titles = @[@"key为nil",
                        @"value为nil",
                        @"key不是object的属性",
                        @"keyPath不正确"];
    [self addBtnsWithTitles:titles];
    
}
// MARK: test
- (void)test0 {
    // key为nil
    Person *p = [[Person alloc]init];
    [p setValue:@"jack" forKey:nil];
}
- (void)test1 {
    // value为nil
    /**
     * 注意：
     * 只有给非对象类型的属性设置nil值时会发生奔溃
     */
    Person *p = [[Person alloc]init];
    [p setValue:nil forKey:@"age"];
}
- (void)test2 {
    // key不是object的属性
    Person *p = [[Person alloc]init];
    [p setValue:@"jack" forKey:@"aaa"];
}
- (void)test3 {
    // keyPath不正确
    Person *p = [[Person alloc]init];
    [p setValue:@"卡特琳" forKeyPath:@"cat.name"];
}

@end
