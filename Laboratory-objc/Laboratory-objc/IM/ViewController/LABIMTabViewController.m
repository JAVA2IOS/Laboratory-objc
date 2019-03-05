//
//  LABIMTabViewController.m
//  Laboratory-objc
//
//  Created by qeeniao35 on 2019/3/5.
//  Copyright © 2019 CodeZ. All rights reserved.
//

#import "LABIMTabViewController.h"
#import "IMConversationController.h"

@interface LABIMTabViewController ()

@end

@implementation LABIMTabViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    IMConversationController *conversationController = [[IMConversationController alloc] init];
    LABNavigationController *conversationNav = [[LABNavigationController alloc] initWithRootViewController:conversationController];
    conversationNav.title = @"会话";
    
    self.viewControllers = @[conversationNav];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
