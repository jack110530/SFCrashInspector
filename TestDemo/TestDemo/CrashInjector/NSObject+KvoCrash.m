//
//  NSObject+KvoCrash.m
//  TestDemo
//
//  Created by 黄山锋 on 2020/10/19.
//  Copyright © 2020 SFTeam. All rights reserved.
//

#import "NSObject+KvoCrash.h"
#import "NSObject+MethodSwizzling.h"
#import "SFCrachInspector.h"
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
                             context:(void *)context;

- (BOOL)removeKvoInfoToMapsWithObserver:(NSObject *)observer
                             forKeyPath:(NSString *)keyPath
                                options:(NSKeyValueObservingOptions)options
                                context:(void *)context;

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
                             context:(void *)context{
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
                                context:(void *)context{
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
    [_kvoInfoMap enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull keyPath, NSMutableSet<SFKovInfo *> * _Nonnull infoSet, BOOL * _Nonnull stop) {
        for (SFKovInfo *info in infoSet) {
            if (info->_observer == observer) {
                [set addObject:info];
            }
        }
    }];
    return set.copy;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    NSMutableSet<SFKovInfo *> *infoSet = _kvoInfoMap[keyPath];
    for (SFKovInfo *info in infoSet.copy) {
        if (!info->_observer) {
            [infoSet removeObject:info];
            NSString *className = (NSStringFromClass([object class]) == nil) ? @"" : NSStringFromClass([object class]);
            NSString *msg = [NSString stringWithFormat:@"【KVO】observer dealloc for the key path:'%@' from %@", keyPath, className];
            [SFCrachInspector log:msg];
        }
    }
    _kvoInfoMap[keyPath] = infoSet;
    for (SFKovInfo *info in infoSet) {
        @try {
            [info->_observer observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        } @catch (NSException *exception) {
            NSString *msg = [NSString stringWithFormat:@"【KVO】%@",[exception description]];
            [SFCrachInspector log:msg];
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

- (void)sf_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context {
    BOOL isOpen = [SFCrachInspector checkIsOpenWithOption:SFCrashInspectorOptionKVO];
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
            [SFCrachInspector log:msg];
        }
        return;
    }
    [self sf_addObserver:observer forKeyPath:keyPath options:options context:context];
}

- (void)sf_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(void *)context {
    BOOL isOpen = [SFCrachInspector checkIsOpenWithOption:SFCrashInspectorOptionKVO];
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
            [SFCrachInspector log:msg];
        }
        return;
    }
    [self sf_removeObserver:observer forKeyPath:keyPath context:context];
}

- (void)sf_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath {
    BOOL isOpen = [SFCrachInspector checkIsOpenWithOption:SFCrashInspectorOptionKVO];
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
            [SFCrachInspector log:msg];
        }
        return;
    }
    [self sf_removeObserver:observer forKeyPath:keyPath];
}

- (void)sf_dealloc {
    @autoreleasepool {
        BOOL isKvoTag = ([self.kvoTag isEqualToString:SF_VALUE_KVOTAG_OBSERVER] || [self.kvoTag isEqualToString:SF_VALUE_KVOTAG_OBSERVED]);
        if (isKvoTag) {
            BOOL isOpen = [SFCrachInspector checkIsOpenWithOption:SFCrashInspectorOptionKVO];
            if (isOpen) {
                if ([self.kvoTag isEqualToString:SF_VALUE_KVOTAG_OBSERVER]) {
                    // 当前正在dealloc的是观察者
                    NSObject *observed = self.kvoProxy.observed;
                    SFKvoProxy *observer = observed.kvoProxy;
                    if (observed) {
                        NSMutableString *msg = [NSMutableString stringWithFormat:@"【KVO】观察者正在dealloc时，移除被观察者：%@ 和当前观察者：%@ 之间注册的所有KVO\n", observed, self];
                        NSSet *infoSet = [observer getInfoSetWithObserver:self];
                        for (SFKovInfo *info in infoSet) {
                            [observed sf_removeObserver:info->_observer forKeyPath:info->_keyPath context:info->_context?:NULL];
                            NSString *str = [NSString stringWithFormat:@"移除keyPath：%@ context：%@\n", info->_keyPath, info->_context?:NULL];
                            [msg appendString:str];
                        }
                        [SFCrachInspector log:msg];
                    }
                }
                else {
                    // 当前正在dealloc的是被观察者
                    
                }
            }
        }
    }
    [self sf_dealloc];
}

// MARK: 关联对象
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
