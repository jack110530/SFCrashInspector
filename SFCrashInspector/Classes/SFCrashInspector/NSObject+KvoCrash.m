//
//  NSObject+KvoCrash.m
//  TestDemo
//
//  Created by 黄山锋 on 2020/10/19.
//  Copyright © 2020 SFTeam. All rights reserved.
//

#import "NSObject+KvoCrash.h"
#import "SFCrashInspectorFunc.h"
#import "NSObject+MethodSwizzling.h"
#import "SFCrashInspectorManager.h"
#import <objc/runtime.h>

#pragma mark - SFKovInfo
@interface SFKovInfo : NSObject

+ (instancetype)infoWithObserver:(nonnull NSObject *)observer forKeyPath:(nonnull NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(nullable void *)context;

@end

@implementation SFKovInfo
{
    @package
    __weak NSObject *_observer;
    NSString *_keyPath;
    NSKeyValueObservingOptions _options;
    void *_context;
}

/// 初始化方法
+ (instancetype)infoWithObserver:(nonnull NSObject *)observer forKeyPath:(nonnull NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(nullable void *)context {
    if (!observer || !keyPath || [keyPath isEqualToString:@""]) {
        return nil;
    }
    SFKovInfo *info = [[SFKovInfo alloc]init];
    info->_observer = observer;
    info->_keyPath = keyPath;
    info->_options = options;
    info->_context = context;
    return info;
}

@end

#pragma mark - SFKvoProxy
@interface SFKvoProxy : NSObject

@property (nonatomic, weak) NSObject *observed;// 被观察者

- (BOOL)addKvoInfoToMapsWithObserver:(NSObject *)observer
                          forKeyPath:(NSString *)keyPath
                             options:(NSKeyValueObservingOptions)options
                             context:(nullable void *)context;

- (BOOL)removeKvoInfoToMapsWithObserver:(NSObject *)observer
                             forKeyPath:(NSString *)keyPath
                                options:(NSKeyValueObservingOptions)options
                                context:(nullable void *)context;

- (NSSet<SFKovInfo *> *)getInfoSetWithObserver:(NSObject *)observer;

@end

@implementation SFKvoProxy
{
    // 关系数据表结构：{keypath : [observer1, observer2 , ...]}
    @private
    NSMutableDictionary<NSString *, NSMutableSet<SFKovInfo *> *> *_kvoInfoMap;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _kvoInfoMap = [NSMutableDictionary dictionary];
    }
    return self;
}

- (BOOL)addKvoInfoToMapsWithObserver:(NSObject *)observer
                          forKeyPath:(NSString *)keyPath
                             options:(NSKeyValueObservingOptions)options
                             context:(nullable void *)context{
    @synchronized (self) {
        SFKovInfo *info = [SFKovInfo infoWithObserver:observer forKeyPath:keyPath options:options context:context];
        if (!info) {
            return NO;
        }
        NSMutableSet<SFKovInfo *> *infoSet = [self getSafeInfoSetWithKeyPath:keyPath];
        BOOL isExist = [self checkExistWithKvoInfo:info ininfoSet:infoSet];
        if (isExist) {
            return NO;
        }else{
            [infoSet addObject:info];
            _kvoInfoMap[keyPath] = infoSet;
            return YES;
        }
    }
}

- (BOOL)removeKvoInfoToMapsWithObserver:(NSObject *)observer
                             forKeyPath:(NSString *)keyPath
                                options:(NSKeyValueObservingOptions)options
                                context:(nullable void *)context{
    @synchronized (self) {
        SFKovInfo *info = [SFKovInfo infoWithObserver:observer forKeyPath:keyPath options:options context:context];
        if (!info) {
            return NO;
        }
        NSMutableSet<SFKovInfo *> *infoSet = [self getSafeInfoSetWithKeyPath:keyPath];
        BOOL isExist = [self checkExistWithKvoInfo:info ininfoSet:infoSet];
        if (isExist) {
            for (SFKovInfo *obj in infoSet) {
                if (obj->_observer == info->_observer && obj->_keyPath == info->_keyPath && obj->_context == info->_context) {
                    [infoSet removeObject:obj];
                    break;
                }
            }
            _kvoInfoMap[keyPath] = infoSet;
            return YES;
        }else{
            return NO;
        }
    }
}

- (NSMutableSet<SFKovInfo *> *)getSafeInfoSetWithKeyPath:(NSString *)keyPath {
    NSMutableSet<SFKovInfo *> *infoSet;
    if ([_kvoInfoMap.allKeys containsObject:keyPath]) {
        infoSet = _kvoInfoMap[keyPath];
    }else{
        infoSet = [NSMutableSet set];
        _kvoInfoMap[keyPath] = infoSet;
    }
    return infoSet;
}

- (BOOL)checkExistWithKvoInfo:(SFKovInfo *)info ininfoSet:(NSMutableSet<SFKovInfo *> *)infoSet {
    @synchronized (self) {
        BOOL contains = NO;
        for (SFKovInfo *obj in infoSet) {
            if (obj->_observer == info->_observer && obj->_keyPath == info->_keyPath && obj->_context == info->_context) {
                contains = YES;
                break;
            }
        }
        return contains;
    }
}

- (NSSet<SFKovInfo *> *)getInfoSetWithObserver:(NSObject *)observer {
    NSMutableSet<SFKovInfo *> *set = [NSMutableSet set];
    for (NSMutableSet<SFKovInfo *> * infoSet in _kvoInfoMap.allValues) {
        for (SFKovInfo *info in infoSet) {
            // ???: 不知道为什么这两个对象地址明明是一样的，为啥就不进if里面
            // 测试发现，这段代码是因为在dealloc里面执行的，判断就会不成功
            // 在一般情况下是正常的
            if (info->_observer == observer) {
                [set addObject:info];
            }
        }
    }
    return set.copy;
}

- (NSSet<SFKovInfo *> *)getAllInfoSet {
    NSArray *values = _kvoInfoMap.allValues;
    NSMutableSet *set = [NSMutableSet set];
    for (NSSet<SFKovInfo *> *infoSet in values) {
        for (SFKovInfo *info in infoSet) {
            [set addObject:info];
        }
    }
    return set;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(nullable void *)context {
    NSObject *observed = (NSObject *)object;
    NSMutableString *msg = [NSMutableString stringWithFormat:@"【KVO】观察者正在dealloc时，移除被观察者：%@ 和当前观察者之间注册的所有KVO\n", observed];
    NSMutableSet<SFKovInfo *> *infoSet = _kvoInfoMap[keyPath];
    NSInteger idx = 0;
    for (SFKovInfo *info in infoSet.copy) {
        if (!info->_observer) {
            idx++;
            [infoSet removeObject:info];
            [observed sf_removeObserver:self forKeyPath:info->_keyPath context:info->_context];
            NSString *str = [NSString stringWithFormat:@" %ld）移除keyPath：%@，context：%@\n", idx, info->_keyPath, info->_context?:NULL];
            [msg appendString:str];
        }
        [SFCrashInspectorManager log:msg];
    }
    _kvoInfoMap[keyPath] = infoSet;
    for (SFKovInfo *info in infoSet) {
        @try {
            [info->_observer observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        } @catch (NSException *exception) {
            NSString *msg = [NSString stringWithFormat:@"【KVO】%@",[exception description]];
            [SFCrashInspectorManager log:msg];
        }
    }
}

@end


#pragma mark - NSObject+KvoCrash
@implementation NSObject (KvoCrash)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        // 交换addObserver:forKeyPath:options:context:方法
        [NSObject sf_swizzlingInstanceMethod:@selector(addObserver:forKeyPath:options:context:) swizzledMethod:@selector(sf_addObserver:forKeyPath:options:context:) withClass:[NSObject class]];

        // 交换removeObserver:forKeyPath:context:方法
        [NSObject sf_swizzlingInstanceMethod:@selector(removeObserver:forKeyPath:context:) swizzledMethod:@selector(sf_removeObserver:forKeyPath:context:) withClass:[NSObject class]];

        /**
         * 由于调用removeObserver:forKeyPath:context:方法时，默认会调用removeObserver:forKeyPath:方法，会导致打印出错。
         * 故在使用移除观察者方法时，推荐使用removeObserver:forKeyPath:context:方法，避免使用removeObserver:forKeyPath:方法。
         */
//        // 交换removeObserver:forKeyPath:方法
//        [NSObject sf_swizzlingInstanceMethod:@selector(removeObserver:forKeyPath:) swizzledMethod:@selector(sf_removeObserver:forKeyPath:) withClass:[NSObject class]];

        // 交换dealloc方法
        [NSObject sf_swizzlingInstanceMethod:NSSelectorFromString(@"dealloc") swizzledMethod:@selector(sf_dealloc) withClass:[NSObject class]];

    });
}

- (void)sf_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(nullable void *)context {
    BOOL isOpen = [SFCrashInspectorManager checkIsOpenWithOption:SFCrashInspectorOptionKVO];
    if (isOpen && !isSystemClass(self.class)) {
        BOOL addInfoSuccess = [self.kvoProxy addKvoInfoToMapsWithObserver:observer forKeyPath:keyPath options:options context:context];
        if (addInfoSuccess) {
            observer.kvoProxy.observed = self;
            observer.kvoTag = SF_VALUE_KVOTAG_OBSERVER;
            self.kvoTag = SF_VALUE_KVOTAG_OBSERVED;
            [self sf_addObserver:self.kvoProxy forKeyPath:keyPath options:options context:context];
            NSLog(@"添加KVO成功!");
        }else{
            // 添加 KVO 信息操作失败：重复添加
            NSString *className = (NSStringFromClass(self.class) == nil) ? @"" : NSStringFromClass(self.class);
            NSString *msg = [NSString stringWithFormat:@"【KVO】Repeated additions to the observer:%@ for the key path:'%@' from %@",
                                observer, keyPath, className];
            [SFCrashInspectorManager log:msg];
        }
        return;
    }
    [self sf_addObserver:observer forKeyPath:keyPath options:options context:context];
}

- (void)sf_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(nullable void *)context {
    BOOL isOpen = [SFCrashInspectorManager checkIsOpenWithOption:SFCrashInspectorOptionKVO];
    if (isOpen && !isSystemClass(self.class)) {
        BOOL removeInfoSuccess = [self.kvoProxy removeKvoInfoToMapsWithObserver:observer forKeyPath:keyPath options:0 context:context];
        if (removeInfoSuccess) {
            [self sf_removeObserver:self.kvoProxy forKeyPath:keyPath context:context];
            NSLog(@"移除KVO成功!");
        }else{
            // 移除 KVO 信息操作失败：移除了一个未注册的观察者
            NSString *className = (NSStringFromClass(self.class) == nil) ? @"" : NSStringFromClass(self.class);
            NSString *msg = [NSString stringWithFormat:@"【KVO】Cannot remove an observer %@ for the key path '%@' from %@ , because it is not registered as an observer",
                                observer, keyPath, className];
            [SFCrashInspectorManager log:msg];
        }
        return;
    }
    [self sf_removeObserver:observer forKeyPath:keyPath context:context];
}

- (void)sf_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath {
    BOOL isOpen = [SFCrashInspectorManager checkIsOpenWithOption:SFCrashInspectorOptionKVO];
    if (isOpen && !isSystemClass(self.class)) {
        BOOL removeInfoSuccess = [self.kvoProxy removeKvoInfoToMapsWithObserver:observer forKeyPath:keyPath options:0 context:NULL];
        if (removeInfoSuccess) {
            [self sf_removeObserver:self.kvoProxy forKeyPath:keyPath context:NULL];
            NSLog(@"移除KVO成功!");
        }else{
            // 移除 KVO 信息操作失败：移除了一个未注册的观察者
            NSString *className = (NSStringFromClass(self.class) == nil) ? @"" : NSStringFromClass(self.class);
            NSString *msg = [NSString stringWithFormat:@"【KVO】Cannot remove an observer %@ for the key path '%@' from %@ , because it is not registered as an observer",
                                observer, keyPath, className];
            [SFCrashInspectorManager log:msg];
        }
        return;
    }
    [self sf_removeObserver:observer forKeyPath:keyPath];
}

- (void)sf_dealloc {
    [self removeUselessKvo];
    [self sf_dealloc];
}

- (void)removeUselessKvo {
    @autoreleasepool {
        BOOL isKvoTag = ([self.kvoTag isEqualToString:SF_VALUE_KVOTAG_OBSERVER] || [self.kvoTag isEqualToString:SF_VALUE_KVOTAG_OBSERVED]);
        if (isKvoTag) {
            BOOL isOpen = [SFCrashInspectorManager checkIsOpenWithOption:SFCrashInspectorOptionKVO];
            if (isOpen && !isSystemClass(self.class)) {
                if ([self.kvoTag isEqualToString:SF_VALUE_KVOTAG_OBSERVER]) {
                    // 当前正在dealloc的是观察者
                    // 由于「不知道为什么这两个对象地址明明是一样的，为啥就不进if里面」的问题（搜索一下就知道了）
                    // 这种情况的解决方案放在了kvoProxy的observeValueForKeyPath:ofObject:change:context:方法中进行处理(推后处理)
                    NSObject *observed = self.kvoProxy.observed;
                    NSObject *observer = self;
                    //SFKvoProxy *kvoProxy = observed.kvoProxy;
                    if (observed) {
                        NSMutableString *msg = [NSMutableString stringWithFormat:@"【KVO】观察者正在dealloc时，移除被观察者：%@ 和当前观察者：%@ 之间注册的所有KVO\n", observed, observer];
//                            NSSet *infoSet = [kvoProxy getInfoSetWithObserver:observer];
//                            for (SFKovInfo *info in infoSet) {
//                                [observed removeObserver:observer forKeyPath:info->_keyPath context:info->_context?:NULL];
//                                NSString *str = [NSString stringWithFormat:@"移除keyPath：%@，context：%@\n", info->_keyPath, info->_context?:NULL];
//                                [msg appendString:str];
//                            }
                        [SFCrashInspectorManager log:msg];
                    }
                }
                else {
                    // 当前正在dealloc的是被观察者
                    NSObject *observed = self;
                    SFKvoProxy *kvoProxy = observed.kvoProxy;
                    NSSet<SFKovInfo *> *infoSet =  [kvoProxy getAllInfoSet];
                    if (infoSet.count > 0) {
                        NSMutableString *msg = [NSMutableString stringWithFormat:@"【KVO】被观察者正在dealloc时，移除被观察者：%@ 和当前观察者之间注册的所有KVO（共%ld个）\n", observed, infoSet.count];
                        NSInteger idx = 0;
                        for (SFKovInfo *info in infoSet) {
                            idx++;
                            [self removeObserver:kvoProxy forKeyPath:info->_keyPath context:info->_context];
                            NSString *str = [NSString stringWithFormat:@" %ld）移除和观察者%@之间的KVO，keyPath：%@，context：%@\n", idx, info->_observer, info->_keyPath, info->_context?:NULL];
                            [msg appendString:str];
                        }
                        [SFCrashInspectorManager log:msg];
                    }
                }
            }
        }
    }
}

#pragma mark - 关联对象
// MARK: 代理
static void *SF_KEY_KVOPROXY = &SF_KEY_KVOPROXY;
- (void)setKvoProxy:(SFKvoProxy *)kvoProxy {
    objc_setAssociatedObject(self, SF_KEY_KVOPROXY, kvoProxy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (SFKvoProxy *)kvoProxy {
    id proxy = objc_getAssociatedObject(self, SF_KEY_KVOPROXY);
    if (proxy == nil) {
        proxy = [[SFKvoProxy alloc] init];
        self.kvoProxy = proxy;
    }
    return proxy;
}

// MARK: 标签
static void *SF_KEY_KVOTAG = &SF_KEY_KVOTAG;
static NSString *const SF_VALUE_KVOTAG_OBSERVER = @"SF_VALUE_KVOTAG_OBSERVER";
static NSString *const SF_VALUE_KVOTAG_OBSERVED = @"SF_VALUE_KVOTAG_OBSERVED";
- (void)setKvoTag:(NSString *)kvoTag {
    objc_setAssociatedObject(self, SF_KEY_KVOTAG, kvoTag, OBJC_ASSOCIATION_COPY);
}
- (NSString *)kvoTag {
    return objc_getAssociatedObject(self, SF_KEY_KVOTAG);
}



@end
