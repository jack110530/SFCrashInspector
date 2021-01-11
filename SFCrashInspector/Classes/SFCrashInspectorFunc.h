//
//  SFCrashInspectorFunc.h
//  TestDemo
//
//  Created by 黄山锋 on 2020/10/22.
//  Copyright © 2020 SFTeam. All rights reserved.
//

#ifndef SFCrashInspectorFunc_h
#define SFCrashInspectorFunc_h

/**
 * 【忽略警告】
 * 未使用变量警告：-Wunused-variable
 * 方法弃用警告：-Wdeprecated-declarations
 * 循环引用警告：-Warc-retain-cycles
 * 不兼容指针类型警告：-Wincompatible-pointer-types
 * 内存泄漏警告：-Warc-performSelector-leaks
 */
#define SFIgnoreWarningPerformSelectorLeak(Stuff)\
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)


// 判断是否是系统类
static inline BOOL isSystemClass(Class cls) {
    BOOL isSystem = NO;
    NSString *className = NSStringFromClass(cls);
    if ([className hasPrefix:@"NS"] || [className hasPrefix:@"__NS"] || [className hasPrefix:@"OS_xpc"]) {
        isSystem = YES;
        return isSystem;
    }
    NSBundle *systemBundle = [NSBundle bundleForClass:[UIView class]];
    NSBundle *customBundle = [NSBundle bundleForClass:cls];
    if (customBundle == systemBundle) {
        isSystem = YES;
    }else{
        isSystem = NO;
    }
    return isSystem;
}



#endif /* SFCrashInspectorFunc_h */
