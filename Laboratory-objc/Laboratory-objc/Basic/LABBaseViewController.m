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
    
    _labNavgationBar = [[LABNavigationBar alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, LABTopHeight)];
    _labNavgationBar.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_labNavgationBar];
    
    Weak(self)
    _labNavgationBar.navigationBarItemBlock = ^(LABNavigationBarItemType type) {
        [weakself lab_navgationBarItemHandler:type];
    };
    
    [self lab_addNotifications];
    
    [self lab_addSubViews];
    
    [self lab_addDataSource];
}


#pragma mark - public methods

- (void)lab_addNotifications{}
- (void)lab_addSubViews{}
- (void)lab_addDataSource{}

- (void)lab_navgationBarItemHandler:(LABNavigationBarItemType)type {
    switch (type) {
        case LABNavigationBarItemTypeBackButton:
            [self lab_popViewController];
            break;
        case LABNavigationBarItemTypeRightButton:
            [self lab_rightBarItemHandler];
            break;
        default:
            break;
    }
}

- (void)lab_popViewController {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)lab_rightBarItemHandler {}


#pragma mark - setter
- (void)setTitle:(NSString *)title {
    [super setTitle:title];
    _labNavgationBar.titleLabel.text = title;
    _labNavgationBar.navgationBar.hidden = YES;
    _labNavgationBar.titleLabel.hidden = NO;
}

@end
