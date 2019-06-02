//
//  StackCardView.m
//  Laboratory-objc
//
//  Created by qeeniao35 on 2019/4/28.
//  Copyright © 2019 CodeZ. All rights reserved.
//

#import "StackCardView.h"

@interface StackCardView()
/**
 卡片视图的缓存池，用来复用，显示的时候取出来，消失的时候加入到缓存池中
 */
@property (nonatomic, retain) NSMutableArray *cachedCardsPool;

@property (nonatomic, retain) UIPanGestureRecognizer *pan;

/**
 缓存的卡片数据
 */
@property (nonatomic, assign) NSInteger cachedCardsData;
/**
 实际显示卡片个数，多一个，用来预加载一张卡片
 */
@property (nonatomic, assign) NSInteger displayCount;

/**
 当前显示的卡片下标
 */
@property (nonatomic, assign) NSInteger currentDisplayIndex;

@end

@implementation StackCardView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _currentDisplayIndex = 0;
        [self numberOfDisplayingCards];
        [self stackCachedCardsData];
        [self addGestureRecognizer:self.pan];
//        [self selectIndex:_currentDisplayIndex animated:YES];
    }
    
    return self;
}

- (void)reloadCardsView {
    [self numberOfDisplayingCards];
    [self stackCachedCardsData];
    
    [self initCards];
//    [self selectIndex:_currentDisplayIndex animated:YES];
}

- (void)selectIndex:(NSInteger)index animated:(BOOL)animated {
    _currentDisplayIndex = MIN(index, _cachedCardsData - 1);
    
    _cachedCardsPool = [[NSMutableArray alloc] init];
    // 获取当前卡片
    NSInteger actualDisplayNumbers = MIN(_displayCount, _cachedCardsData - index - 1);
    for (int currentIndex = 0; currentIndex < actualDisplayNumbers; currentIndex ++) {
        StackCardCell *currentCell = [self reusableCardCellAtIndex:_currentDisplayIndex + currentIndex];
        [_cachedCardsPool addObject:currentCell];
    }
    
    [self updateCells];
}

- (void)updateCells {
    for (StackCardCell *currentCell in _cachedCardsPool) {
        [self addSubview:currentCell];
        [self sendSubviewToBack:currentCell];
        [self makeScaleForCurrentCards:currentCell atIndex:currentCell.index displayIndex:0];
    }
}


/**
 缩放当前的cell视图

 @param cell 当前显示的cell
 @param index 当前所在的序号
 @param displayIndex 显示的序号
 */
- (void)makeScaleForCurrentCards:(StackCardCell *)cell atIndex:(NSInteger)index displayIndex:(NSInteger)displayIndex {
    CGPoint center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2 + 10 * index);
//    cell.center = CGPointMake(center.x, center.y + cell.labHeight / 2 * (1 - scale));
    cell.labBottom = cell.labHeight + index * 10;
//    float scale = [self scaleForCurrentCenter:center];
//    cell.transform = CGAffineTransformMakeScale(scale, scale);
    NSLog(@"center.y %f", cell.center.y);
}


- (void)stackCachedCardsData {
    _cachedCardsData = [_stackDelegate numberOfCardsDataForCards:self];
}

- (void)panHandle:(UIPanGestureRecognizer *)pan {
    
    // 获取顶部视图
//    TABBaseCardView * cardView = self.cards[self.currentIndex];
    
    CGPoint velocity = [pan velocityInView:[UIApplication sharedApplication].keyWindow];
    
    // 开始拖动
    if (pan.state == UIGestureRecognizerStateBegan) {
        // 缓存卡片最初的位置信息
//        self.oldCenter = cardView.center;
    }
    
    // 拖动中
    if (pan.state == UIGestureRecognizerStateChanged) {
        // 给顶部视图添加动画
        CGPoint transLcation = [pan translationInView:self];
        NSLog(@"移动的距离%f", transLcation.y);
        [self updateCellFrame:transLcation.y];
        // 视图跟随手势移动
//        cardView.center = CGPointMake(cardView.center.x + transLcation.x, cardView.center.y + transLcation.y);
//        // 计算偏移系数
//        CGFloat XOffPercent = (cardView.center.x - self.center.x)/(self.center.x);
//        CGFloat rotation = M_PI_2/10.5*XOffPercent;
//        cardView.transform = CGAffineTransformMakeRotation(-rotation);
//        [pan setTranslation:CGPointZero inView:cardView];
//        // 给其余底部视图添加缩放动画
//        [self animationBlowViewWithXOffPercent:fabs(XOffPercent)];
    }
    
    // 拖动结束
    if (pan.state == UIGestureRecognizerStateEnded) {
        
        // 移除拖动视图逻辑
        
        // 加速度 小于 1100points/second
//        if (sqrt(pow(velocity.x, 2) + pow(velocity.y, 2)) < 1100.0) {
//
//            // 移动区域半径大于120pt
//            if ((sqrt(pow(self.oldCenter.x-cardView.center.x,2) + pow(self.oldCenter.y-cardView.center.y,2))) > 120) {
//
//                // 移除，自然垂落
//                [UIView animateWithDuration:0.6 animations:^{
//                    UIWindow * window = [[[UIApplication sharedApplication] delegate] window];
//                    CGRect rect = [cardView convertRect:cardView.bounds toView:window];
//                    cardView.center = CGPointMake(cardView.center.x, cardView.center.y+(kScreenHeight-rect.origin.y+50));
//                }];
//                [self animationBlowViewWithXOffPercent:1];
//                [self performSelector:@selector(cardRemove:) withObject:cardView afterDelay:0.5];
//
//            }else {
//
//                __weak typeof(self) weakSelf = self;
//                // 不移除，回到初始位置
//                [UIView animateWithDuration:0.5 animations:^{
//                    cardView.center = weakSelf.oldCenter;
//                    cardView.transform = CGAffineTransformMakeRotation(0);
//                    [self animationBlowViewWithXOffPercent:0];
//                }];
//            }
//        }else {
//
//            // 移除，以手势速度飞出
//            [UIView animateWithDuration:0.5 animations:^{
//                cardView.center = velocity;
//            }];
//            [self animationBlowViewWithXOffPercent:1];
//            [self performSelector:@selector(cardRemove:) withObject:cardView afterDelay:0.25];
//        }
    }
}


#pragma mark - 显示个数获取
- (void)numberOfDisplayingCards {
    if (_stackDelegate && [_stackDelegate respondsToSelector:@selector(numberOfDisplayingCards)]) {
        self.displayCount = [_stackDelegate numberOfDisplayingCards];
    }else {
        self.displayCount = 3;
    }
}


#pragma mark - cell获取
- (StackCardCell *)reusableCardCellAtIndex:(NSInteger)index {
    return [_stackDelegate stackCardsView:self cellForCurrentIndex:index];
}

- (StackCardCell *)cellForIndex:(NSInteger)index reusableIdentifier:(NSString *)reusableIdentifier {
    StackCardCell *cell = [[StackCardCell alloc] initWithIndex:index reusableIdentifier:reusableIdentifier];
    cell.frame = CGRectMake((self.labWidth - 200) / 2, 0, 200, 200);
    
    return cell;
}

- (float)scaleForCurrentCenter:(CGPoint)center {
    float distance = (center.y - self.bounds.size.height / 2);
    NSLog(@"距离%f", distance);
    float scale = 1 - (float)distance / 20;
    
    return scale;
}



#pragma mark - 初始化当前页面
/**
 初始化加载卡片组
 */
- (void)initCards {
    // 获取卡片数组
    
    if (!_cachedCardsPool) {
        _cachedCardsPool = [[NSMutableArray alloc] init];
    }
    // 获取当前卡片组
    NSInteger actualDisplayNumbers = MAX(0, _displayCount + 1);
    for (int currentIndex = 0; currentIndex < actualDisplayNumbers; currentIndex ++) {
        StackCardCell *currentCell = [self reusableCardCellAtIndex:_currentDisplayIndex + currentIndex];
        if (![self.subviews containsObject:currentCell]) {
            [_cachedCardsPool addObject:currentCell];
            [self addSubview:currentCell];
        }
        [self sendSubviewToBack:currentCell];
        [self makeScaleForCurrentCards:currentCell atIndex:currentIndex displayIndex:currentIndex];
    }
}


#pragma mark - 根据手势移动距离，动态设置尺寸
- (void)updateCellFrame:(CGFloat)distance {
    for (StackCardCell *cell in self.cachedCardsPool) {
        cell.labY += distance;
    }
}


- (UIPanGestureRecognizer *)pan {
    if (!_pan) {
        _pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panHandle:)];
    }
    
    return _pan;
}

@end
