//
//  NSObject+SelectorCrash.m
//  TestDemo
//
//  Created by 黄山锋 on 2020/10/16.
//  Copyright © 2020 SFTeam. All rights reserved.
//

#import "NSObject+SelectorCrash.h"
#import "SFCrashInspectorFunc.h"
#import "NSObject+MethodSwizzling.h"
#import "SFCrashInspectorManager.h"
#import <objc/runtime.h>

@implementation NSObject (SelectorCrash)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 交换forwardingTargetForSelector:方法(实例方法和对象方法)
        [NSObject sf_swizzlingInstanceMethod:@selector(forwardingTargetForSelector:) swizzledMethod:@selector(sf_forwardingTargetForSelector:) withClass:[NSObject class]];
        [NSObject sf_swizzlingClassMethod:@selector(forwardingTargetForSelector:) swizzledMethod:@selector(sf_forwardingTargetForSelector:) withClass:[NSObject class]];
    });
}

- (id)sf_forwardingTargetForSelector:(SEL)aSelector {
    BOOL isOpen = [SFCrashInspectorManager checkIsOpenWithOption:SFCrashInspectorOptionSelector];
    if (isOpen) {
        // 1，判断当前类有没有重写forwardingTargetForSelector:方法
        SEL forwarding_sel = @selector(forwardingTargetForSelector:);
        BOOL override_forwarding = checkMethodOverride([self class], NO, forwarding_sel);
        if (!override_forwarding) {
            // 没有重写「备用接受者」
            // 2，判断当前类有没有重写methodSignatureForSelector:方法
            SEL methodSignature_sel = @selector(methodSignatureForSelector:);
            BOOL override_methodSignature = checkMethodOverride([self class], NO, methodSignature_sel);
            if (!override_methodSignature) {
                // 没有重写「方法签名」
                // 3，把消息转发到当前动态生成类的实例对象上
                NSString *className = @"SFCrashInspectorManager";
                Class cls = NSClassFromString(className);
                // 如果类不存在 动态创建一个类
                if (!cls) {
                    Class superClsss = [NSObject class];
                    cls = objc_allocateClassPair(superClsss, className.UTF8String, 0);
                    // 注册类
                    objc_registerClassPair(cls);
                }
                // 如果类没有对应的方法，则动态添加一个
                if (!class_getInstanceMethod(NSClassFromString(className), aSelector)) {
                    class_addMethod(cls, aSelector, (IMP)crash, "@@:@");
                }
                // 打印日志
                printCrachMessage(self, NO, aSelector);
                return [[cls alloc] init];
            }
        }
    }
    return [self sf_forwardingTargetForSelector:aSelector];
}
+ (id)sf_forwardingTargetForSelector:(SEL)aSelector {
    BOOL isOpen = [SFCrashInspectorManager checkIsOpenWithOption:SFCrashInspectorOptionSelector];
    if (isOpen) {
        // 1，判断当前类有没有重写forwardingTargetForSelector:方法
        SEL forwarding_sel = @selector(forwardingTargetForSelector:);
        BOOL override_forwarding = checkMethodOverride([self class], YES, forwarding_sel);
        if (!override_forwarding) {
            // 没有重写「备用接受者」
            // 2，判断当前类有没有重写methodSignatureForSelector:方法
            SEL methodSignature_sel = @selector(methodSignatureForSelector:);
            BOOL override_methodSignature = checkMethodOverride([self class], YES, methodSignature_sel);
            if (!override_methodSignature) {
                // 没有重写「方法签名」
                // 3，把消息转发到当前动态生成类的实例对象上
                NSString *className = @"SFCrashInspectorManager";
                Class cls = NSClassFromString(className);
                // 如果类不存在 动态创建一个类
                if (!cls) {
                    Class superClsss = [NSObject class];
                    cls = objc_allocateClassPair(superClsss, className.UTF8String, 0);
                    // 注册类
                    objc_registerClassPair(cls);
                }
                // 如果类没有对应的方法，则动态添加一个
                if (!class_getInstanceMethod(NSClassFromString(className), aSelector)) {
                    class_addMethod(cls, aSelector, (IMP)crash, "@@:@");
                }
                // 打印日志
                printCrachMessage(self, YES, aSelector);
                return [[cls alloc] init];
            }
        }
    }
    return [self sf_forwardingTargetForSelector:aSelector];
}


/// 判断方法是否重写过
/// @param class 类
/// @param isMetaClass 是否元类
/// @param aSelector 方法
BOOL checkMethodOverride(Class class, BOOL isMetaClass, SEL aSelector) {
    Method root_method;
    Method current_method;
    if (isMetaClass) {
        root_method = class_getClassMethod([NSObject class], aSelector);
        current_method = class_getClassMethod(class, aSelector);
    }else{
        root_method = class_getInstanceMethod([NSObject class], aSelector);
        current_method = class_getInstanceMethod(class, aSelector);
    }
    IMP root_imp = method_getImplementation(root_method);
    IMP current_imp = method_getImplementation(current_method);
    return root_imp != current_imp;
}

// 动态添加的方法实现
static int crash(id slf, SEL selector) {
    return 0;
}

/// 打印Crash日志
/// @param obj 对象（实例对象/类对象）
/// @param isMetaClass 是否元类
/// @param aSelector 方法
void printCrachMessage(id obj, BOOL isMetaClass, SEL aSelector) {
    NSString *errClassName = NSStringFromClass([obj class]);
    NSString *errSel = NSStringFromSelector(aSelector);
    NSString *msg = [NSString stringWithFormat:@"【Selector】%@[%@ %@]: unrecognized selector sent to %@ %p.",isMetaClass?@"+":@"-", errClassName, errSel, isMetaClass?@"class":@"instance", obj];
    [SFCrashInspectorManager log:msg];
}


@end
