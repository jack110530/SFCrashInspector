//
//  ViewController.m
//  TestDemo
//
//  Created by 黄山锋 on 2020/9/23.
//  Copyright © 2020 SFTeam. All rights reserved.
//

#import "ViewController.h"
#import "Person.h"

@interface ViewController ()


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    Person *p = [[Person alloc]init];
    [p testInstanceFunc];
    //[Person testClassFunc];
    
}

@end
