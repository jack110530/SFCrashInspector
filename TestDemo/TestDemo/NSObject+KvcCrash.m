//
//  NSObject+KvcCrash.m
//  TestDemo
//
//  Created by 黄山锋 on 2020/10/16.
//  Copyright © 2020 SFTeam. All rights reserved.
//

#import "NSObject+KvcCrash.h"
#import "NSObject+MethodSwizzling.h"

@implementation NSObject (KvcCrash)

+ (void)load {
#if DEBUG
        
#else
    
#endif
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 交换setValue:forKey:方法(实例方法和对象方法)
        [NSObject sf_swizzlingInstanceMethod:@selector(setValue:forKey:) swizzledMethod:@selector(sf_setValue:forKey:) withClass:[NSObject class]];
    });
}

- (void)sf_setValue:(id)value forKey:(NSString *)key {
    if (!key) {
        NSString *crashMessages = [NSString stringWithFormat:@"*** Crash Message: [<%@ %p> setValue:forKey:]: attempt to set a value for a nil key. ***",NSStringFromClass([self class]),self];
        NSLog(@"%@", crashMessages);
        return;
    }
    [self sf_setValue:value forKey:key];
}

- (void)setNilValueForKey:(NSString *)key {
    NSString *crashMessages = [NSString stringWithFormat:@"*** Crash Message: [<%@ %p> setNilValueForKey]: could not set nil as the value for the key %@. ***",NSStringFromClass([self class]),self,key];
    NSLog(@"%@", crashMessages);
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    NSString *crashMessages = [NSString stringWithFormat:@"*** Crash Message: [<%@ %p> setValue:forUndefinedKey:]: this class is not key value coding-compliant for the key: %@,value:%@'. ***",NSStringFromClass([self class]),self,key,value];
    NSLog(@"%@", crashMessages);
}

- (nullable id)valueForUndefinedKey:(NSString *)key {
    NSString *crashMessages = [NSString stringWithFormat:@"*** Crash Message: [<%@ %p> valueForUndefinedKey:]: this class is not key value coding-compliant for the key: %@. ***",NSStringFromClass([self class]),self,key];
    NSLog(@"%@", crashMessages);
    
    return self;
}

@end
