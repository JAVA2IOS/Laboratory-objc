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
/**
 缓存的卡片数据
 */
@property (nonatomic, assign) NSInteger cachedCardsData;
/**
 显示卡片个数
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
        [self selectIndex:_currentDisplayIndex animated:YES];
    }
    
    return self;
}

- (void)reloadCardsView {
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self numberOfDisplayingCards];
    [self stackCachedCardsData];
    [self selectIndex:_currentDisplayIndex animated:YES];
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
    float scale = [self scaleForCurrentCenter:center];
    cell.center = CGPointMake(center.x, center.y + cell.labHeight / 2 * (1 - scale));
    cell.transform = CGAffineTransformMakeScale(scale, scale);
    NSLog(@"center.y %f", cell.center.y);
}


- (void)stackCachedCardsData {
    _cachedCardsData = [_stackDelegate numberOfCardsDataForCards:self];
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
    cell.frame = self.bounds;
    
    return cell;
}

- (float)scaleForCurrentCenter:(CGPoint)center {
    float distance = (center.y - self.bounds.size.height / 2);
    NSLog(@"距离%f", distance);
    float scale = 1 - (float)distance / 20;
    
    return scale;
}

@end
