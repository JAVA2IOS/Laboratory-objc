//
//  BaseTabBarController.m
//  Laboratory-objc
//
//  Created by qeeniao35 on 2019/1/15.
//  Copyright © 2019 CodeZ. All rights reserved.
//

#import "BaseTabBarController.h"
#import "HomeViewController.h"
#import "IMTestController.h"

@interface BaseTabBarController ()<UITabBarControllerDelegate>

@end

@implementation BaseTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self configureTabbarController];
    self.delegate = self;
}

#pragma mark - Navigation
- (void)configureTabbarController {
    HomeViewController *homeVC = [[HomeViewController alloc] init];
    homeVC.title = @"主页";
    LABNavigationController *nav = [[LABNavigationController alloc] initWithRootViewController:homeVC];
    
    IMTestController *territoryVC = [[IMTestController alloc] init];
    territoryVC.title = @"未知";
    LABNavigationController *territoryNav = [[LABNavigationController alloc] initWithRootViewController:territoryVC];
    self.viewControllers = @[nav, territoryNav];
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    if ([viewController isKindOfClass:[IMTestController class]]) {
//        [IMSocket connect];
    }
}

@end
