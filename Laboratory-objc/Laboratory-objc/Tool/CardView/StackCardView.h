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

/**
 滚动的方向

 - StackScrollDirectionClockwise: 顺时针
 - StackScrollDirectionCounterClockwise: 逆时针
 */
typedef NS_ENUM(NSInteger, StackScrollDirection) {
    StackScrollDirectionClockwise,
    StackScrollDirectionCounterClockwise,
};

@protocol StackCardViewDelegate <NSObject>

/**
 当前卡片视图的数据源，是叠加的，不是覆盖

 @param cardsView 当前的卡片视图
 @return 新增的数据源
 */
- (NSInteger)numberOfCardsDataForCards:(StackCardView *)cardsView;

- (StackCardCell *)stackCardsView:(StackCardView *)cardView cellForCurrentIndex:(NSInteger)index displayIndex:(NSInteger)displayIndex;

@optional
/**
 切换到指定卡片后响应
 
 @param cardsView 卡片视图
 @param index 选中的卡片下标
 */
- (void)stackCardView:(StackCardView *)cardsView didSelectAtIndex:(NSInteger)index;

/**
 一次性显示卡片的个数，默认3个

 @return 卡片个数
 */
- (NSInteger)numberOfDisplayingCards;

/**
 cell之间的偏移量，目前只支持cell之间偏移量固定，默认5
 
 @param cardsView 卡片视图
 @return 偏移量
 */
- (CGFloat)distanceOfCellOffset:(StackCardView *)cardsView;

/**
 最后一个显示的cell视图的缩放程度，缩放程度从1开始往后渐变，默认0.7
 @param cardsView 卡片视图
 @return 缩放程度
 */
- (CGFloat)lastCellScaleForCards:(StackCardView *)cardsView;

/**
 cell到容器的内边距，默认(5, 5, 5, 5)
 
 @param cardsView 卡片视图
 @return 内边距
 */
- (UIEdgeInsets)edgeInsetsForCell:(StackCardView *)cardsView;

@end

/**
 卡片堆叠
 
 note: 关于卡片复用问题，目前只支持单一的卡片复用，多种卡片暂不考虑
 不支持:
    循环滚动；
    滚动到指定卡片位置；
 支持：
    上一页/下一页 (0^0)
 */
@interface StackCardView : UIScrollView

@property (nonatomic, weak) id<StackCardViewDelegate> stackDelegate;

/**
 当前选中的cell
 */
@property (nonatomic, retain) StackCardCell *selectedCell;

/**
 当前需要复用的cell

 @param index cell需要显示的下标
 @param displayIndex 实际显示的位置
 @return 复用的cell
 */
- (StackCardCell *)cellForIndex:(NSInteger)index atDisplayIndex:(NSInteger)displayIndex;

/**
 选中某个卡片视图，有问题

 @param index 选中的卡片视图
 @param animated 是否动画展示
 */
- (void)selectIndex:(NSInteger)index animated:(BOOL)animated;

/**
 重新加载卡片
 */
- (void)reloadCardsView;

/**
 加载下一页
 */
- (void)loadNextCard;

/**
 加载上一页
 */
- (void)loadPreviousCard;

@end

