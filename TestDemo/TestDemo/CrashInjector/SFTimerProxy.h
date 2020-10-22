//
//  SFTimerProxy.h
//  TestDemo
//
//  Created by 黄山锋 on 2020/10/20.
//  Copyright © 2020 SFTeam. All rights reserved.
//

#import "SFProxy.h"
#import <UIKit/UIKit.h>
#import "SFGcdTimer.h"

NS_ASSUME_NONNULL_BEGIN

@interface SFTimerProxy : SFProxy
- (instancetype)initWithTarget:(id)target aSelector:(SEL)aSelector;
+ (instancetype)proxyWithTarget:(id)target aSelector:(SEL)aSelector;
- (void)fireProxyTimer:(NSTimer *)timer;
- (void)fireProxyDisplayLink:(CADisplayLink *)displayLink;
- (void)fireProxyGcdTimer:(SFGcdTimer *)timer;
@end

NS_ASSUME_NONNULL_END
