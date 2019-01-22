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

@interface TransitionViewController ()

@end

@implementation TransitionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"转场动画";
    LaboratoryAnimatiedTransitioning *laboratoryAnimated = [[LaboratoryAnimatiedTransitioning alloc] init];
    laboratoryAnimated.animatedType = LABAnimatedTransitioningTypeFade;
    self.navigationController.delegate = laboratoryAnimated;
    self.view.backgroundColor = [UIColor whiteColor];
    UIButton *button = [UIButton lab_initButton:CGRectMake(30, LABTopHeight + 100, SCREENWIDTH - 30 * 2, 40) title:@"跳转" font:[UIFont systemFontOfSize:14] titleColor:[UIColor whiteColor] backgroundColor:[UIColor redColor]];
    [button buttonClick:self selector:@selector(fadeViewControllerHandler)];
    [self.view addSubview:button];
}


- (void)fadeViewControllerHandler {
    [self lab_pushChildViewController:[FadeViewController class]];
}

@end
