//
//  StackCardCell.h
//  Laboratory-objc
//
//  Created by qeeniao35 on 2019/4/28.
//  Copyright © 2019 CodeZ. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface StackCardCell : UIView

@property (nonatomic, assign) NSInteger index;

@property (nonatomic, retain, readonly) UILabel *label;

/**
 可复用的标志符
 */
@property (nonatomic, copy, readonly) NSString *identifier;

/**
 可复用性标志符

 @return 可复用性标志符
 */
+ (NSString *)reusableIdenfier;

@end

NS_ASSUME_NONNULL_END
