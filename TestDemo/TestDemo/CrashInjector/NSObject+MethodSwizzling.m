//
//  NSObject+MethodSwizzling.m
//  TestDemo
//
//  Created by 黄山锋 on 2020/10/14.
//  Copyright © 2020 SFTeam. All rights reserved.
//

#import "NSObject+MethodSwizzling.h"
#import <objc/runtime.h>

@implementation NSObject (MethodSwizzling)

+ (void)sf_swizzlingClassMethod:(SEL)originalSel swizzledMethod:(SEL)swizzledMethod withClass:(Class)targetClass {
    swizzlingMethod(targetClass, YES, originalSel, swizzledMethod);
}
+ (void)sf_swizzlingInstanceMethod:(SEL)originalSel swizzledMethod:(SEL)swizzledMethod withClass:(Class)targetClass {
    swizzlingMethod(targetClass, NO, originalSel, swizzledMethod);
}

/// 交换类方法
/// @param class 类/元类
/// @param originalSel 原方法
/// @param swizzledSel 交换方法
void swizzlingMethod(Class class, BOOL isMetaClass, SEL originalSel, SEL swizzledSel) {
    Method originalMethod;
    Method swizzledMethod;
    if (isMetaClass) {
        originalMethod = class_getClassMethod(class, originalSel);
        swizzledMethod = class_getClassMethod(class, swizzledSel);
    }else{
        originalMethod = class_getInstanceMethod(class, originalSel);
        swizzledMethod = class_getInstanceMethod(class, swizzledSel);
    }
    if (!originalMethod || !swizzledMethod) {
        NSLog(@"【Class】：%@中，方法交换失败 \n【originalSel】：%@ \n【swizzledSel】：%@ \n", class, NSStringFromSelector(originalSel), NSStringFromSelector(swizzledSel));
        return;
    }
    if (isMetaClass) {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }else{
        BOOL didAddMethod = class_addMethod(class,
                                             originalSel,
                                             method_getImplementation(swizzledMethod),
                                             method_getTypeEncoding(swizzledMethod));
        if (didAddMethod) {
            class_replaceMethod(class,
                                swizzledSel,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod));
        }else{
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    }
}

@end
