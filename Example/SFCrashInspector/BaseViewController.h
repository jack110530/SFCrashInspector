//
//  BaseViewController.h
//  TestDemo
//
//  Created by 黄山锋 on 2020/10/16.
//  Copyright © 2020 SFTeam. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BaseViewController : UIViewController

- (void)addBtnsWithTitles:(NSArray *)titles;
- (void)clickBtn:(UIButton *)sender;

@end

NS_ASSUME_NONNULL_END
