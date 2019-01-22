//
//  LaboratoryAnimatiedTransitioning.h
//  Laboratory-objc
//
//  Created by qeeniao35 on 2019/1/18.
//  Copyright © 2019 CodeZ. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, LABAnimatedTransitioningType) {
    LABAnimatedTransitioningTypeDefault,
    LABAnimatedTransitioningTypeFade,
    LABAnimatedTransitioningTypePush,
    LABAnimatedTransitioningTypePop,
};

@interface LaboratoryAnimatiedTransitioning : NSObject<UIViewControllerAnimatedTransitioning>
/**
 动画时间
 */
@property (nonatomic, assign) NSTimeInterval animatedDuriation;
/**
 动画效果
 */
@property (nonatomic, assign) LABAnimatedTransitioningType animatedType;

@property (nonatomic, assign) UINavigationControllerOperation operation;

@end
