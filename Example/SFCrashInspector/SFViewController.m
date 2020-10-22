//
//  SFViewController.m
//  SFCrashInspector
//
//  Created by hsfiOSGitHub on 10/22/2020.
//  Copyright (c) 2020 hsfiOSGitHub. All rights reserved.
//

#import "SFViewController.h"
#import "SelectorCrashTestVC.h"
#import "KvcCrashTestVC.h"
#import "KvoCrashTestVC.h"
#import "TimerCrashTestVC.h"

@interface SFViewController ()

@end

@implementation SFViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"TestDemo";
    NSArray *titles = @[@"SelectorCrashTest",
                        @"KvcCrashTest",
                        @"KvoCrashTestVC",
                        @"TimerCrashTestVC"];
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
- (void)test2 {
    KvoCrashTestVC *vc = [[KvoCrashTestVC alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)test3 {
    TimerCrashTestVC *vc = [[TimerCrashTestVC alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
