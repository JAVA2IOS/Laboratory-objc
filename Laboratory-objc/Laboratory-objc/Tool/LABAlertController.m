//
//  LABAlertController.m
//  Laboratory-objc
//
//  Created by qeeniao35 on 2019/3/8.
//  Copyright © 2019 CodeZ. All rights reserved.
//

#import "LABAlertController.h"
#import "LABPopAnimateTransitioning.h"

@interface LABAlertController ()<UIViewControllerTransitioningDelegate>
@property (nonatomic, retain) UIControl *maskView;
@property (nonatomic, retain) LABPopAnimateTransitioning *animateTransitioning;
@end

@implementation LABAlertController

- (void)viewDidLoad {
    [super viewDidLoad];
    _animateTransitioning = [[LABPopAnimateTransitioning alloc] init];
    self.transitioningDelegate = self;
    
    
    
    [self.view addSubview:self.maskView];
}


#pragma mark - methods

- (void)doSomething {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark - getter & getter

- (UIControl *)maskView {
    if (!_maskView) {
        _maskView = [[UIControl alloc] initWithFrame:self.view.bounds];
        _maskView.backgroundColor = [UIColor colorWithHexString:@"7f7f7f" withAlpha:.5];
        [_maskView addTarget:self action:@selector(doSomething) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _maskView;
}


#pragma mark - UIViewControllerTransitioningDelegate
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return self.animateTransitioning;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return self.animateTransitioning;
}

@end
