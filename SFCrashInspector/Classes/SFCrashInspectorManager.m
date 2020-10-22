//
//  SFCrashInspectorManager.m
//  TestDemo
//
//  Created by 黄山锋 on 2020/10/22.
//  Copyright © 2020 SFTeam. All rights reserved.
//

#import "SFCrashInspectorManager.h"

@interface SFCrashInspectorManager ()
@property (nonatomic, assign) SFCrashInspectorOption crashOptions;
@end

@implementation SFCrashInspectorManager
#pragma mark - 单例
static SFCrashInspectorManager *_instance = nil;
+ (instancetype)shareInstance {
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        _instance = [[super allocWithZone:NULL] init] ;
    }) ;
    return _instance ;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    return [SFCrashInspectorManager shareInstance] ;
}

- (id)copyWithZone:(struct _NSZone *)zone {
    return [SFCrashInspectorManager shareInstance] ;
}

#pragma mark - func
/// 开启崩溃防护
/// @param options 崩溃类型（可多选）
+ (void)openCrashInspectorWithOptions:(SFCrashInspectorOption)options {
    [SFCrashInspectorManager shareInstance].crashOptions = options;
}

/// 开启所有类型的崩溃防护
+ (void)openAllCrashInspector {
    [SFCrashInspectorManager shareInstance].crashOptions = SFCrashInspectorOptionSelector | SFCrashInspectorOptionKVC | SFCrashInspectorOptionKVO | SFCrashInspectorOptionTimer;
}

/// 关闭指定的崩溃类型
/// @param option 崩溃类型
+ (void)closeCrashInspectorWithOption:(SFCrashInspectorOption)option {
    SFCrashInspectorOption options = [SFCrashInspectorManager shareInstance].crashOptions;
    if (options & option) {
        [SFCrashInspectorManager shareInstance].crashOptions = options ^ option;
    }
}

/// 关闭所有类型的崩溃防护
+ (void)closeAllCrashInspector {
    [SFCrashInspectorManager shareInstance].crashOptions = 0;
}

/// 检查该类崩溃防护是否开启
/// @param option 崩溃类型
+ (BOOL)checkIsOpenWithOption:(SFCrashInspectorOption)option {
    BOOL isOpen = [SFCrashInspectorManager shareInstance].crashOptions & option;
    if ([SFCrashInspectorManager shareInstance].onlyRelease) {
#ifdef DEBUG
        isOpen = NO;
#else
        
#endif
    }
    return isOpen;
}

/// 崩溃日志打印
/// @param message 日志信息
+ (void)log:(NSString *)message {
    NSString *start = @"\n---------------------- SFCrash Message ----------------------\n";
    NSString *end =   @"\n---------------------------- END ----------------------------\n";
    NSLog(@"%@%@%@",start,message,end);
}
@end
