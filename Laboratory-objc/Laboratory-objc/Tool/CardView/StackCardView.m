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
 实际显示卡片个数，多两个个，用来预加载两张卡片
 */
@property (nonatomic, assign) NSInteger displayCount;

/**
 当前显示的卡片下标
 */
@property (nonatomic, assign) NSInteger currentDisplayIndex;

/**
 动画时间
 */
@property (nonatomic, assign) CGFloat animateDuration;

/**
 用来防止极短时间内重复调用
 */
@property (nonatomic, assign) BOOL animateStatus;

@property (nonatomic) CGPoint cardCenter;

@end

@implementation StackCardView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _currentDisplayIndex = 0;
        _animateDuration = .4;
        _cachedCardsPool = [[NSMutableArray alloc] init];
        [self addGestureRecognizer:self.pan];
    }
    
    return self;
}

- (void)reloadCardsView {
    [self numberOfDisplayingCards];
    [self stackCachedCardsData];
    
    [self initCards];
    [self selectIndex:_currentDisplayIndex animated:NO];
}

- (void)selectIndex:(NSInteger)index animated:(BOOL)animated {
    NSInteger targetIndex = index;
    targetIndex = MIN(targetIndex, _cachedCardsData - 1);   // 限制最大值的范围
    targetIndex = MAX(0, targetIndex);
    
    NSInteger actualDisplayNumbers = _displayCount + 2;
    
    // 目标坐标到当前显示坐标的卡片个数
    NSInteger distanceCards = _currentDisplayIndex - targetIndex;
    if (distanceCards == 0) {
        return;
    }
    if (distanceCards < 0) {
        if (labs(distanceCards) == 1) {
        
            NSMutableArray *mutCopyArray = [[NSMutableArray alloc] initWithArray:_cachedCardsPool];
            // 滑动一个卡片，每个卡片向上滑动一个卡片距离
            for (int currentExist = 0; currentExist < actualDisplayNumbers; currentExist ++) {
                NSInteger displayIndex = currentExist - 1;
                NSInteger cellIndex = (_currentDisplayIndex + displayIndex) % (_cachedCardsData);
                BOOL hide = NO;
                if (_currentDisplayIndex + displayIndex >= _cachedCardsData) {
                    hide = YES;
                }
                
                if (cellIndex < 0) {
                    cellIndex = (_cachedCardsData + cellIndex) % (_cachedCardsData);
                }
                // 获取当前在目前位置的cell
                NSLog(@"现在显示的坐标:%ld, 显示的坐标:%ld", cellIndex, displayIndex);
                StackCardCell *currentCell = [self reusableCellAtIndex:cellIndex displayIndex:currentExist];
                
                // 缩放当前的卡片视图
                [self makeNextScaleForCurrentCards:currentCell atIndex:cellIndex displayIndex:displayIndex + distanceCards animated:animated hideCurrentCell:hide];

                // 将当前的cell移动到首位
                if (displayIndex <= -1) {
                    [mutCopyArray removeObject:currentCell];
                    [mutCopyArray addObject:currentCell];
                }
                
                // 将当前的cell移动到首位
                if (displayIndex > _displayCount) {
                    [mutCopyArray removeObject:currentCell];
                    [mutCopyArray insertObject:currentCell atIndex:0];
                }
            }
            _cachedCardsPool = nil;
            _cachedCardsPool = [[NSMutableArray alloc] initWithArray:mutCopyArray];
        }
        _currentDisplayIndex = targetIndex;
        [self cardCellDidChangedAtIndex];
        
    }else {
        NSMutableArray *mutCopyArray = [[NSMutableArray alloc] initWithArray:_cachedCardsPool];
        if (labs(distanceCards) == 1) {
            for (int currentExist = 0; currentExist < actualDisplayNumbers; currentExist ++) {
                NSInteger displayIndex = currentExist - 1;
                // 循环
                NSInteger cellIndex = (_currentDisplayIndex + displayIndex) % (_cachedCardsData);
                BOOL hide = NO;
                if (_currentDisplayIndex + displayIndex >= _cachedCardsData) {
                    hide = YES;
                }
                if (cellIndex < 0) {
                    cellIndex = (_cachedCardsData + cellIndex) % (_cachedCardsData);
                }
                NSLog(@"当前坐标:%ld, 显示的坐标:%ld", cellIndex, displayIndex);
                StackCardCell *currentCell = [self reusableCardCellAtIndex:cellIndex displayIndex:currentExist];
                
                [self makePreviousScaleForCurrentCards:currentCell atIndex:cellIndex displayIndex:displayIndex + distanceCards animated:animated hideCurrentCell:hide];
                
                if (currentCell) {
                    if (![_cachedCardsPool containsObject:currentCell]) {
                        [_cachedCardsPool addObject:currentCell];
                        [mutCopyArray addObject:currentCell];
                    }
                }
                // 将当前的cell移动到首位
                if (displayIndex < -1) {
                    NSLog(@"放到尾部");
                    [mutCopyArray removeObject:currentCell];
                    [mutCopyArray addObject:currentCell];
                }
                
                // 将当前的cell移动到首位
                if (displayIndex >= _displayCount) {
                    NSLog(@"移动到首部");
                    [mutCopyArray removeObject:currentCell];
                    [mutCopyArray insertObject:currentCell atIndex:0];
                }
            }
        }
        _cachedCardsPool = nil;
        _cachedCardsPool = [[NSMutableArray alloc] initWithArray:mutCopyArray];
        
        _currentDisplayIndex = targetIndex;
        [self cardCellDidChangedAtIndex];
    }
}

- (void)loadNextCard {
    if (_animateStatus) {
        return;
    }
    _animateStatus = YES;
    WeakSelf(self)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_animateDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        weakself.animateStatus = NO;
    });
    NSInteger targetIndex = (MIN(_cachedCardsData - 1,_currentDisplayIndex + 1)) % _cachedCardsData;
    [self selectIndex:targetIndex animated:YES];
}

- (void)loadPreviousCard {
    if (_animateStatus) {
        return;
    }
    _animateStatus = YES;
    WeakSelf(self)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_animateDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        weakself.animateStatus = NO;
    });
    NSInteger targetIndex = (MAX(0, _currentDisplayIndex - 1)) % _cachedCardsData;
    [self selectIndex:targetIndex animated:YES];
}


#pragma mark - 视图缩放

/**
 缩放当前的cell视图
 
 @param cell 当前显示的cell
 @param index 当前所在的序号
 @param displayIndex 显示的序号, 比如当前显示为最上层的卡片
 @param animated 是否动画显示
 @param hide 隐藏
 */
- (void)makePreviousScaleForCurrentCards:(StackCardCell *)cell atIndex:(NSInteger)index displayIndex:(NSInteger)displayIndex animated:(BOOL)animated hideCurrentCell:(BOOL)hide {
    float scale = [self scaleTargetIndex:displayIndex];
    CGFloat targetCenterY = [self currentTargetCenterY:cell displayIndex:displayIndex];
    
    CGPoint point = CGPointMake(cell.labCenterX, targetCenterY);
    CGAffineTransform scaleTransform = CGAffineTransformMakeScale(scale, scale);
    
    CGFloat duration = _animateDuration;
    // 动画速度主要是为了首尾卡片切换时，提前放置层级顺序，其他正常显示的卡片动画时间正常
    if (displayIndex > _displayCount) {
        duration = MIN(0, duration - labs(displayIndex) * .1);
    }
    CGFloat dely = 0;
    if (displayIndex < 0) {
        dely = .1;
    }
    
    if (index > self.cachedCardsData) {
        cell.alpha = 0;
    }
    WeakSelf(self)
    [UIView animateWithDuration:animated ? duration : 0 delay:dely options:UIViewAnimationOptionCurveEaseIn animations:^{
        cell.center = point;
        cell.transform = scaleTransform;
        if (hide) {
            cell.alpha = 0;
        }else if (index > weakself.cachedCardsData) {
            cell.alpha = 0;
        }else {
            cell.alpha = [self alphaAfterScalingAnimated:displayIndex cellIndex:index];
        }
    } completion:^(BOOL finished) {
        if (displayIndex < 0) {
            if (displayIndex == -1) {
                // -1 理论上应该表示最顶层的卡片，显示顺序为-1 , 0, ....,
                [self bringSubviewToFront:cell];
            }
        }else if (displayIndex >= weakself.displayCount) {
            // 底层多推出了一张，需要将该视图放置到最顶层去
            if (displayIndex == weakself.displayCount + 1) {
                [self makePreviousScaleForCurrentCards:cell atIndex:weakself.currentDisplayIndex - 1 displayIndex:-1 animated:NO hideCurrentCell:hide];
            }
            
            // 设置为最底层视图，即尾部视图
            if (displayIndex == weakself.displayCount) {
            }
        }
    }];
}

/**
 缩放当前的cell视图

 @param cell 当前显示的cell
 @param index 当前所在的序号
 @param displayIndex 显示的序号, 比如当前显示为最上层的卡片
 @param animated 是否动画显示
 @param hide 隐藏
 */
- (void)makeNextScaleForCurrentCards:(StackCardCell *)cell atIndex:(NSInteger)index displayIndex:(NSInteger)displayIndex animated:(BOOL)animated hideCurrentCell:(BOOL)hide {
    float scale = [self scaleTargetIndex:displayIndex];
    CGFloat targetCenterY = [self currentTargetCenterY:cell displayIndex:displayIndex];
    
    CGPoint point = CGPointMake(cell.labCenterX, targetCenterY);
    CGAffineTransform scaleTransform = CGAffineTransformMakeScale(scale, scale);
    
    CGFloat duration = _animateDuration;
    CGFloat dely = 0;
    if (displayIndex >= 0) {
        dely = .1;
    }
    WeakSelf(self)
    [UIView animateWithDuration:animated ? duration : 0 delay:dely options:UIViewAnimationOptionCurveEaseOut animations:^{
        cell.center = point;
        cell.transform = scaleTransform;
        if (hide) {
            cell.alpha = 0;
        }else if (index > weakself.cachedCardsData) {
            cell.alpha = 0;
        }else {
            cell.alpha = [self alphaAfterScalingAnimated:displayIndex cellIndex:index];
        }
    } completion:^(BOOL finished) {
        [weakself updateReusableCell:cell currentDisplayIndex:displayIndex atIndex:index];
    }];
}

- (void)updateReusableCell:(StackCardCell *)cell currentDisplayIndex:(NSInteger)displayIndex atIndex:(NSInteger)index {
    
    if (displayIndex < 0) {
        if (displayIndex == -1) {
            // -1 理论上应该表示最顶层的卡片，显示顺序为-1 , 0, ....,
            [self bringSubviewToFront:cell];
        }
        
        if (displayIndex <= -2) {
            // -2 表示向下翻了一页，此时最顶层坐标为-2，需要将该视图放置最底层，变为尾部的卡片
            [self sendSubviewToBack:cell];
            [self makeNextScaleForCurrentCards:cell atIndex:_currentDisplayIndex + _displayCount displayIndex:_displayCount animated:NO hideCurrentCell:NO];
        }
    }
}


- (void)panHandle:(UIPanGestureRecognizer *)pan {}


#pragma mark - 数据获取
- (void)stackCachedCardsData {
    _cachedCardsData = [_stackDelegate numberOfCardsDataForCards:self];
}

#pragma mark 显示个数获取
- (void)numberOfDisplayingCards {
    if (_stackDelegate && [_stackDelegate respondsToSelector:@selector(numberOfDisplayingCards)]) {
        self.displayCount = [_stackDelegate numberOfDisplayingCards];
    }else {
        self.displayCount = 3;
    }
}

#pragma mark 卡片切换
- (void)cardCellDidChangedAtIndex{
    if (_stackDelegate && [_stackDelegate respondsToSelector:@selector(stackCardView:didSelectAtIndex:)]) {
        [_stackDelegate stackCardView:self didSelectAtIndex:_currentDisplayIndex];
    }
}

#pragma mark cell获取
- (StackCardCell *)reusableCardCellAtIndex:(NSInteger)index displayIndex:(NSInteger)displayIndex {
    return [self reusableCellAtIndex:index displayIndex:displayIndex];
}

- (StackCardCell *)reusableCellAtIndex:(NSInteger)index displayIndex:(NSInteger)displayIndex {
    return [_stackDelegate stackCardsView:self cellForCurrentIndex:index displayIndex:displayIndex];
}

- (StackCardCell *)cellForIndex:(NSInteger)index atDisplayIndex:(NSInteger)displayIndex {
    StackCardCell *cell = nil;
    
    /*
     复用问题
     */
    if (_cachedCardsPool.count > displayIndex) {
        cell = _cachedCardsPool[displayIndex];
    }
    
    if (cell == nil) {
        cell = [[StackCardCell alloc] initWithFrame:[self cellFrame]];
        cell.index = index;
        cell.alpha = 0;
        [self addSubview:cell];
        [self sendSubviewToBack:cell];
    }
    
    return cell;
}

#pragma mark 偏移量
- (CGFloat)cardOffsetFromDelegate {
    if (_stackDelegate && [_stackDelegate respondsToSelector:@selector(cardOffsetFromDelegate)]) {
        return [_stackDelegate distanceOfCellOffset:self];
    }
    
    return 5;
}

#pragma mark 卡片的尺寸
- (UIEdgeInsets)paddingInsets {
    if (_stackDelegate && [_stackDelegate respondsToSelector:@selector(edgeInsetsForCell:)]) {
        return [_stackDelegate edgeInsetsForCell:self];
    }
    return UIEdgeInsetsMake(5, 5, 5, 5);
}

- (CGRect)cellFrame {
    UIEdgeInsets inset = [self paddingInsets];

    return CGRectMake(inset.left, inset.top, self.bounds.size.width - inset.left - inset.right, self.bounds.size.height - inset.top - inset.bottom);
}

#pragma mark cell的透明度设置

/**
 动画缩放之后此时cell的透明度
 
 @param displayIndex 显示坐标
 @param cellIndex cell实际的坐标
 @return 透明度
 */
- (float)alphaAfterScalingAnimated:(NSInteger)displayIndex cellIndex:(NSInteger)cellIndex {
    if (displayIndex < 0 || displayIndex >= _displayCount) {
        return 0;
    }
    
    return [self scaleTargetIndex:displayIndex];
}

#pragma mark - 初始化当前页面
/**
 初始化加载卡片组
 */
- (void)initCards {
    // 获取当前卡片组, 限制个数n
    NSInteger actualDisplayNumbers = MAX(0, _displayCount + 2);
    
    CGRect displayFrame = [self cellFrame];
    _cardCenter = CGPointMake(CGRectGetWidth(displayFrame) / 2 + CGRectGetMinX(displayFrame), CGRectGetHeight(displayFrame) / 2  + CGRectGetMinY(displayFrame));

    NSMutableArray *mutCopyArray = [[NSMutableArray alloc] initWithArray:_cachedCardsPool];
    
    for (int currentIndex = 0; currentIndex < actualDisplayNumbers; currentIndex ++) {
        NSInteger displayIndex = currentIndex - 1;
        NSInteger cellIndex = (_currentDisplayIndex + displayIndex) % (_cachedCardsData);
        BOOL hide = NO;
        if (_currentDisplayIndex + displayIndex >= _cachedCardsData || (_currentDisplayIndex + displayIndex) < 0) {
            hide = YES;
        }
        if (displayIndex < 0) {
            cellIndex = (_cachedCardsData + displayIndex) % _cachedCardsData;
        }
        
        NSLog(@"当前坐标:%ld, 显示的坐标:%ld", cellIndex, displayIndex);
        // 获取cell
        StackCardCell *currentCell = [self reusableCellAtIndex:cellIndex displayIndex:currentIndex];
        
        if (currentCell) {
            if (![_cachedCardsPool containsObject:currentCell]) {
                [_cachedCardsPool addObject:currentCell];
                [mutCopyArray addObject:currentCell];
            }
        }
        
        // 缩放当前的卡片视图
        [self makeNextScaleForCurrentCards:currentCell atIndex:cellIndex displayIndex:displayIndex animated:NO hideCurrentCell:hide];
        
        // 将当前的cell移动到首位
        if (displayIndex >= actualDisplayNumbers) {
            NSLog(@"将最尾部卡片移动到首部");
            [mutCopyArray removeObject:currentCell];
            [mutCopyArray insertObject:currentCell atIndex:0];
        }
    }
    
    _cachedCardsPool = nil;
    _cachedCardsPool = [[NSMutableArray alloc] initWithArray:mutCopyArray];
}


#pragma mark 视图缩放参数动态计算
- (float)lastCellScale {
    if (_stackDelegate && [_stackDelegate respondsToSelector:@selector(lastCellScaleForCards:)]) {
        return [_stackDelegate lastCellScaleForCards:self];
    }
    
    return .7;
}

- (CGFloat)scaleTargetIndex:(NSInteger)displayIndex {
    float lastScale = 1 - [self lastCellScale];
    float scale = 1 - (float)displayIndex * ((float)lastScale / MAX(1, _displayCount - 1));
    
    return scale;
}

- (CGFloat)currentTargetCenterY:(StackCardCell *)cell displayIndex:(NSInteger)displayIndex {
    float scale = [self scaleTargetIndex:displayIndex];
    CGFloat targetOffset = [self cardOffsetFromDelegate] * displayIndex;
    CGFloat scaleHeight = cell.bounds.size.height / 2 * scale; // 缩放后的高度
    CGFloat targetCenterY = _cardCenter.y + cell.bounds.size.height / 2 - scaleHeight + targetOffset;
    
    return targetCenterY;
}


- (UIPanGestureRecognizer *)pan {
    if (!_pan) {
        _pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panHandle:)];
    }
    
    return _pan;
}


#pragma mark - getter
- (StackCardCell *)selectedCell {
    NSString *filterString = [NSString stringWithFormat:@"index = %ld", (long)_currentDisplayIndex];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:filterString];
    
    NSArray *array = [_cachedCardsPool filteredArrayUsingPredicate:predicate];
    if (array.count > 0) {
        return array.firstObject;
    }
    
    return nil;
}

@end
