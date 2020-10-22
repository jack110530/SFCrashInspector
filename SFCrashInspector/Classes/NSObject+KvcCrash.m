//
//  NSObject+KvcCrash.m
//  TestDemo
//
//  Created by 黄山锋 on 2020/10/16.
//  Copyright © 2020 SFTeam. All rights reserved.
//

#import "NSObject+KvcCrash.h"
#import "SFCrashInspectorFunc.h"
#import "NSObject+MethodSwizzling.h"
#import "SFCrashInspectorManager.h"

@implementation NSObject (KvcCrash)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 交换setValue:forKey:方法(实例方法和对象方法)
        [NSObject sf_swizzlingInstanceMethod:@selector(setValue:forKey:) swizzledMethod:@selector(sf_setValue:forKey:) withClass:[NSObject class]];
    });
}

- (void)sf_setValue:(id)value forKey:(NSString *)key {
    BOOL isOpen = [SFCrashInspectorManager checkIsOpenWithOption:SFCrashInspectorOptionKVC];
    if (isOpen) {
        if (!key) {
            NSString *msg = [NSString stringWithFormat:@"【KVC】[<%@ %p> setValue:forKey:]: attempt to set a value for a nil key. ",NSStringFromClass([self class]),self];
            [SFCrashInspectorManager log:msg];
            return;
        }
    }
    [self sf_setValue:value forKey:key];
}

- (void)setNilValueForKey:(NSString *)key {
    BOOL isOpen = [SFCrashInspectorManager  checkIsOpenWithOption:SFCrashInspectorOptionKVC];
    if (isOpen) {
        NSString *msg = [NSString stringWithFormat:@"【KVC】[<%@ %p> setNilValueForKey]: could not set nil as the value for the key %@.",NSStringFromClass([self class]),self,key];
        [SFCrashInspectorManager log:msg];
    }
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    BOOL isOpen = [SFCrashInspectorManager checkIsOpenWithOption:SFCrashInspectorOptionKVC];
    if (isOpen) {
        NSString *msg = [NSString stringWithFormat:@"【KVC】[<%@ %p> setValue:forUndefinedKey:]: this class is not key value coding-compliant for the key: %@,value:%@'.",NSStringFromClass([self class]),self,key,value];
        [SFCrashInspectorManager log:msg];
    }
}

- (nullable id)valueForUndefinedKey:(NSString *)key {
    BOOL isOpen = [SFCrashInspectorManager checkIsOpenWithOption:SFCrashInspectorOptionKVC];
    if (isOpen) {
        NSString *msg = [NSString stringWithFormat:@"【KVC】[<%@ %p> valueForUndefinedKey:]: this class is not key value coding-compliant for the key: %@.",NSStringFromClass([self class]),self,key];
        [SFCrashInspectorManager log:msg];
    }
    return self;
}

@end
