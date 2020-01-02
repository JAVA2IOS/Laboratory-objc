//
//  StackCardView.m
//  Laboratory-objc
//
//  Created by qeeniao35 on 2019/4/28.
//  Copyright © 2019 CodeZ. All rights reserved.
//

#import "StackCardView.h"

@interface StackCardConfigure()
@property (nonatomic, assign, readwrite) BOOL empty;
@property (nonatomic, copy, readwrite) NSString *version;
@end

@implementation StackCardConfigure
- (NSString *)version {
    return @"0.0.1";
}

- (double)calculateTheRelativeMovingDistance:(CGFloat)currentMovingDistance targetDistance:(CGFloat)targetDistance {
    CGFloat distance = self.panLimitedDistance;
    if (distance <= 0) {
        distance = 1;
    }

    double loga = (double)(log(targetDistance) - 1) / distance;
    
    double y = (double)log(currentMovingDistance) / loga  - (double)1 / loga;
    
    MJRefreshLog(@"当前y值:%f, 距离%f, 目标距离%f, 卡片位移距离:%f", y, currentMovingDistance, targetDistance, self.panLimitedDistance);
    
    return y;
}

@end


@interface StackCardView() <UIGestureRecognizerDelegate> {
    CGPoint panPreviousPoint;  // 滑动一开始的点
    BOOL panStatus; // 类似加一个锁，保证手势滑动的时候一次有响应一次结束的事件(很重要，否则计算不准确)
}
/**
 正在显示的cell
 */
@property (nonatomic, retain) NSMutableArray<__kindof StackCardCell *> *visibleCells;

@property (nonatomic, retain) UIPanGestureRecognizer *panGesture;
/// 为每个动作添加状态，主要防止加载上一页和下一页多次不间断触发造成计算逻辑错误
@property (nonatomic, assign, readwrite) StackCardLoadStatus status;

@property (nonatomic, retain, readwrite) StackCardConfigure *configure;

/// 注册过的可以复用的cell
@property (nonatomic, retain) NSMutableDictionary<NSString *, Class> *registClassDictionary;
/// 可复用的cell缓存池
/*
 {
    "identifier" : NSArray[cell, cell ...]
 }
 */
@property (nonatomic, retain) NSMutableDictionary *registReuslableCellPools;

#pragma mark 以下属性在计算时需要使用
/// 当前最顶部的cell显示的坐标
@property (nonatomic, retain) NSIndexPath *currentIndexPath;
@property (nonatomic) CGPoint cardCenter;
/**
 实际显示的卡片个数，正常的加载的卡片比该个数多一个，多余的一个一般放在最后，并且与倒数第二个重复叠加
 */
@property (nonatomic, assign) NSInteger displayCount;

/// 从缩放程度.7~1之间总共垂直的间距(用于计算每个卡片在垂直方向的y坐标，间距等分)
@property (nonatomic, assign) CGFloat scaleDistanceSpacing;

/// 最后一个卡片缩放时的目标y坐标
@property (nonatomic, assign) CGFloat lastScaleCardCenterY;

/// 当前卡片列表所有的section
@property (nonatomic, assign) NSInteger preferredSection;

@end

@implementation StackCardView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initialParameters];
        _visibleCells = [[NSMutableArray alloc] init];
        _registReuslableCellPools = [[NSMutableDictionary alloc] init];
        _registClassDictionary = [[NSMutableDictionary alloc] init];
        _currentIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        
        [self addGestureRecognizer:self.panGesture];
    }
    
    return self;
}

/// 初始化参数系数
- (void)initialParameters {
    if (_configure == nil) {
        _configure = [[StackCardConfigure alloc] init];
        _configure.animatedDuration = .15;
        _configure.panGestureEnable = YES;
        _configure.panLimitedDistance = fabs(self.bounds.size.width / 3);
        _configure.panMinimunCardCenterX = -20;
    }
    
    _status = StackCardLoadStatusNone;
    
    CGRect frame = [self cellFrame];
    
    _cardCenter = CGPointMake(CGRectGetWidth(frame) / 2 + CGRectGetMinX(frame), CGRectGetMinY(frame) + CGRectGetHeight(frame) / 2);
    [self numberOfDisplayingCards];
    _preferredSection = [self sections];
    if (!_currentIndexPath && _preferredSection > 0) {
        _currentIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    }
    
    // 每个卡片垂直方向的间距等分
    NSInteger averageCount = _displayCount - 1;
    averageCount = MAX(1, averageCount);
    _scaleDistanceSpacing = [self cardOffsetFromDelegate] * averageCount;
    // 每份缩放的程度
    float scaleDistance = (float)(1 - [self lastCellScale]) / averageCount;
    float scale = 1 - scaleDistance * _displayCount;
    scale = MAX([self lastCellScale], scale);
    CGFloat scaleHeight = CGRectGetHeight(frame) / 2 * scale; // 缩放后的高度
    _lastScaleCardCenterY = _cardCenter.y + CGRectGetHeight(frame) / 2 - scaleHeight +  _scaleDistanceSpacing;
    
}

- (void)pangeGestureHandler:(UIPanGestureRecognizer *)pan {
    CGPoint currentPoint = [pan locationInView:self];
    CGPoint translationPoint = [pan translationInView:self];
    
    CGFloat directions = translationPoint.x;
    StackScrollDirection direction = StackScrollDirectionClockwise;
    if (directions < 0) {
        direction = StackScrollDirectionCounterClockwise;
    }
    
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
        {
            panPreviousPoint = CGPointZero;
        }
            break;
        case UIGestureRecognizerStateChanged:
            panStatus = YES;
            [self movedComponents:currentPoint translatePoint:translationPoint direction:direction];
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateCancelled:
        {
            if (panStatus) {
                if ([self canSwipe:_panGesture direction:direction]) {
                    CGPoint velocity = [pan velocityInView:self];
                    [self panGestureEnded:currentPoint translatePoint:translationPoint velocity:velocity];
                }else {
                    if (direction == StackScrollDirectionClockwise) {
                        if (_currentIndexPath.section == 0
                            && _currentIndexPath.row == 0) {
                        }else {
                            _currentIndexPath = [self nextIndexPath];
                        }
                    }
                    
                    [self restoreCancelledCell:direction];
                    
                    if (fabs(directions) >= _configure.panLimitedDistance / 4 * 3) {
                        // 超过当前距离才会响应
                        if (_stackDelegate && [_stackDelegate respondsToSelector:@selector(stackCardView:didSwitchedUsedPangestureCell:atIndexPath:direction:)]) {
                            [_stackDelegate stackCardView:self didSwitchedUsedPangestureCell:_visibleCells.firstObject atIndexPath:_currentIndexPath direction:direction];
                        }
                    }
                }
                [pan setTranslation:CGPointZero inView:pan.view];
                
                panStatus = NO;
            }
        }
            break;
            
        default:
            break;
    }
    
    panPreviousPoint = currentPoint;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == _panGesture) {
        CGPoint velocity = [_panGesture velocityInView:self];
        return fabs(velocity.x) > fabs(velocity.y);
    }
    
    return YES;
}

- (void)movedComponents:(CGPoint)currentPoint translatePoint:(CGPoint)translatePoint direction:(StackScrollDirection)direction {
    CGFloat distance = currentPoint.x - panPreviousPoint.x;
    CGFloat directions = translatePoint.x;
    
    if (![self canSwipe:_panGesture direction:direction]) {
        // 禁用滑动手势时，卡片只能滑动三分之一的宽度
        double currenDistance = [_configure calculateTheRelativeMovingDistance:fabs(directions) targetDistance:self.bounds.size.width];
        if (direction == StackScrollDirectionCounterClockwise) {
            CGFloat previousX = currentPoint.x - directions;
            currentPoint = CGPointMake(previousX - currenDistance, currentPoint.y);
            MJRefreshLog(@"当前坐标(%f, %f)", currentPoint.x, currentPoint.y);
        }
        
        if (fabs(directions) >= _configure.panLimitedDistance) {
            return;
        }
    }

    // 上一页
    if (direction == StackScrollDirectionClockwise) {
        [self translatedWithDirectionClockwise:distance currentPoint:currentPoint];
        return;
    }else {
        [self translatedWithDirectionCountClockwise:distance currentPoint:currentPoint];
        return;
    }
}

- (void)panGestureEnded:(CGPoint)currentPoint translatePoint:(CGPoint)translatePoint velocity:(CGPoint)veloctiyPoint {
    // 计算减速到0为止的卡片滑动的目标坐标
    CGFloat directions = translatePoint.x;
    CGFloat targetDistance = veloctiyPoint.x - currentPoint.x;
    float a = -200.f;
    float t = -(float)fabs(veloctiyPoint.x) / a;
    CGFloat s = fabs(veloctiyPoint.x) * t + a * pow(t, 2) / 2.f;
    targetDistance = s;
    
    StackScrollDirection direction = StackScrollDirectionClockwise;
    if (directions < 0) {
        direction = StackScrollDirectionCounterClockwise;
    }
    
    if (fabs(directions) + fabs(targetDistance) > _configure.panLimitedDistance) {
        if (_currentIndexPath.section == 0
            && _currentIndexPath.row == 0
            && direction == StackScrollDirectionClockwise) {
            [self restoreCancelledCell:direction];
            return;
        }
        if (_visibleCells.count >= 1 && direction == StackScrollDirectionCounterClockwise) {
            NSIndexPath *lastIndexPath = ((StackCardCell *)_visibleCells.lastObject).indexPath;
            NSComparisonResult result = [lastIndexPath compare:_currentIndexPath];
            if (result == NSOrderedSame) {
                [self restoreCancelledCell:direction];
                return;
            }
        }
        
        // 滑动过去
        [self translationSuccessedCell:direction];
    }else {
        if (direction == StackScrollDirectionClockwise) {
            NSComparisonResult result = [_currentIndexPath compare:[NSIndexPath indexPathForRow:0 inSection:0]];
            if (result != NSOrderedSame) {
                _currentIndexPath = [self nextIndexPath];
            }
        }
        
        // 恢复原样
        [self restoreCancelledCell:direction];
    }
}

// 上一页
- (void)translatedWithDirectionClockwise:(CGFloat)distance currentPoint:(CGPoint)currentPoint {
    CGPoint selfCenterPoint = _cardCenter;
    StackCardCell *topCell = _visibleCells.firstObject;
    NSIndexPath *lastIndexPath = [self lastIndexPath];
    
    if (topCell.center.x >= selfCenterPoint.x
        && topCell.center.y >= selfCenterPoint.y) {
        // 新增一个cell，如果cell存在不增加
        BOOL containStatus = NO;
        for (StackCardCell *visibleCell in _visibleCells) {
            if (visibleCell.indexPath.section == lastIndexPath.section
                && visibleCell.indexPath.row == lastIndexPath.row) {
                containStatus = YES;
                break;
            }
        }
        if (!containStatus) {
            StackCardCell *newCell = [self dequeueReusableCell:lastIndexPath];
            [self addSubview:newCell];
            [self bringSubviewToFront:newCell];
            [self movedCellIntoVisiblePool:newCell];
            CGAffineTransform rotationTransform = CGAffineTransformMakeRotation(- M_PI_4 / 4);
            newCell.transform = rotationTransform;
            newCell.center = CGPointMake(_configure.panMinimunCardCenterX, selfCenterPoint.y);
            // 移除最后一个cell
            if (_visibleCells.count > (_displayCount + 1)) {
                [self movedCellIntoCachedPools:_visibleCells.lastObject];
            }
        }
    }
    
    NSMutableArray *newVisibleCells = [_visibleCells mutableCopy];
    for (StackCardCell *subView in newVisibleCells) {
        CGPoint centerPoint = subView.center;
        
        if ((centerPoint.x + distance) <= selfCenterPoint.x
            && centerPoint.y <= selfCenterPoint.y) {
            CGFloat x = [self rotationProportion:currentPoint];
            centerPoint.x += x;
            // 已经滑到左边了
            centerPoint.x = MIN(selfCenterPoint.x, centerPoint.x);
            subView.transform = CGAffineTransformIdentity;
            
            CGFloat k = (- M_PI_4 / 4) / (_configure.panMinimunCardCenterX - selfCenterPoint.x);
            CGFloat m = - selfCenterPoint.x * k;
            
            CGFloat rotation = centerPoint.x * k + m;
            
            CGAffineTransform rotationTransform = CGAffineTransformMakeRotation(rotation);
            subView.transform = rotationTransform;
        }else {
            if (centerPoint.x < selfCenterPoint.x) {
                centerPoint.x += [self rotationProportion:currentPoint];
                centerPoint.x = MIN(selfCenterPoint.x, centerPoint.x);
                centerPoint.x = MAX(_configure.panMinimunCardCenterX, centerPoint.x);
                subView.transform = CGAffineTransformIdentity;
            }else {
                float movedDistance = [self scaleDistanceProportion:currentPoint];
                centerPoint.y += movedDistance;
                centerPoint.y = MAX(selfCenterPoint.y, centerPoint.y);
                centerPoint.y = MIN(_lastScaleCardCenterY, centerPoint.y);
                float lastScale = 1 - [self lastCellScale];
                CGFloat scaleDistance = _lastScaleCardCenterY - selfCenterPoint.y;
                CGFloat k = -(float)lastScale / scaleDistance;
                CGFloat m = 1 - selfCenterPoint.y * k;
                float scale = centerPoint.y * k + m;
                
                CGAffineTransform scaleTransform = CGAffineTransformMakeScale(scale, scale);
                subView.transform = scaleTransform;
            }
        }
        subView.center = centerPoint;
        
        if (subView.center.x >= _configure.panMinimunCardCenterX && subView.center.x <= selfCenterPoint.x
            && subView.center.y == selfCenterPoint.y) {
            _currentIndexPath = ((StackCardCell *)_visibleCells.firstObject).indexPath;
        }
    }
}

// 下一页
- (void)translatedWithDirectionCountClockwise:(CGFloat)distance currentPoint:(CGPoint)currentPoint {
    CGPoint selfCenterPoint = _cardCenter;
    NSIndexPath *nextIndexPath = [self estimatedBottomCardIndexPath];

    // 新增一个cell，如果cell存在不增加
    BOOL containStatus = NO;
    for (StackCardCell *visibleCell in _visibleCells) {
        if (visibleCell.indexPath.section == nextIndexPath.section
            && visibleCell.indexPath.row == nextIndexPath.row) {
            containStatus = YES;
            break;
        }
    }
    
    if (!containStatus) {
        StackCardCell *newCell = [self dequeueReusableCell:nextIndexPath];
        [self addSubview:newCell];
        [self sendSubviewToBack:newCell];
        [self makeTargetScaleCoefficient:newCell];
        [self movedCellIntoVisiblePool:newCell];
    }
    
    NSMutableArray *newVisibleCells = [_visibleCells mutableCopy];
    NSInteger lastRow = [self numberOfRowsInSection:_preferredSection - 1];
    
    for (StackCardCell *subView in newVisibleCells) {
        CGPoint centerPoint = subView.center;
        // section 在目标范围内，以及 row也要在范围内可以滚动，超过范围不滚动
        if (subView.indexPath.section >= nextIndexPath.section) {
            if (subView.indexPath.section == nextIndexPath.section) {
                if (subView.indexPath.row >= nextIndexPath.row) {
                    if (nextIndexPath.row == lastRow - 1
                        && _visibleCells.count <= _displayCount) {
                    }else {
                        continue;
                    }
                }
            }else {
                continue;
            }
        }
        
        if ((centerPoint.x + distance) <= selfCenterPoint.x
            && centerPoint.y <= selfCenterPoint.y) {
            CGFloat x = [self rotationProportion:currentPoint];
            centerPoint.x += x;
            // 已经滑到左边了
            centerPoint.x = MIN(selfCenterPoint.x, centerPoint.x);
            subView.transform = CGAffineTransformIdentity;
            
            CGFloat k = (- M_PI_4 / 4) / (_configure.panMinimunCardCenterX - selfCenterPoint.x);
            CGFloat m = - selfCenterPoint.x * k;
            
            CGFloat rotation = centerPoint.x * k + m;
            
            CGAffineTransform rotationTransform = CGAffineTransformMakeRotation(rotation);
            subView.transform = rotationTransform;
        }else {
            if (centerPoint.x < selfCenterPoint.x) {
                centerPoint.x += [self rotationProportion:currentPoint];
                centerPoint.x = MIN(selfCenterPoint.x, centerPoint.x);
                centerPoint.x = MAX(_configure.panMinimunCardCenterX, centerPoint.x);
                subView.transform = CGAffineTransformIdentity;
            }else {
                float movedDistance = [self scaleDistanceProportion:currentPoint];
                centerPoint.y += movedDistance;
                centerPoint.y = MAX(selfCenterPoint.y, centerPoint.y);
                centerPoint.y = MIN(_lastScaleCardCenterY, centerPoint.y);
                float lastScale = 1 - [self lastCellScale];
                CGFloat scaleDistance = _lastScaleCardCenterY - selfCenterPoint.y;
                CGFloat k = -(float)lastScale / scaleDistance;
                CGFloat m = 1 - selfCenterPoint.y * k;
                float scale = centerPoint.y * k + m;
                
                CGAffineTransform scaleTransform = CGAffineTransformMakeScale(scale, scale);
                subView.transform = scaleTransform;
            }
        }
        subView.center = centerPoint;
        
        
        // 超过了直接移除
        if (subView.center.x <= _configure.panMinimunCardCenterX) {
            [self movedCellIntoCachedPools:subView];
        }
        
        if (subView.center.x >= _configure.panMinimunCardCenterX && subView.center.x <= selfCenterPoint.x
            && subView.center.y == selfCenterPoint.y) {
            _currentIndexPath = ((StackCardCell *)_visibleCells.firstObject).indexPath;
        }
        
        if (subView.indexPath.section == nextIndexPath.section &&
            subView.indexPath.row > nextIndexPath.row) {
            [self movedCellIntoCachedPools:subView];
        }
    }
}

/// 切换成功，完成剩余动画
- (void)translationSuccessedCell:(StackScrollDirection)direction {
    NSMutableArray *newVisibleCells = [_visibleCells mutableCopy];
    // 滑动过去
    if (direction == StackScrollDirectionCounterClockwise) {
        _currentIndexPath = [self nextIndexPath];
        
        for (StackCardCell *visibleCell in newVisibleCells) {
            NSComparisonResult result = [visibleCell.indexPath compare:_currentIndexPath];
            [UIView animateWithDuration:_configure.animatedDuration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                // 已经滑到左边了
                if (result == NSOrderedAscending) {
                    CGPoint centerPoint = visibleCell.center;
                    CGAffineTransform rotationTransform = CGAffineTransformMakeRotation(- M_PI_4 / 4);
                    visibleCell.center = CGPointMake(self->_configure.panMinimunCardCenterX, centerPoint.y);
                    visibleCell.transform = rotationTransform;
                }else {
                    [self makeTargetScaleCoefficient:visibleCell];
                }
            } completion:^(BOOL finished) {
                if (finished) {
                    if (result == NSOrderedAscending) {
                        // 将顶部cell移动到缓存池当中
                        [self movedCellIntoCachedPools:visibleCell];
                    }
                }
            }];
        }
    }else {
        // 上一页
        for (StackCardCell *visibleCell in newVisibleCells) {
            // 旋转
            [UIView animateWithDuration:_configure.animatedDuration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                // 已经滑到中间
                [self makeTargetScaleCoefficient:visibleCell];
            } completion:^(BOOL finished) {
                if (finished) {
                }
            }];
        }
    }
    [self selectIndexPathHandler:_currentIndexPath];
}

/// 还原
- (void)restoreCancelledCell:(StackScrollDirection)direction {
    NSMutableArray *newVisibleCells = [_visibleCells mutableCopy];
    for (StackCardCell *visibleCell in newVisibleCells) {
        NSComparisonResult result = [visibleCell.indexPath compare:self->_currentIndexPath];
        [UIView animateWithDuration:_configure.animatedDuration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            if (result == NSOrderedAscending && direction == StackScrollDirectionClockwise) {
                CGPoint centerPoint = visibleCell.center;
                CGAffineTransform rotationTransform = CGAffineTransformMakeRotation(- M_PI_4 / 4);
                visibleCell.center = CGPointMake(self->_configure.panMinimunCardCenterX, centerPoint.y);
                visibleCell.transform = rotationTransform;
                return;
            }
            [self makeTargetScaleCoefficient:visibleCell];
        } completion:^(BOOL finished) {
            if (finished) {
                if (result == NSOrderedAscending
                    && direction == StackScrollDirectionClockwise) {
                    // 将顶部cell移动到缓存池当中
                    [self movedCellIntoCachedPools:visibleCell];
                }
            }
        }];
    }
    
    [self selectIndexPathHandler:_currentIndexPath];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return ![otherGestureRecognizer.view isKindOfClass:[UIScrollView class]];
}


#pragma mark - 数据获取

/// 获取上一个卡片的坐标
- (NSIndexPath *)lastIndexPath {
//    NSInteger lastTargetSections = _currentIndexPath.section;
//    NSInteger lastTargetRows = _currentIndexPath.row;
//    if (_currentIndexPath.row >= 1) {
//        lastTargetRows = _currentIndexPath.row - 1;
//    }else {
//        if (_currentIndexPath.section > 0) {
//            lastTargetSections = _currentIndexPath.section - 1;
//            NSInteger row = [self numberOfRowsInSection:lastTargetSections];
//            lastTargetRows = row - 1;
//        }
//    }
    
    return [self estimatedLastIndexPath:_currentIndexPath];
}

/// 获取指定坐标的上一个坐标
/// @param indexPath 当前坐标
- (NSIndexPath *)estimatedLastIndexPath:(NSIndexPath *)indexPath {
    NSInteger lastTargetSections = indexPath.section;
    NSInteger lastTargetRows = indexPath.row;
    if (indexPath.row >= 1) {
        lastTargetRows = indexPath.row - 1;
    }else {
        if (indexPath.section > 0) {
            lastTargetSections = indexPath.section - 1;
            NSInteger row = [self numberOfRowsInSection:lastTargetSections];
            lastTargetRows = row - 1;
        }
    }
    
    return [NSIndexPath indexPathForRow:lastTargetRows inSection:lastTargetSections];
}

/// 获取上一组卡片的最开始的坐标(当前坐标的卡片 间距 前_displayCount 张卡片的坐标)
/// @param indexPath 当前坐标
- (NSIndexPath *)estimatedLastPageFirstIndexPath:(NSIndexPath *)indexPath {
    NSInteger lastTargetSections = indexPath.section;
    NSInteger lastTargetRows = indexPath.row;
    if (indexPath.row >= _displayCount) {
        lastTargetRows = indexPath.row - _displayCount;
    }else {
        NSInteger restCount = _displayCount - indexPath.row + 1;
        if (indexPath.section > 0) {
            lastTargetSections = indexPath.section - 1;
            for (NSInteger section = lastTargetSections; section >= 0; section--) {
                NSInteger rows = [self numberOfRowsInSection:section];
                if (restCount - rows < 0) {
                    lastTargetRows = rows - restCount;
                    break;
                }else {
                    restCount = restCount - rows;
                }
            }
            
            // 表示到(0, 0)的卡片不足_displayCount张卡片
            if (restCount != 0) {
                lastTargetRows = 0;
                lastTargetSections = 0;
            }
        }else {
            lastTargetRows = 0;
            lastTargetSections = 0;
        }
    }
    
    return [NSIndexPath indexPathForRow:lastTargetRows inSection:lastTargetSections];
}

/// 根据当前显示的indexPath获取下一个卡片的坐标
- (NSIndexPath *)nextIndexPath {
    return [self estimatedNextPath:_currentIndexPath];
}

- (NSIndexPath *)estimatedNextPath:(NSIndexPath *)currentIndexPath {
    NSInteger nextTargetSections = currentIndexPath.section;
    NSInteger nextTargetRows = currentIndexPath.row;
    
    if (nextTargetSections < (_preferredSection - 1)) {
        if (nextTargetRows + 1 < [self numberOfRowsInSection:nextTargetSections]) {
            nextTargetRows += 1;
        }else {
            nextTargetSections += 1;
            nextTargetRows = 0;
        }
    }else if (nextTargetSections == _preferredSection - 1) {
        if (nextTargetRows + 1 < [self numberOfRowsInSection:nextTargetSections]) {
            nextTargetRows += 1;
        }
    }
    
    return [NSIndexPath indexPathForRow:nextTargetRows inSection:nextTargetSections];
}

/// 当前显示卡片组中再插入一张卡片到最底层所在的坐标位置
- (NSIndexPath *)estimatedBottomCardIndexPath {
    NSInteger nextTargetSections = 0;
    NSInteger nextTargetRows = 0;
    NSInteger count = 0;
    for (NSInteger sectionIndex = _currentIndexPath.section; sectionIndex < _preferredSection; sectionIndex++) {
        NSInteger originRows = [self numberOfRowsInSection:sectionIndex];
        NSInteger rows = originRows;
        if (sectionIndex == _currentIndexPath.section) {
            rows -= (_currentIndexPath.row + 1);
        }

        count += rows;
        if (count >= _displayCount) {
            count -= rows;
            count = _displayCount - count;
            nextTargetRows = count - 1;
            if (sectionIndex == _currentIndexPath.section) {
                nextTargetRows += (_currentIndexPath.row + 1);
            }
            break;
        }

        nextTargetSections += 1;
        if ((nextTargetSections + _currentIndexPath.section) >= _preferredSection) {
            nextTargetSections -= 1;
            nextTargetRows = originRows - 1;
            break;
        }
    }

    nextTargetSections += _currentIndexPath.section;

    return [NSIndexPath indexPathForRow:nextTargetRows inSection:nextTargetSections];
}

#pragma mark 显示个数获取
- (NSInteger)numberOfDisplayingCards {
    if (_stackDelegate && [_stackDelegate respondsToSelector:@selector(numberOfDisplayingCards)]) {
        self.displayCount = [_stackDelegate numberOfDisplayingCards];
    }else {
        self.displayCount = 3;
    }
    
    return self.displayCount;
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section {
    return [_stackDelegate stackCardView:self numberOfItemsInSection:section];
}

- (NSInteger)sections {
    if (_stackDelegate && [_stackDelegate respondsToSelector:@selector(numberOfSectionsInStackCard:)]) {
        return [_stackDelegate numberOfSectionsInStackCard:self];
    }
    
    return 1;
}

#pragma mark 卡片切换

- (void)selectIndexPathHandler:(NSIndexPath *)indexPath {
    if (_stackDelegate && [_stackDelegate respondsToSelector:@selector(stackCardView:didSelectAtIndexPath:)]) {
        return [_stackDelegate stackCardView:self didSelectAtIndexPath:indexPath];
    }
}

#pragma mark cell获取
- (StackCardCell *)dequeueReusableCell:(NSIndexPath *)targetIndexPath {
    StackCardCell *cell = [_stackDelegate stackCardsView:self cellForCurrentIndexPath:targetIndexPath];
    
    return cell;
}

#pragma mark 每个卡片垂直方向上的偏移量
- (CGFloat)cardOffsetFromDelegate {
    if (_stackDelegate && [_stackDelegate respondsToSelector:@selector(distanceOfPerCellOffset:)]) {
        return [_stackDelegate distanceOfPerCellOffset:self];
    }
    
    return 10;
}

#pragma mark 卡片的尺寸(通过设置卡片的内边距来确定卡片的大小)
- (UIEdgeInsets)paddingInsets {
    if (_stackDelegate && [_stackDelegate respondsToSelector:@selector(edgeInsetsForCell:)]) {
        return [_stackDelegate edgeInsetsForCell:self];
    }
    return UIEdgeInsetsMake(35, 35, 35, 35);
}

- (CGRect)cellFrame {
    UIEdgeInsets inset = [self paddingInsets];
    
    return CGRectMake(inset.left, inset.top, self.bounds.size.width - inset.left - inset.right, self.bounds.size.height - inset.top - inset.bottom);
}


#pragma mark 视图缩放参数动态计算

/// 旋转的角度
/// @param point 当前滑动的点
- (float)rotationProportion:(CGPoint)point {
    CGFloat currentMovedDistance = point.x - panPreviousPoint.x;
    // y = k * x + m
    CGFloat touchMovedDistance = CGRectGetWidth(self.bounds);
    CGFloat maxCardPointCenterX = CGRectGetWidth(self.bounds) / 2;
    CGFloat minCardPointCenterX = _configure.panMinimunCardCenterX;

    float k = -(float)(minCardPointCenterX - maxCardPointCenterX) / touchMovedDistance;
    
    float y = k * currentMovedDistance;
    
    return y;
}

/// 卡片缩放的程度
/// @param point 当前手势滑动的点，手势触发所在的点
- (float)scaleDistanceProportion:(CGPoint)point {
    CGFloat currentMovedDistance = point.x - panPreviousPoint.x;
    
    CGRect frame = [self cellFrame];
    CGFloat targetOffset = [self cardOffsetFromDelegate] * 2;
    float scale = [self lastCellScale];
    CGFloat scaleHeight = CGRectGetHeight(frame) / 2 * scale; // 缩放后的高度
    CGFloat maxCardMovedDistance = (float)CGRectGetHeight(frame) / 2 - scaleHeight + targetOffset;
    CGFloat touchMovedDistance = CGRectGetWidth(self.bounds);
    
    float k = (float)maxCardMovedDistance / (touchMovedDistance * 2);
    
    return (float)currentMovedDistance * k;
}


/// 最后一个卡片缩放的程度，默认.7
- (float)lastCellScale {
    if (_stackDelegate && [_stackDelegate respondsToSelector:@selector(lastCellScaleForCards:)]) {
        return [_stackDelegate lastCellScaleForCards:self];
    }
    
    return .7;
}


- (BOOL)canSwipe:(UIPanGestureRecognizer *)panGesture direction:(StackScrollDirection)direction {
    if (!_configure.panGestureEnable) {
        return NO;
    }
    if (_stackDelegate && [_stackDelegate respondsToSelector:@selector(stackCardView:shouldSwipeCell:atIndexPath:direction:)]) {
        return [_stackDelegate stackCardView:self shouldSwipeCell:_visibleCells.firstObject atIndexPath:_currentIndexPath direction:direction];
    }
    
    return YES;
}


#pragma mark - public
- (void)loadNextCard {
    if (![self canSwipe:_panGesture direction:StackScrollDirectionCounterClockwise]) {
        return;
    }
    
    if (_status == StackCardLoadStatusPreviousCard) {
        return;
    }
    
    _status = StackCardLoadStatusNextCard;
    

    [self selectIndexPath:[self nextIndexPath] animated:YES];
    _status = StackCardLoadStatusNone;
}

- (void)loadPreviousCard {
    if (![self canSwipe:_panGesture direction:StackScrollDirectionClockwise]) {
        return;
    }
    
    if (_status == StackCardLoadStatusNextCard) {
        return;
    }
    _status = StackCardLoadStatusPreviousCard;

    [self selectIndexPath:[self lastIndexPath] animated:YES];
    _status = StackCardLoadStatusNone;
}

/// 单纯的收起卡片
- (void)shrinkCards:(BOOL)animated {
    for (StackCardCell *currentCell in _visibleCells) {
        [currentCell.layer removeAllAnimations];
        [UIView animateWithDuration:animated ? _configure.animatedDuration : 0 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            currentCell.transform = CGAffineTransformIdentity;
            currentCell.center = self->_cardCenter;
        } completion:nil];
    }
}

/// 将cell移动到缓存池中，回收当前不显示的cell
/// @param cell 待移动的cell
- (void)movedCellIntoCachedPools:(StackCardCell *)cell {
    if ([_visibleCells containsObject:cell]) {
        [_visibleCells removeObject:cell];
    }
//    MJRefreshLog(@"移除的坐标%p: [%ld, %ld]", cell, cell.indexPath.section, cell.indexPath.row);
    NSMutableArray *cachedPool = [_registReuslableCellPools[cell.identifier] mutableCopy];
    [cachedPool addObject:cell];
    [cell removeFromSuperview];
    _registReuslableCellPools[cell.identifier] = cachedPool;
}

/// 将cell移动到可视的数组中
/// @param cell 待移动的cell
- (void)movedCellIntoVisiblePool:(StackCardCell *)cell {
    if (![_visibleCells containsObject:cell]) {
        [_visibleCells addObject:cell];
    }
    [_visibleCells sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        StackCardCell *firstCell = (StackCardCell *)obj1;
        StackCardCell *lastCell = (StackCardCell *)obj2;
        return [firstCell.indexPath compare:lastCell.indexPath];
    }];
}

- (void)registerClass:(Class)stackCellClass reusableIdentifer:(NSString *)reusableIdentifier {
    if (reusableIdentifier
        && reusableIdentifier.length > 0
        && stackCellClass) {
        [_registClassDictionary setObject:stackCellClass forKey:reusableIdentifier];
        [_registReuslableCellPools setObject:@[] forKey:reusableIdentifier];
    }
}

- (StackCardCell *)dequeueReusableIdentifier:(NSString *)reusableIdentifier indexPath:(NSIndexPath *)indexPath {
    
    Class cellClass = [_registClassDictionary objectForKey:reusableIdentifier];
    NSMutableArray *reusableCellPool = [_registReuslableCellPools[reusableIdentifier] mutableCopy];
    if (reusableCellPool.count > 0) {
        StackCardCell *cell = reusableCellPool.firstObject;
        cell.indexPath = indexPath;
        [reusableCellPool removeObject:cell];
        _registReuslableCellPools[reusableIdentifier] = reusableCellPool;
        
        return cell;
    }
    
    if ([[cellClass new] isKindOfClass:[StackCardCell class]]) {
        StackCardCell *cell = [cellClass initWithIdentifer:reusableIdentifier atIndexPath:indexPath frame:[self cellFrame]];

        return cell;
    }
    
    return nil;
}

- (void)makeTargetScaleCoefficient:(StackCardCell *)cell {
    CGPoint selfCenterPoint = _cardCenter;
    NSIndexPath *index = cell.indexPath;
    NSComparisonResult result = [index compare:_currentIndexPath];
    if (result == NSOrderedAscending) {
        CGAffineTransform rotationTransform = CGAffineTransformMakeRotation(- M_PI_4 / 4);
        selfCenterPoint.x = _configure.panMinimunCardCenterX;
        cell.transform = rotationTransform;
        cell.center = selfCenterPoint;
        cell.contentView.alpha = 1;
        return;
    }else {
        CGRect frame = [self cellFrame];
        NSInteger distanceCount = index.row;
        if (index.section == _currentIndexPath.section) {
            distanceCount = labs(index.row - _currentIndexPath.row);
        }else {
            for (NSInteger startSection = _currentIndexPath.section; startSection < index.section; startSection++) {
                NSInteger targetRows = [self numberOfRowsInSection:startSection];
                if (startSection == _currentIndexPath.section) {
                    targetRows -= _currentIndexPath.row;
                }
                distanceCount += targetRows;
            }
        }
        
        NSInteger indexDistance = distanceCount;
        NSInteger targetDisplayCount = [self numberOfDisplayingCards];
        indexDistance = MIN(indexDistance, targetDisplayCount - 1);
        cell.contentView.alpha = indexDistance > 1 ? 0 : 1;
        CGFloat targetOffset = [self cardOffsetFromDelegate] * indexDistance;
        float scaleDistance = (float)(1 - [self lastCellScale]) / (targetDisplayCount - 1);
        
        float scale = 1 - scaleDistance * indexDistance;
        scale = MAX([self lastCellScale], scale);
        CGFloat scaleHeight = CGRectGetHeight(frame) / 2 * scale; // 缩放后的高度
        CGFloat targetCenterY = selfCenterPoint.y + CGRectGetHeight(frame) / 2 - scaleHeight + targetOffset;
        CGAffineTransform scaleTransform = CGAffineTransformMakeScale(scale, scale);
        cell.transform = scaleTransform;
        selfCenterPoint.y = targetCenterY;
        cell.center = selfCenterPoint;
    }
}

- (void)reloadData {
    [self initialParameters];
    
    NSInteger count = 0;
    
    for (NSInteger sectionIndex = 0; sectionIndex < _preferredSection; sectionIndex++) {
        NSInteger row = [self numberOfRowsInSection:sectionIndex];
        count += row;
        
        if (sectionIndex == _currentIndexPath.section) {
            if (_currentIndexPath.row >= row) {
                _currentIndexPath = [NSIndexPath indexPathForRow:row - 1 inSection:sectionIndex];
            }
        }else if (sectionIndex == _preferredSection - 1) {
            if (_currentIndexPath.section >= sectionIndex) {
                _currentIndexPath = [NSIndexPath indexPathForRow:0 inSection:sectionIndex];
            }
        }
    }
    
    _configure.empty = count == 0;
    _panGesture.enabled = !_configure.empty;
    
    if (_configure.empty) {
        _currentIndexPath = nil;
    }
    
    NSMutableArray *mutVisibleArray = [_visibleCells mutableCopy];
    // 移除数据
    for (StackCardCell *visibleCell in mutVisibleArray) {
        [self movedCellIntoCachedPools:visibleCell];
    }
    
    if (!_configure.empty){
        NSInteger currentIndex = 0;

        for (int section = (int)_currentIndexPath.section; section < _preferredSection; section ++) {
            NSInteger rows = [self numberOfRowsInSection:section];
            NSInteger startIndex = 0;
            if (section == _currentIndexPath.section) {
                startIndex = _currentIndexPath.row;
            }
            
            for (NSInteger row = startIndex; row < rows; row ++) {
                if (currentIndex > _displayCount) {
                    break;
                }
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
                StackCardCell *cell = [self dequeueReusableCell:indexPath];
                [self addSubview:cell];
                [self sendSubviewToBack:cell];
                [self makeTargetScaleCoefficient:cell];
                [self movedCellIntoVisiblePool:cell];
                currentIndex++;
            }
            
            if (currentIndex > _displayCount) {
                break;
            }
        }
    }
}

- (void)scrollToLastIndexPath {
    NSInteger rows = [self numberOfRowsInSection:_preferredSection - 1];
    [self selectIndexPath:[NSIndexPath indexPathForRow:rows - 1 inSection:_preferredSection - 1] animated:YES];
}

- (void)selectIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated {
    // 确保index不会超出范围
    if (indexPath.section >= _preferredSection) {
        NSInteger rows = [self numberOfRowsInSection:_preferredSection - 1];
        indexPath = [NSIndexPath indexPathForRow:rows - 1 inSection:_preferredSection - 1];
    }else {
        NSInteger targetRows = [self numberOfRowsInSection:indexPath.section];
        if (indexPath.row >= targetRows) {
            indexPath = [NSIndexPath indexPathForRow:targetRows - 1 inSection:indexPath.section];
        }
    }
    
    NSComparisonResult result = [indexPath compare:_currentIndexPath];
    // 在当前显示的卡片前面
    if (result == NSOrderedAscending) {
        NSInteger totalCount = 0;
        if (indexPath.section == _currentIndexPath.section) {
            totalCount = _currentIndexPath.row - indexPath.row;
        }else {
            for (NSInteger startSection = indexPath.section; startSection <= _currentIndexPath.section; startSection ++) {
                NSInteger currentRows = [self numberOfRowsInSection:startSection];
                if (startSection == indexPath.section) {
                    currentRows -= (indexPath.row + 1);
                }
                
                if (startSection == _currentIndexPath.section) {
                    currentRows = _currentIndexPath.row + 1;
                }
                
                totalCount += currentRows;
            }
        }
        
        NSInteger newCellCount = MIN(totalCount, _displayCount + 1);

        // 新增cell
        for (NSInteger newIndex = newCellCount; newIndex > 0; newIndex--) {
            NSInteger restCount = newIndex;
            NSInteger targetSection = indexPath.section;
            NSInteger targetRow = indexPath.row;
            if (indexPath.section == _currentIndexPath.section) {
                targetRow = indexPath.row + newIndex - 1;
            }else {
                for (NSInteger startSection = indexPath.section; startSection <= _currentIndexPath.section; startSection ++) {
                    NSInteger currentRows = [self numberOfRowsInSection:startSection];
                    if (startSection == indexPath.section) {
                        currentRows -= indexPath.row;
                    }
                    
                    if (restCount > currentRows) {
                        // 在下一个section
                        restCount = restCount - currentRows;
                        targetSection += 1;
                        continue;
                    }
                    targetRow = restCount - 1;
                    if (startSection == indexPath.section) {
                        targetRow += indexPath.row;
                    }
                    break;
                }
            }
            
            NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:targetRow inSection:targetSection];
            BOOL contained = NO;
            for (StackCardCell *currentCell in _visibleCells) {
                NSComparisonResult result = [currentCell.indexPath compare:newIndexPath];
                if (result == NSOrderedSame) {
                    contained = YES;
                    break;
                }
            }
            if (!contained) {
                StackCardCell *cell = [self dequeueReusableCell:newIndexPath];
                [self addSubview:cell];
                [self bringSubviewToFront:cell];
                cell.transform = CGAffineTransformMakeRotation(- M_PI_4 / 4);
                cell.center = CGPointMake(_configure.panMinimunCardCenterX, _cardCenter.y);
                [self movedCellIntoVisiblePool:cell];
            }
        }
        
        // 移除多余的cell
        NSMutableArray *array = [_visibleCells mutableCopy];
        _currentIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
        
        for (StackCardCell *cell in array) {
            NSIndexPath *bottomIndexPath = [self estimatedBottomCardIndexPath];
            NSComparisonResult cardResult = [cell.indexPath compare:bottomIndexPath];
            if (animated) {
                [UIView animateWithDuration:_configure.animatedDuration delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                    [self makeTargetScaleCoefficient:cell];
                } completion:^(BOOL finished) {
                    if (finished) {
                        if (cardResult == NSOrderedDescending) {
                            //                        MJRefreshLog(@"最后一张卡片坐标(%ld, %ld)", bottomIndexPath.section, bottomIndexPath.row);
                            [self movedCellIntoCachedPools:cell];
                        }
                    }
                }];
            }else {
                [self makeTargetScaleCoefficient:cell];
                if (cardResult == NSOrderedDescending) {
                    [self movedCellIntoCachedPools:cell];
                }
            }
        }
    }else if (result == NSOrderedDescending) {
        // 在当前显示卡片的后面
        
        // 新增cell
        NSInteger totalCount = 0;
        
        NSIndexPath *currentBottomIndexPath = ((StackCardCell *)_visibleCells.lastObject).indexPath;
        
        if (indexPath.section == _currentIndexPath.section) {
            totalCount = labs(_currentIndexPath.row - indexPath.row);
        }else {
            for (NSInteger startSection = _currentIndexPath.section; startSection <= indexPath.section; startSection ++) {
                NSInteger currentRows = [self numberOfRowsInSection:startSection];
                if (startSection == _currentIndexPath.section) {
                    currentRows -= (_currentIndexPath.row + 1);
                }
                
                if (startSection == indexPath.section) {
                    currentRows = indexPath.row + 1;
                }
                
                totalCount += currentRows;
            }
        }
        
        NSInteger diffCount = totalCount - _displayCount;
        
        
        // 滑动在_displayCount个卡片以后,需要新增_displayCount个卡片在最底部，并且移除当前所显示的所有卡片
        NSIndexPath *startIndexPath = [self estimatedLastIndexPath:indexPath];
        NSInteger targetCount = _displayCount + 1;
        if (diffCount < 0) {
            // 滑动在_displayCount个以内, 移除totalCount卡片，并且新增totalcount卡片
            targetCount = totalCount;
            startIndexPath = [NSIndexPath indexPathForRow:currentBottomIndexPath.row inSection:currentBottomIndexPath.section];
        }
        
        for (NSInteger newIndex = 1; newIndex <= targetCount; newIndex++) {
            // 计算出目标的坐标
            NSInteger targetSection = startIndexPath.section;
            NSInteger targetRow = startIndexPath.row;
            NSInteger restCount = newIndex;
            for (NSInteger endSection = startIndexPath.section; endSection < _preferredSection; endSection++) {
                targetSection = endSection;
                NSInteger endRows = [self numberOfRowsInSection:endSection];
                if (endSection == startIndexPath.section) {
                    endRows -= (startIndexPath.row + 1);
                }
                
                if (restCount <= endRows) {
                    targetRow = restCount - 1;
                    if (endSection == startIndexPath.section) {
                        targetRow = startIndexPath.row + restCount;
                    }
                    break;
                }
                
                restCount -= endRows;
            }
                            
            NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:targetRow inSection:targetSection];
            BOOL contained = NO;
            for (StackCardCell *currentCell in _visibleCells) {
                NSComparisonResult result = [currentCell.indexPath compare:newIndexPath];
                if (result == NSOrderedSame) {
                    contained = YES;
                    break;
                }
            }
            if (!contained) {
                StackCardCell *cell = [self dequeueReusableCell:newIndexPath];
                [self addSubview:cell];
                [self sendSubviewToBack:cell];
                [self makeTargetScaleCoefficient:cell];
                [self movedCellIntoVisiblePool:cell];
            }
        }
        
        // 添加移动动画，并且移除多余的视图
        NSMutableArray *array = [_visibleCells mutableCopy];
        _currentIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
        
        for (StackCardCell *currentCell in array) {
            NSComparisonResult cardResult = [currentCell.indexPath compare:self->_currentIndexPath];
            if (animated) {
                [UIView animateWithDuration:_configure.animatedDuration delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                    [self makeTargetScaleCoefficient:currentCell];
                } completion:^(BOOL finished) {
                    if (cardResult == NSOrderedAscending) {
                        [self movedCellIntoCachedPools:currentCell];
                    }
                }];
            }else {
                [self makeTargetScaleCoefficient:currentCell];
                if (cardResult == NSOrderedAscending) {
                    [self movedCellIntoCachedPools:currentCell];
                }
            }
        }
    }
    
    [self selectIndexPathHandler:_currentIndexPath];
}

- (void)removeIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    
}

- (void)removeItemsInSection:(NSInteger)section {
    if (section < 0 || section >= _preferredSection) {
        return;
    }
    
    [self initialParameters];

    // 移除当前所有的超过当前section的cell
    NSMutableArray *newVisibleCells = [_visibleCells mutableCopy];
    for (StackCardCell *currentCell in newVisibleCells) {
        if (currentCell.indexPath.section >= section) {
            [self movedCellIntoCachedPools:currentCell];
        }else {
            continue;
        }
    }
    
    if (_visibleCells.count > 0) {
        NSIndexPath *lastPageIndexPath = [self estimatedLastPageFirstIndexPath:_visibleCells.lastObject.indexPath];
        [self selectIndexPath:lastPageIndexPath animated:YES];
        
        // 还有cell，直接补全剩下的cell
        NSInteger restCount = _displayCount - _visibleCells.count + 1;
        if (restCount > 0) {
            NSIndexPath *nextIndexPath = _visibleCells.lastObject.indexPath;
            for (NSInteger i = 0; i < restCount; i++) {
                nextIndexPath = [self estimatedNextPath:nextIndexPath];
                BOOL contained = NO;
                for (StackCardCell *currentCell in _visibleCells) {
                    NSComparisonResult result = [currentCell.indexPath compare:nextIndexPath];
                    if (result == NSOrderedSame) {
                        contained = YES;
                        break;
                    }
                }
                if (!contained) {
                    StackCardCell *cell = [self dequeueReusableCell:nextIndexPath];
                    [self addSubview:cell];
                    [self sendSubviewToBack:cell];
                    [self movedCellIntoVisiblePool:cell];
                    [UIView animateWithDuration:_configure.animatedDuration delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                        [self makeTargetScaleCoefficient:cell];
                    } completion:^(BOOL finished) {
                    }];
                }
            }
        }
    }else {
        if (section >= _preferredSection - 1
            && section != 0) {
            // 填补上一个section
            NSInteger rows = [self numberOfRowsInSection:_preferredSection - 1];
            NSIndexPath *estimatedPageIndex = [self estimatedLastPageFirstIndexPath:[NSIndexPath indexPathForRow:rows - 1 inSection:_preferredSection - 1]];
            [self selectIndexPath:estimatedPageIndex animated:YES];
        }else {
            NSInteger currentIndex = 0;
            for (int sectionIndex = (int)section; sectionIndex < _preferredSection; sectionIndex ++) {
                NSInteger rows = [self numberOfRowsInSection:sectionIndex];
                NSInteger startIndex = 0;
                if (sectionIndex == _currentIndexPath.section) {
                    startIndex = _currentIndexPath.row;
                }
                for (NSInteger row = startIndex; row < rows; row ++) {
                    if (currentIndex > _displayCount) {
                        break;
                    }
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:sectionIndex];
                    StackCardCell *cell = [self dequeueReusableCell:indexPath];
                    [self addSubview:cell];
                    [self sendSubviewToBack:cell];
                    [UIView animateWithDuration:_configure.animatedDuration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                        [self makeTargetScaleCoefficient:cell];
                    } completion:nil];
                    [self movedCellIntoVisiblePool:cell];
                    currentIndex++;
                }
                
                if (currentIndex > _displayCount) {
                    break;
                }
            }
            [self selectIndexPathHandler:_currentIndexPath];
        }

    }
}


#pragma mark - getter
- (UIPanGestureRecognizer *)panGesture {
    if (!_panGesture) {
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pangeGestureHandler:)];
        _panGesture.delegate = self;
    }
    
    return _panGesture;
}

- (StackCardCell *)selectedCell {
    return _visibleCells.firstObject;
}

@end
