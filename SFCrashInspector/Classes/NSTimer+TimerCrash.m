//
//  NSTimer+TimerCrash.m
//  TestDemo
//
//  Created by 黄山锋 on 2020/10/20.
//  Copyright © 2020 SFTeam. All rights reserved.
//

#import "NSTimer+TimerCrash.h"
#import "SFCrashInspectorFunc.h"
#import "NSObject+MethodSwizzling.h"
#import "SFCrashInspectorManager.h"
#import "SFTimerProxy.h"

@implementation NSTimer (TimerCrash)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // 交换timerWithTimeInterval:target:selector:userInfo:repeats:方法
        [NSObject sf_swizzlingClassMethod:@selector(timerWithTimeInterval:target:selector:userInfo:repeats:) swizzledMethod:@selector(sf_timerWithTimeInterval:target:selector:userInfo:repeats:) withClass:[NSTimer class]];
        
        // 交换scheduledTimerWithTimeInterval:target:selector:userInfo:repeats:方法
        [NSObject sf_swizzlingClassMethod:@selector(scheduledTimerWithTimeInterval:target:selector:userInfo:repeats:) swizzledMethod:@selector(sf_scheduledTimerWithTimeInterval:target:selector:userInfo:repeats:) withClass:[NSTimer class]];
    });
}

+ (NSTimer *)sf_timerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(nullable id)userInfo repeats:(BOOL)yesOrNo {
    BOOL isOpen = [SFCrashInspectorManager checkIsOpenWithOption:SFCrashInspectorOptionTimer];
    if (isOpen && !isSystemClass([aTarget class])) {
        SFTimerProxy *proxy = [SFTimerProxy proxyWithTarget:aTarget aSelector:aSelector];
        return [self sf_timerWithTimeInterval:ti target:proxy selector:@selector(fireProxyTimer:) userInfo:userInfo repeats:yesOrNo];
    }
    return [self sf_timerWithTimeInterval:ti target:aTarget selector:aSelector userInfo:userInfo repeats:yesOrNo];
}

+ (NSTimer *)sf_scheduledTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(nullable id)userInfo repeats:(BOOL)yesOrNo {
    BOOL isOpen = [SFCrashInspectorManager checkIsOpenWithOption:SFCrashInspectorOptionTimer];
    if (isOpen && !isSystemClass([aTarget class])) {
        SFTimerProxy *proxy = [SFTimerProxy proxyWithTarget:aTarget aSelector:aSelector];
        return [self sf_scheduledTimerWithTimeInterval:ti target:proxy selector:@selector(fireProxyTimer:) userInfo:userInfo repeats:yesOrNo];
    }
    return [self sf_scheduledTimerWithTimeInterval:ti target:aTarget selector:aSelector userInfo:userInfo repeats:yesOrNo];
}

@end
