//
//  TransitionViewController.m
//  Laboratory-objc
//
//  Created by qeeniao35 on 2019/1/18.
//  Copyright © 2019 CodeZ. All rights reserved.
//

#import "TransitionViewController.h"
#import "FadeViewController.h"

#import "LaboratoryAnimatiedTransitioning.h"

@interface TransitionViewController ()<UINavigationControllerDelegate>

@end

@implementation TransitionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.delegate = self;
    self.title = @"转场动画";
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)lab_addSubViews {
    UIButton *button = [UIButton lab_initButton:CGRectMake(30, LABTopHeight + 100, SCREENWIDTH - 30 * 2, 40) title:@"跳转" font:[UIFont systemFontOfSize:14] titleColor:[UIColor whiteColor] backgroundColor:[UIColor redColor]];
    [button buttonClick:self selector:@selector(fadeViewControllerHandler)];
    [self.view addSubview:button];
}


- (void)fadeViewControllerHandler {
    [self lab_pushChildViewController:[FadeViewController class]];
}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    LaboratoryAnimatiedTransitioning *animatedTransitioning = [[LaboratoryAnimatiedTransitioning alloc] init];
    animatedTransitioning.animatedType = LABAnimatedTransitioningTypeFade;
    animatedTransitioning.operation = operation;
    
    return animatedTransitioning;
}

- (void)dealloc {
    self.navigationController.delegate = nil;
}

@end
