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

@property (nonatomic, retain) NSIndexPath *indexPath;

@property (nonatomic, retain, readonly) UIView *contentView;

/**
 可复用的标志符
 */
@property (nonatomic, copy, readonly) NSString *identifier;

+ (instancetype)initWithIdentifer:(NSString *)idenfitier atIndexPath:(NSIndexPath *)indexPath frame:(CGRect)frame;

+ (NSString *)reusableIdentifier;

@end

NS_ASSUME_NONNULL_END
