//
//  NSObject+KvoCrash.h
//  TestDemo
//
//  Created by 黄山锋 on 2020/10/19.
//  Copyright © 2020 SFTeam. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (KvoCrash)
- (void)sf_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(nullable void *)context;
@end

NS_ASSUME_NONNULL_END
