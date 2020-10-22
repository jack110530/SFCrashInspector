//
//  Person.h
//  TestDemo
//
//  Created by 黄山锋 on 2020/10/14.
//  Copyright © 2020 SFTeam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Animal.h"

NS_ASSUME_NONNULL_BEGIN

@interface Person : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) Animal *dog;
@property (nonatomic, assign) int age;

- (void)testInstanceFunc;
+ (void)testClassFunc;

@end

NS_ASSUME_NONNULL_END
