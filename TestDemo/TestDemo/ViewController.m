//
//  ViewController.m
//  TestDemo
//
//  Created by 黄山锋 on 2020/9/23.
//  Copyright © 2020 SFTeam. All rights reserved.
//

#import "ViewController.h"
#import "SelectorCrashTestVC.h"
#import "KvcCrashTestVC.h"

@interface ViewController ()


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"TestDemo";
    NSArray *titles = @[@"SelectorCrashTest", @"KvcCrashTest"];
    [self addBtnsWithTitles:titles];
}

// MARK: test
- (void)test0 {
    SelectorCrashTestVC *vc = [[SelectorCrashTestVC alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)test1 {
    KvcCrashTestVC *vc = [[KvcCrashTestVC alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
