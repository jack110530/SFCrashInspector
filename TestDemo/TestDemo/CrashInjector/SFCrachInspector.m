//
//  SFCrachInspector.m
//  TestDemo
//
//  Created by 黄山锋 on 2020/10/19.
//  Copyright © 2020 SFTeam. All rights reserved.
//

#import "SFCrachInspector.h"

@interface SFCrachInspector ()
@property (nonatomic, assign) SFCrashInspectorOption crashOptions;
@end

@implementation SFCrachInspector
// MARK: 单例
static SFCrachInspector *_instance = nil;
+ (instancetype)shareInstance {
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        _instance = [[super allocWithZone:NULL] init] ;
    }) ;
    return _instance ;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    return [SFCrachInspector shareInstance] ;
}

- (id)copyWithZone:(struct _NSZone *)zone {
    return [SFCrachInspector shareInstance] ;
}

// MARK: func
/// 开启崩溃防护
/// @param options 崩溃类型（可多选）
- (void)openCrashInspectorWithOptions:(SFCrashInspectorOption)options {
    self.crashOptions = options;
}

/// 开启所有类型的崩溃防护
- (void)openAllCrashInspector {
    self.crashOptions = SFCrashInspectorOptionSelector | SFCrashInspectorOptionKVC | SFCrashInspectorOptionKVO;
}

/// 关闭指定的崩溃类型
/// @param option 崩溃类型
- (void)closeCrashInspectorWithOption:(SFCrashInspectorOption)option {
    SFCrashInspectorOption options = self.crashOptions;
    if (options & option) {
        self.crashOptions = options ^ option;
    }
}

/// 关闭所有类型的崩溃防护
- (void)closeAllCrashInspector {
    self.crashOptions = 0;
}

/// 检查该类崩溃防护是否开启
/// @param option 崩溃类型
- (BOOL)checkIsOpenWithOption:(SFCrashInspectorOption)option {
    return self.crashOptions & option;
}

/// 崩溃日志打印
/// @param message 日志信息
+ (void)log:(NSString *)message {
    NSString *start = @"\n---------------------- SFCrash Message ----------------------\n";
    NSString *end =   @"\n---------------------------- END ----------------------------\n";
    NSLog(@"%@%@%@",start,message,end);
}

@end
