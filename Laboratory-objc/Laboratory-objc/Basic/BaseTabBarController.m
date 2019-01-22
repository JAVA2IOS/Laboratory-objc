//
//  BaseTabBarController.m
//  Laboratory-objc
//
//  Created by qeeniao35 on 2019/1/15.
//  Copyright © 2019 CodeZ. All rights reserved.
//

#import "BaseTabBarController.h"
#import "HomeViewController.h"

@interface BaseTabBarController ()

@end

@implementation BaseTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self configureTabbarController];
}

#pragma mark - Navigation
- (void)configureTabbarController {
    HomeViewController *homeVC = [[HomeViewController alloc] init];
    homeVC.title = @"主页";
    LABNavigationController *nav = [[LABNavigationController alloc] initWithRootViewController:homeVC];
    self.viewControllers = @[nav];
}

@end
