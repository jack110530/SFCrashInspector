//
//  NSObject+MethodSwizzling.h
//  TestDemo
//
//  Created by 黄山锋 on 2020/10/14.
//  Copyright © 2020 SFTeam. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (MethodSwizzling)

+ (void)sf_swizzlingClassMethod:(SEL)originalSel swizzledMethod:(SEL)swizzledMethod withClass:(Class)targetClass;
+ (void)sf_swizzlingInstanceMethod:(SEL)originalSel swizzledMethod:(SEL)swizzledMethod withClass:(Class)targetClass;

@end

// 判断是否是系统类
static inline BOOL isSystemClass(Class cls) {
    BOOL isSystem = NO;
    NSString *className = NSStringFromClass(cls);
    if ([className hasPrefix:@"NS"] || [className hasPrefix:@"__NS"] || [className hasPrefix:@"OS_xpc"]) {
        isSystem = YES;
        return isSystem;
    }
    NSBundle *mainBundle = [NSBundle bundleForClass:cls];
    if (mainBundle == [NSBundle mainBundle]) {
        isSystem = NO;
    }else{
        isSystem = YES;
    }
    return isSystem;
}

NS_ASSUME_NONNULL_END
