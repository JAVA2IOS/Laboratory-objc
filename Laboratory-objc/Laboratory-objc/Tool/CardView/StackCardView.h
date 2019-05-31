//
//  StackCardView.h
//  Laboratory-objc
//
//  Created by qeeniao35 on 2019/4/28.
//  Copyright © 2019 CodeZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StackCardCell.h"
@class StackCardView;

@protocol StackCardViewDelegate <NSObject>

/**
 当前卡片视图的数据源，是叠加的，不是覆盖

 @param cardsView 当前的卡片视图
 @return 新增的数据源
 */
- (NSInteger)numberOfCardsDataForCards:(StackCardView *)cardsView;

- (StackCardCell *)stackCardsView:(StackCardView *)cardView cellForCurrentIndex:(NSInteger)index;

@optional
/**
 一次性显示卡片的个数，默认3个

 @return 卡片个数
 */
- (NSInteger)numberOfDisplayingCards;

@end

NS_ASSUME_NONNULL_BEGIN

/**
 卡片堆叠
 */
@interface StackCardView : UIScrollView
@property (nonatomic, weak) id<StackCardViewDelegate> stackDelegate;


/**
 当前需要复用的cell

 @param index cell需要显示的下标
 @param reusableIdentifier 复用标志符
 @return 复用的cell
 */
- (StackCardCell *)cellForIndex:(NSInteger)index reusableIdentifier:(NSString *)reusableIdentifier;

- (void)selectIndex:(NSInteger)index animated:(BOOL)animated;

- (void)reloadCardsView;

@end

NS_ASSUME_NONNULL_END
