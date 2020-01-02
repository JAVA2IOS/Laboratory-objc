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

 - StackScrollDirectionClockwise: 顺时针，上一页
 - StackScrollDirectionCounterClockwise: 逆时针，下一页
 */
typedef NS_ENUM(NSInteger, StackScrollDirection) {
    StackScrollDirectionClockwise,  /// 顺时针，上一页
    StackScrollDirectionCounterClockwise,   /// 逆时针，下一页
};

typedef NS_ENUM(NSInteger, StackCardLoadStatus) {
    /// 目前暂无滑动以及点击状态
    StackCardLoadStatusNone,
//    StackCardLoadStatusPanGesture,  /// 滑动手势触发状态
    /// 调用下一卡片状态
    StackCardLoadStatusNextCard,
    /// 调用上一卡片状态
    StackCardLoadStatusPreviousCard,
};

@protocol StackCardViewDelegate <NSObject>

- (NSInteger)stackCardView:(StackCardView *)cardsView numberOfItemsInSection:(NSInteger)section;

- (__kindof StackCardCell *)stackCardsView:(StackCardView *)cardView cellForCurrentIndexPath:(NSIndexPath *)indexPath;

@optional

- (NSInteger)numberOfSectionsInStackCard:(StackCardView *)cardsView;

/// 手势或者切换卡片是否禁用
/// @param cardsView 卡片列表视图
/// @param cell 当前的选中的卡片
/// @param indexPath 当前选中的卡片的坐标
/// @param direction 滑动的方向
- (BOOL)stackCardView:(StackCardView *)cardsView shouldSwipeCell:(__kindof StackCardCell *)cell atIndexPath:(NSIndexPath *)indexPath direction:(StackScrollDirection)direction;

/// 使用手势切换时响应当前方法，可用于分页加载
/// @param cardsView 卡片列表视图
/// @param cell 当前选中的卡片
/// @param indexPath 当前选中卡片的坐标
/// @param direction 滑动方向
- (void)stackCardView:(StackCardView *)cardsView didSwitchedUsedPangestureCell:(__kindof StackCardCell *)cell atIndexPath:(NSIndexPath *)indexPath direction:(StackScrollDirection)direction;

/// 选中卡片后响应(未使用)
/// @param cardsView 卡片列表视图
/// @param indexPath 选中的卡片坐标
- (void)stackCardView:(StackCardView *)cardsView didSelectAtIndexPath:(NSIndexPath *)indexPath;

/**
 一次性显示卡片的个数，默认3

 @return 卡片个数
 */
- (NSInteger)numberOfDisplayingCards;

/**
 cell之间的偏移量，目前只支持cell之间偏移量固定，默认5
 
 @param cardsView 卡片视图
 @return 偏移量
 */
- (CGFloat)distanceOfPerCellOffset:(StackCardView *)cardsView;

/**
 最后一个显示的cell视图的缩放程度，缩放程度从1开始往后渐变，默认0.7
 @param cardsView 卡片视图
 @return 缩放程度
 */
- (CGFloat)lastCellScaleForCards:(StackCardView *)cardsView;

/**
 cell到容器的内边距padding，默认(5, 5, 5, 5)
 
 @param cardsView 卡片视图
 @return 内边距
 */
- (UIEdgeInsets)edgeInsetsForCell:(StackCardView *)cardsView;

@end


/// 卡片样式选择
@interface StackCardConfigure : NSObject
@property (nonatomic, copy, readonly) NSString *version;
/// 卡片的滑动动画持续时间，默认.15s
@property (nonatomic, assign) NSTimeInterval animatedDuration;
/// 是否使用滑动手势，默认YES
@property (nonatomic, assign) BOOL panGestureEnable;

/// 判断滑动是否成功的距离，默认 stackcard.width / 3
@property (nonatomic, assign) CGFloat panLimitedDistance;

/// 默认滑动到最左边消失的最小卡片中点x坐标，默认 -20
@property (nonatomic, assign) CGFloat panMinimunCardCenterX;

/// 数据是否为空
@property (nonatomic, assign, readonly) BOOL empty;

@end


/**
 卡片堆叠
 不支持:
    循环滚动；
    滚动到指定卡片位置；
    每个卡片frame动态改变
 支持：
    上一页/下一页 (0^0)
 */
@interface StackCardView : UIView

@property (nonatomic, weak) id<StackCardViewDelegate> stackDelegate;

@property (nonatomic, retain) StackCardCell *selectedCell;
/// 调用状态
@property (nonatomic, assign, readonly) StackCardLoadStatus status;
/**
 配置
 */
@property (nonatomic, retain, readonly) StackCardConfigure *configure;
/**
 加载下一页
 */
- (void)loadNextCard;

/**
 加载上一页
 */
- (void)loadPreviousCard;

/**
 收起卡片

 @param animated 动画效果
 */
- (void)shrinkCards:(BOOL)animated;

/// 注册复用cell的标志符
/// @param stackCellClass 复用的cell类
/// @param reusableIdentifier 复用的标志符
- (void)registerClass:(Class)stackCellClass reusableIdentifer:(NSString *)reusableIdentifier;

/// 复用cell
/// @param reusableIdentifier 复用的标识
/// @param indexPath 当前的坐标
- (__kindof StackCardCell *)dequeueReusableIdentifier:(NSString *)reusableIdentifier indexPath:(NSIndexPath *)indexPath;

- (void)reloadData;

/**
 选中某个卡片视图
 
 @param indexPath 指定选中的坐标
 @param animated 是否动画展示
 */
- (void)selectIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated;

/// 滚动到最后一张卡片
- (void)scrollToLastIndexPath;

/// 移除指定某几个数据(未实现方法)
/// @param indexPaths 指定移除的数据坐标
- (void)removeIndexPaths:(NSArray<NSIndexPath *> *)indexPaths;

/// 移除某一个section的所有数据(需要排除每个section的rows = 0的情况)
/// @param section 待移除的section的数据
- (void)removeItemsInSection:(NSInteger)section;

@end

