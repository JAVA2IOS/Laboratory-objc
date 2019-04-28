//
//  StackCardView.m
//  Laboratory-objc
//
//  Created by qeeniao35 on 2019/4/28.
//  Copyright © 2019 CodeZ. All rights reserved.
//

#import "StackCardView.h"
#import "StackCardCell.h"

@interface StackCardView()
/**
 卡片视图的缓存池，用来复用，显示的时候取出来，消失的时候加入到缓存池中
 */
@property (nonatomic, retain) NSMutableArray *cachedCardsPool;
/**
 缓存的卡片数据
 */
@property (nonatomic, retain) NSMutableArray *cachedCardsData;
/**
 显示卡片个数
 */
@property (nonatomic, assign) NSInteger displayCount;

@end

@implementation StackCardView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
    }
    
    return self;
}

- (void)loadCards {
    
}

/**
 缩放当前的cell视图

 @param cell 当前显示的cell
 @param index 当前所在的序号
 @param displayIndex 显示的序号
 */
- (void)makeScaleForCurrentCards:(StackCardCell *)cell atIndex:(NSInteger)index displayIndex:(NSInteger)displayIndex {
    CGAffineTransformMakeScale(1, 1);
//   cell.transform =
}


- (void)stackCachedCardsData {
    if (!_cachedCardsData) {
        _cachedCardsData = [[NSMutableArray alloc] init];
    }
    NSArray *newCards = [_stackDelegate currentCardsDataForCards:self];
    [_cachedCardsData addObjectsFromArray:newCards];
}

- (void)numberOfDisplayingCards {
    if (_stackDelegate && [_stackDelegate respondsToSelector:@selector(numberOfDisplayingCards)]) {
        self.displayCount = [_stackDelegate numberOfDisplayingCards];
    }else {
        self.displayCount = 3;
    }
}

@end
