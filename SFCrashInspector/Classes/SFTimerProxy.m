//
//  SFTimerProxy.m
//  TestDemo
//
//  Created by 黄山锋 on 2020/10/20.
//  Copyright © 2020 SFTeam. All rights reserved.
//

#import "SFTimerProxy.h"

@implementation SFTimerProxy
{
    SEL _aSelector;
}
- (instancetype)initWithTarget:(id)target aSelector:(SEL)aSelector {
    self = [super initWithTarget:target];
    _aSelector = aSelector;
    return self;
}
+ (instancetype)proxyWithTarget:(id)target aSelector:(SEL)aSelector {
    return [[self alloc] initWithTarget:target aSelector:aSelector];
}

- (void)fireProxyTimer:(NSTimer *)timer {
    if (self.target) {
        if ([self.target respondsToSelector:_aSelector]) {
            [self.target performSelector:_aSelector withObject:timer];
        }
    }else{
        [timer invalidate];
        timer = nil;
    }
}
- (void)fireProxyDisplayLink:(CADisplayLink *)displayLink {
    if (self.target) {
        if ([self.target respondsToSelector:_aSelector]) {
            [self.target performSelector:_aSelector withObject:displayLink];
        }
    }else{
        [displayLink invalidate];
        displayLink = nil;
    }
}
- (void)fireProxyGcdTimer:(SFGcdTimer *)timer {
    if (self.target) {
        if ([self.target respondsToSelector:_aSelector]) {
            [self.target performSelector:_aSelector withObject:timer];
        }
    }else{
        [timer invalidate];
        timer = nil;
    }
}

// 设置白名单
- (BOOL)respondsToSelector:(SEL)aSelector {
    if (aSelector == @selector(fireProxyTimer:)
        || aSelector == @selector(fireProxyDisplayLink:)
        || aSelector == @selector(fireProxyGcdTimer:)) {
        return YES;
    }else{
        return [super respondsToSelector:aSelector];
    }
}

@end
