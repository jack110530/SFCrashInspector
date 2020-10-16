//
//  NSObject+CrashMessageLog.m
//  TestDemo
//
//  Created by 黄山锋 on 2020/10/16.
//  Copyright © 2020 SFTeam. All rights reserved.
//

#import "NSObject+CrashMessageLog.h"

@implementation NSObject (CrashMessageLog)

+ (void)logCrashMessage:(NSString *)message {
    NSString *start = @"\n---------------------- SFCrash Message ----------------------\n";
    NSString *end =   @"\n---------------------------- END ----------------------------\n";
    NSLog(@"%@%@%@",start,message,end);
}

@end
