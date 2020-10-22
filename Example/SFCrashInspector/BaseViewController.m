//
//  BaseViewController.m
//  TestDemo
//
//  Created by 黄山锋 on 2020/10/16.
//  Copyright © 2020 SFTeam. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)addBtnsWithTitles:(NSArray *)titles {
    CGFloat x = 10;
    CGFloat y = 10;
    CGFloat w = self.view.frame.size.width - 20;
    CGFloat h = 40;
    for (int i = 0; i < titles.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        y = (h+10)*i+100;
        btn.frame = CGRectMake(x, y, w, h);
        btn.backgroundColor = [UIColor grayColor];
        [btn setTitle:titles[i] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont boldSystemFontOfSize:17];
        btn.tag = i;
        [btn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
    }
}
- (void)clickBtn:(UIButton *)sender {
    NSString *selectorStr = [NSString stringWithFormat:@"test%ld",sender.tag];
    SEL selector = NSSelectorFromString(selectorStr);
    if ([self respondsToSelector:selector]) {
        [self performSelector:selector];
    }
}

@end
