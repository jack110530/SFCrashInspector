//
//  NSObject+CrashMessageLog.h
//  TestDemo
//
//  Created by 黄山锋 on 2020/10/16.
//  Copyright © 2020 SFTeam. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (CrashMessageLog)
+ (void)logCrashMessage:(NSString *)message;
@end

NS_ASSUME_NONNULL_END
