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

/**
 复用标志符
 */
@property (nonatomic, copy, readonly) NSString *identifier;

@property (nonatomic, assign, readonly) NSInteger index;

- (instancetype)initWithIndex:(NSInteger)index reusableIdentifier:(NSString *)reusableIdentifier;

@end

NS_ASSUME_NONNULL_END
