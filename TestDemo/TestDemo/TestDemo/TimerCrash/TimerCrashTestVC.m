//
//  TimerCrashTestVC.m
//  TestDemo
//
//  Created by 黄山锋 on 2020/10/20.
//  Copyright © 2020 SFTeam. All rights reserved.
//

#import "TimerCrashTestVC.h"
#import "SFTimerProxy.h"

@interface TimerCrashTestVC ()
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation TimerCrashTestVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"TimerCrashTestVC";
    NSArray *titles = @[@"防止循环引用问题",
                        @"防止target释放掉后，timer还在执行"];
    [self addBtnsWithTitles:titles];
    
    SFTimerProxy *proxy = [SFTimerProxy proxyWithTarget:self aSelector:@selector(timerEvent)];
    self.timer = [NSTimer timerWithTimeInterval:1 target:proxy selector:@selector(fireProxyTimer:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}
// MARK: test
- (void)test0 {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)test1 {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)timerEvent{
    NSLog(@"定时器事件");
}

- (void)dealloc {
    NSLog(@"%s", __func__);
}

@end
