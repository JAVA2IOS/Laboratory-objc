//
//  LABNavigationController.m
//  Laboratory-objc
//
//  Created by qeeniao35 on 2019/1/21.
//  Copyright © 2019 CodeZ. All rights reserved.
//

#import "LABNavigationController.h"

@interface LABNavigationController ()

@end

@implementation LABNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigationBarHidden:YES animated:NO];
    _labNavgationBar = [[LABNavigationBar alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, LABTopHeight)];
    _labNavgationBar.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_labNavgationBar];
}


#pragma mark - override
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.viewControllers.count > 0) {
        viewController.hidesBottomBarWhenPushed = YES;
    }
    [super pushViewController:viewController animated:animated];
}

@end
