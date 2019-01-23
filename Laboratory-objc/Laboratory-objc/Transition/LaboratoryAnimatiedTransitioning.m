//
//  LaboratoryAnimatiedTransitioning.m
//  Laboratory-objc
//
//  Created by qeeniao35 on 2019/1/18.
//  Copyright © 2019 CodeZ. All rights reserved.
//

#import "LaboratoryAnimatiedTransitioning.h"

@interface LaboratoryAnimatiedTransitioning()

/**
 保证只在当前的视图控制器中使用，其余地方使用默认的转场动画
 */
@property (nonatomic, assign) BOOL hasUsed;

@end

@implementation LaboratoryAnimatiedTransitioning

- (instancetype)init {
    if (self = [super init]) {
        _animatedDuriation = .382;
    }
    
    return self;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return MAX(0, _animatedDuriation);
}

// 转场动画实现逻辑
- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    // 转场动画发生的容器
    UIView *containerView = transitionContext.containerView;
    // UIView是UIViewController的父容器
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    
//    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
//    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    switch (_animatedType) {
        case LABAnimatedTransitioningTypeFade:
            [self lab_animatedTransitionTypeFade:transitionContext container:containerView fromView:fromView toView:toView];
            break;
        default:
            [self lab_defaultAnimation:transitionContext fromView:fromView toView:toView];
            break;
    }
}

#pragma mark - 动画实现


- (void)lab_animatedTransitionTypeFade:(id<UIViewControllerContextTransitioning>)transitionContext container:(UIView *)container fromView:(UIView *)fromView toView:(UIView *)toView {
//    UIView *snapshotView = [fromView snapshotViewAfterScreenUpdates:NO];
    
    // 一定要把转场后的视图添加到容器当中
    [container addSubview:toView];
//    [container addSubview:snapshotView];
    
    
    // 关键动画实现步骤. e.g 渐变动画
//    fromView.hidden = YES;
//    snapshotView.transform = CGAffineTransformMakeScale(.5, .5);
    toView.alpha = 0;
    NSTimeInterval animatedTime = [self transitionDuration:transitionContext];
    [UIView animateWithDuration:animatedTime animations:^{
        toView.alpha = 1;
//        snapshotView.transform = CGAffineTransformMakeScale(1, 1);
    } completion:^(BOOL finished) {
//        fromView.hidden = NO;
        // 一定要实现，用于有交互式转场时
//        [snapshotView removeFromSuperview];
        
        BOOL canceled = [transitionContext transitionWasCancelled];
        [transitionContext completeTransition:!canceled];
    }];
}

- (void)lab_defaultAnimation:(id<UIViewControllerContextTransitioning>)transitionContext fromView:(UIView *)fromView toView:(UIView *)toView {
    NSTimeInterval animatedTime = [self transitionDuration:transitionContext];
    [UIView transitionFromView:fromView
                        toView:toView
                      duration:animatedTime
                       options: _operation == UINavigationControllerOperationPop ? UIViewAnimationOptionTransitionCurlUp : UIViewAnimationOptionTransitionCurlDown
                    completion:^(BOOL finished) {
                        // 一定要实现，用于有交互式转场时
                        BOOL canceled = [transitionContext transitionWasCancelled];
                        [transitionContext completeTransition:!canceled];
                    }];
}

@end
