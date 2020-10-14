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

NS_ASSUME_NONNULL_END
