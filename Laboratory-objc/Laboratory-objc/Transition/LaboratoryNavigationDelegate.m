//
//  LaboratoryNavigationDelegate.m
//  Laboratory-objc
//
//  Created by qeeniao35 on 2019/1/23.
//  Copyright © 2019 CodeZ. All rights reserved.
//

#import "LaboratoryNavigationDelegate.h"

@implementation LaboratoryNavigationDelegate

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    return _animatedTransitioning;
}

@end
