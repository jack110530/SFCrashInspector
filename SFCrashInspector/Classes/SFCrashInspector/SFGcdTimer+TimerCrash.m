//
//  SFGcdTimer+TimerCrash.m
//  TestDemo
//
//  Created by 黄山锋 on 2020/10/22.
//  Copyright © 2020 SFTeam. All rights reserved.
//

#import "SFGcdTimer+TimerCrash.h"
#import "SFCrashInspectorFunc.h"
#import "NSObject+MethodSwizzling.h"
#import "SFCrashInspectorManager.h"
#import "SFTimerProxy.h"

@implementation SFGcdTimer (TimerCrash)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // 交换initWithTimeInterval:delay:target:selector:userInfo:repeats:queue:方法
        [NSObject sf_swizzlingInstanceMethod:@selector(initWithTimeInterval:delay:target:selector:userInfo:repeats:queue:) swizzledMethod:@selector(sf_initWithTimeInterval:delay:target:selector:userInfo:repeats:queue:) withClass:[SFGcdTimer class]];
        
    });
}
 
- (instancetype)sf_initWithTimeInterval:(NSTimeInterval)interval delay:(NSTimeInterval)delay target:(id)aTarget selector:(SEL)aSelector userInfo:(nullable id)userInfo repeats:(BOOL)repeats queue:(dispatch_queue_t)queue {
    BOOL isOpen = [SFCrashInspectorManager checkIsOpenWithOption:SFCrashInspectorOptionTimer];
    if (isOpen && !isSystemClass([aTarget class])) {
        SFTimerProxy *proxy = [SFTimerProxy proxyWithTarget:aTarget aSelector:aSelector];
        return [self sf_initWithTimeInterval:interval delay:delay target:proxy selector:@selector(fireProxyGcdTimer:) userInfo:userInfo repeats:repeats queue:queue];
    }
    return [self initWithTimeInterval:interval delay:delay target:aTarget selector:aSelector userInfo:userInfo repeats:repeats queue:queue];
}



@end
