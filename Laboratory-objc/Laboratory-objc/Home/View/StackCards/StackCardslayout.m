//
//  StackCardslayout.m
//  Laboratory-objc
//
//  Created by qeeniao35 on 2019/5/29.
//  Copyright © 2019 CodeZ. All rights reserved.
//

#import "StackCardslayout.h"

@interface StackCardslayout()
@property (nonatomic, retain) NSMutableArray *cardsItems;
@end

@implementation StackCardslayout
//- (void)prepareLayout {
//    _cardsItems = [[NSMutableArray alloc] init];
//    NSInteger sections = [self.collectionView numberOfSections];
//
//    for (NSInteger sectionIndex = 0; sectionIndex < sections; sectionIndex ++) {
//        NSInteger rows = [self.collectionView numberOfItemsInSection:sectionIndex];
//        for (NSInteger rowIndex = 0; rowIndex < rows; rowIndex ++) {
//          UICollectionViewLayoutAttributes *attrites = [self.collectionView layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex]];
//            [_cardsItems addObject:attrites];
//        }
//    }
//
//    [self updateCardsFrames];
//}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray *cards = [super layoutAttributesForElementsInRect:rect];
    
    for (UICollectionViewLayoutAttributes *attrites in cards) {
        UIEdgeInsets sectionInset = UIEdgeInsetsZero;
        
        
        // 缩放
        NSIndexPath *indexPath = attrites.indexPath;
        
        if (indexPath.row < 3) {
            attrites.zIndex = - indexPath.row;
            float scale = 1 - (float)indexPath.row / 20;
            attrites.frame = CGRectMake(sectionInset.left, sectionInset.top + 10 * indexPath.row + attrites.frame.size.height * (1 - scale), attrites.frame.size.width, attrites.frame.size.height);
            
            attrites.transform = CGAffineTransformMakeScale(scale, scale);
            attrites.alpha = 1;
        }else {
            attrites.frame = CGRectMake(sectionInset.left, sectionInset.top, attrites.frame.size.width, attrites.frame.size.height);
//            attrites.alpha = 0;
        }
        
        NSLog(@"当前坐标y:%f", attrites.frame.origin.y);
    }
    
    return cards;
}


//- (void)updateCardsFrames {
//    for (UICollectionViewLayoutAttributes *attrites in _cardsItems) {
//
//    }
//}

@end
