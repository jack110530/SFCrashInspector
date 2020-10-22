//
//  TimerCrashTestVC.m
//  TestDemo
//
//  Created by 黄山锋 on 2020/10/20.
//  Copyright © 2020 SFTeam. All rights reserved.
//

#import "TimerCrashTestVC.h"
#import "SFGcdTimer.h"

@interface TimerCrashTestVC ()
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, strong) SFGcdTimer *gcdTimer;
@end

@implementation TimerCrashTestVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"TimerCrashTestVC";
    NSArray *titles = @[@"防止循环引用问题",
                        @"防止target释放掉后，timer还在执行"];
    [self addBtnsWithTitles:titles];
    
//    self.timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(timerEvent) userInfo:nil repeats:YES];
//    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    
//    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(timerEvent)];
//    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    
    self.gcdTimer = [SFGcdTimer timerWithTimeInterval:1 delay:0 target:self selector:@selector(timerEvent) userInfo:nil repeats:YES];
    [self.gcdTimer fire];
    
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
    //[self.timer invalidate];
    //self.timer = nil;
}

@end
