//
//  SFProxy.m
//  TestDemo
//
//  Created by 黄山锋 on 2020/10/20.
//  Copyright © 2020 SFTeam. All rights reserved.
//

#import "SFProxy.h"

@interface SFProxy ()

@end

@implementation SFProxy
- (instancetype)initWithTarget:(id)target {
    _target = target;
    return self;
}
+ (instancetype)proxyWithTarget:(id)target {
    return [[self alloc] initWithTarget:target];
}

// 消息转发
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector{
    if (self.target && [self.target respondsToSelector:aSelector]) {
        return [self.target methodSignatureForSelector:aSelector];
    }
    return [super methodSignatureForSelector:aSelector];
}
- (void)forwardInvocation:(NSInvocation *)anInvocation{
    SEL aSelector = [anInvocation selector];
    if (self.target && [self.target respondsToSelector:aSelector]) {
        [anInvocation invokeWithTarget:self.target];
    } else {
        [super forwardInvocation:anInvocation];
    }
}

@end
