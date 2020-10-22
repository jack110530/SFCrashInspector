//
//  SFGcdTimer.m
//  JX_GCDTimer
//
//  Created by 黄山锋 on 2020/10/22.
//  Copyright © 2020 com.joeyxu. All rights reserved.
//

#import "SFGcdTimer.h"

@interface SFGcdTimer ()
@property (nonatomic, strong) dispatch_source_t timer;
@property (nonatomic, strong) dispatch_queue_t queue;
/**
 * 提问：苹果为什么要把NSTimer中的target设计成强引用关系，既然他会导致循环引用问题，为什么苹果不直接将NSTimer的target设计成弱引用关系？
 * 所以这里保留跟NSTimer类似的设计
 */
@property (nonatomic, strong) NSObject *target;
@property (nullable, retain) id userInfo;
@property (nonatomic, assign) NSTimeInterval timeInterval;
@end

@implementation SFGcdTimer

// MARK: target方式
/// 初始化方法（target）
/// @param interval 时间间隔
/// @param delay 延迟时间
/// @param aTarget 执行对象
/// @param aSelector 执行方法
/// @param userInfo 附带信息
/// @param repeats 是否重复
+ (SFGcdTimer *)timerWithTimeInterval:(NSTimeInterval)interval delay:(NSTimeInterval)delay target:(id)aTarget selector:(SEL)aSelector userInfo:(nullable id)userInfo repeats:(BOOL)repeats  {
    SFGcdTimer *timer = [[SFGcdTimer alloc] initWithTimeInterval:interval delay:delay target:aTarget selector:aSelector userInfo:userInfo repeats:repeats queue:nil];
    return timer;
}

/// 初始化方法（target）
/// @param interval 时间间隔
/// @param delay 延迟时间
/// @param aTarget 执行对象
/// @param aSelector 执行方法
/// @param userInfo 附带信息
/// @param repeats 是否重复
/// @param queue 指定队列（默认主队列）
+ (SFGcdTimer *)timerWithTimeInterval:(NSTimeInterval)interval delay:(NSTimeInterval)delay target:(id)aTarget selector:(SEL)aSelector userInfo:(nullable id)userInfo repeats:(BOOL)repeats queue:(dispatch_queue_t)queue {
    SFGcdTimer *timer = [[SFGcdTimer alloc] initWithTimeInterval:interval delay:delay target:aTarget selector:aSelector userInfo:userInfo repeats:repeats queue:queue];
    return timer;
}

/// 初始化方法（target）
/// @param interval 时间间隔
/// @param delay 延迟时间
/// @param aTarget 执行对象
/// @param aSelector 执行方法
/// @param userInfo 附带信息
/// @param repeats 是否重复
/// @param queue 指定队列（默认主队列）
- (instancetype)initWithTimeInterval:(NSTimeInterval)interval delay:(NSTimeInterval)delay target:(id)aTarget selector:(SEL)aSelector userInfo:(nullable id)userInfo repeats:(BOOL)repeats queue:(dispatch_queue_t)queue {
    if (self = [super init]) {
        self.timeInterval = interval;
        self.queue = queue;
        self.target = aTarget;
        self.userInfo = userInfo;
        self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self.queue);
        dispatch_source_set_timer(self.timer,
                                  dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC), // 开始时间
                                  interval * NSEC_PER_SEC, // 间隔
                                  0 // 误差
                                  );
        dispatch_source_set_event_handler(self.timer, ^{
            if ([self.target respondsToSelector:aSelector]) {
                [self.target performSelector:aSelector withObject:self];
            }
            if (!repeats) {
                [self invalidate];
            }
        });
    }
    return self;
}


// MARK: block方式
/// 初始化方法（block）
/// @param interval 时间间隔
/// @param delay 延迟时间
/// @param repeats 是否重复
/// @param block 执行block
+ (SFGcdTimer *)timerWithTimeInterval:(NSTimeInterval)interval delay:(NSTimeInterval)delay repeats:(BOOL)repeats block:(void (^)(SFGcdTimer *timer))block {
    SFGcdTimer *timer = [[SFGcdTimer alloc]initWithTimeInterval:interval delay:delay repeats:repeats block:block queue:nil];
    return timer;
}


/// 初始化方法（block）
/// @param interval 时间间隔
/// @param delay 延迟时间
/// @param repeats 是否重复
/// @param block 执行block
/// @param queue 执行队列（默认主队列）
+ (SFGcdTimer *)timerWithTimeInterval:(NSTimeInterval)interval delay:(NSTimeInterval)delay repeats:(BOOL)repeats block:(void (^)(SFGcdTimer *timer))block queue:(dispatch_queue_t)queue {
    SFGcdTimer *timer = [[SFGcdTimer alloc]initWithTimeInterval:interval delay:delay repeats:repeats block:block queue:queue];
    return timer;
}


/// 初始化方法（block）
/// @param interval 时间间隔
/// @param delay 延迟时间
/// @param repeats 是否重复
/// @param block 执行block
/// @param queue 执行队列（默认主队列）
- (instancetype)initWithTimeInterval:(NSTimeInterval)interval delay:(NSTimeInterval)delay repeats:(BOOL)repeats block:(void (^)(SFGcdTimer *timer))block queue:(dispatch_queue_t)queue {
    if (self = [super init]) {
        self.timeInterval = interval;
        self.queue = queue;
        self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self.queue);
        dispatch_source_set_timer(self.timer,
                                  dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC), // 开始时间
                                  interval * NSEC_PER_SEC, // 间隔
                                  0 // 误差
                                  );
        dispatch_source_set_event_handler(self.timer, ^{
            if (block) {
                block(self);
            }
            if (!repeats) {
                [self invalidate];
            }
        });
    }
    return self;
}

/// 开启
- (void)fire {
    dispatch_resume(self.timer);
}

/// 暂停
- (void)pause {
    dispatch_suspend(self.timer);
}

/// 销毁
- (void)invalidate {
    dispatch_source_cancel(self.timer);
}


#pragma mark - lazy load
// 默认主队列
- (dispatch_queue_t)queue {
    if (!_queue) {
        _queue = dispatch_get_main_queue();
    }
    return _queue;
}

@end
