//
//  SFCrashInspectorManager.h
//  TestDemo
//
//  Created by 黄山锋 on 2020/10/22.
//  Copyright © 2020 SFTeam. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSUInteger, SFCrashInspectorOption) {
    SFCrashInspectorOptionSelector       = 1 <<  0,
    SFCrashInspectorOptionKVC            = 1 <<  1,
    SFCrashInspectorOptionKVO            = 1 <<  2,
    SFCrashInspectorOptionTimer          = 1 <<  3,
};

@interface SFCrashInspectorManager : NSObject
/// 是否仅在Release模式下开启crash防护，默认Release和Debug模式都开启
@property (nonatomic, assign) BOOL onlyRelease;

#pragma mark - 单例
+ (instancetype)shareInstance;

#pragma mark - func
/// 开启崩溃防护
/// @param options 崩溃类型（可多选）
+ (void)openCrashInspectorWithOptions:(SFCrashInspectorOption)options;

/// 开启所有类型的崩溃防护
+ (void)openAllCrashInspector;

/// 关闭指定的崩溃类型
/// @param option 崩溃类型
+ (void)closeCrashInspectorWithOption:(SFCrashInspectorOption)option;

/// 关闭所有类型的崩溃防护
+ (void)closeAllCrashInspector;

/// 检查该类崩溃防护是否开启
/// @param option 崩溃类型
+ (BOOL)checkIsOpenWithOption:(SFCrashInspectorOption)option;

/// 崩溃日志打印
/// @param message 日志信息
+ (void)log:(NSString *)message;

@end

NS_ASSUME_NONNULL_END
