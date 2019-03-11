//
//  LABPopAnimateTransitioning.m
//  Laboratory-objc
//
//  Created by qeeniao35 on 2019/3/8.
//  Copyright © 2019 CodeZ. All rights reserved.
//

#import "LABPopAnimateTransitioning.h"

@implementation LABPopAnimateTransitioning
- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return .3;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIView * toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    UIView * fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    //这里有个重要的概念containerView，要做转场动画的视图就必须要加入containerView上才能进行，可以理解containerView管理着所有做转场动画的视图
    UIView *containerView = [transitionContext containerView];
    [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
//    if ([transitionContext transitionWasCancelled]) {
//        //如果取消转场
//    }else{
//        //完成转场
//    }];
}

@end
