//
//  BaseTabBarController.m
//  Laboratory-objc
//
//  Created by qeeniao35 on 2019/1/15.
//  Copyright © 2019 CodeZ. All rights reserved.
//

#import "BaseTabBarController.h"
#import "HomeViewController.h"
#import "IMConversationController.h"

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
    LABNavigationController *homeNav = [[LABNavigationController alloc] initWithRootViewController:homeVC];
    UITabBarItem *homeItem = [[UITabBarItem alloc] initWithTitle:@"首页" image:nil selectedImage:nil];
    homeNav.tabBarItem = homeItem;
    
    IMConversationController *conversationVC = [[IMConversationController alloc] init];
    LABNavigationController *conversationNav = [[LABNavigationController alloc] initWithRootViewController:conversationVC];
    self.viewControllers = @[homeNav, conversationNav];
    UITabBarItem *imItem = [[UITabBarItem alloc] init];
    imItem.title = @"IM";
    conversationNav.tabBarItem = imItem;
    
}

@end
