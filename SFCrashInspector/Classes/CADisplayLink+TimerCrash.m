//
//  CADisplayLink+TimerCrash.m
//  TestDemo
//
//  Created by 黄山锋 on 2020/10/21.
//  Copyright © 2020 SFTeam. All rights reserved.
//

#import "CADisplayLink+TimerCrash.h"
#import "SFCrashInspectorFunc.h"
#import "NSObject+MethodSwizzling.h"
#import "SFCrashInspectorManager.h"
#import "SFTimerProxy.h"

@implementation CADisplayLink (TimerCrash)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // 交换displayLinkWithTarget:selector:方法
        [NSObject sf_swizzlingClassMethod:@selector(displayLinkWithTarget:selector:) swizzledMethod:@selector(sf_displayLinkWithTarget:selector:) withClass:[CADisplayLink class]];
        
    });
}
 
+ (CADisplayLink *)sf_displayLinkWithTarget:(id)target selector:(SEL)sel {
    BOOL isOpen = [SFCrashInspectorManager checkIsOpenWithOption:SFCrashInspectorOptionTimer];
    if (isOpen && !isSystemClass([target class])) {
        SFTimerProxy *proxy = [SFTimerProxy proxyWithTarget:target aSelector:sel];
        return [self sf_displayLinkWithTarget:proxy selector:@selector(fireProxyDisplayLink:)];
    }
    return [self sf_displayLinkWithTarget:target selector:sel];
}


@end
