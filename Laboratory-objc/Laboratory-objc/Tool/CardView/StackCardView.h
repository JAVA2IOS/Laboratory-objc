//
//  StackCardView.h
//  Laboratory-objc
//
//  Created by qeeniao35 on 2019/4/28.
//  Copyright © 2019 CodeZ. All rights reserved.
//

#import <UIKit/UIKit.h>
@class StackCardView;

@protocol StackCardViewDelegate <NSObject>

/**
 当前卡片视图的数据源，是叠加的，不是覆盖

 @param cardsView 当前的卡片视图
 @return 新增的数据源
 */
- (NSArray *)currentCardsDataForCards:(StackCardView *)cardsView;

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

@end

NS_ASSUME_NONNULL_END
