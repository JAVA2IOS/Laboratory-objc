//
//  LABBaseViewController.m
//  Laboratory-objc
//
//  Created by qeeniao35 on 2019/1/21.
//  Copyright © 2019 CodeZ. All rights reserved.
//

#import "LABBaseViewController.h"

@interface LABBaseViewController ()

@end

@implementation LABBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)setTitle:(NSString *)title {
    [super setTitle:title];
    if ([self.navigationController isKindOfClass:[LABNavigationController class]]) {
        LABNavigationController *navigationVC = (LABNavigationController *)self.navigationController;
        navigationVC.labNavgationBar.titleLabel.text = title;
    }
}

@end
