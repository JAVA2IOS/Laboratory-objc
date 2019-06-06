//
//  StackCardsViewController.m
//  Laboratory-objc
//
//  Created by qeeniao35 on 2019/5/29.
//  Copyright © 2019 CodeZ. All rights reserved.
//

#import "StackCardsViewController.h"

#import "StackCardslayout.h"

#import "TABCardView.h"
#import "CardView.h"

#import "TABDefine.h"

#import "StackCardView.h"

@interface StackCardsViewController ()<TABCardViewDelegate, StackCardViewDelegate>
@property (nonatomic,strong) TABCardView * cardView;
@property (nonatomic,strong) StackCardView *customCards;
@end

@implementation StackCardsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = LabColor(@"ffffff");

    _customCards = [[StackCardView alloc] initWithFrame:CGRectMake(40, self.labNavgationBar.labBottom + 10, self.view.labWidth - 80, self.view.labWidth - 80)];
    [self.view addSubview:_customCards];
    _customCards.stackDelegate = self;
    [_customCards reloadCardsView];
    
    UIButton *previousButton = [UIButton lab_initButtonTitile:@"上一张" fontSize:16 titleColor:[UIColor blackColor] backgroundColor:[UIColor whiteColor]];
    previousButton.frame = CGRectMake(10, _customCards.labBottom + 20, 100, 50);
    [self.view addSubview:previousButton];
    [previousButton addTarget:self action:@selector(previousCard) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *nextButton = [UIButton lab_initButtonTitile:@"下一张" fontSize:16 titleColor:[UIColor blackColor] backgroundColor:[UIColor whiteColor]];
    nextButton.frame = CGRectMake(self.view.labWidth - 110, _customCards.labBottom + 20, 100, 50);
    [self.view addSubview:nextButton];
    [nextButton addTarget:self action:@selector(next) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *refreshButton = [UIButton lab_initButtonTitile:@"刷新" fontSize:16 titleColor:[UIColor blackColor] backgroundColor:[UIColor whiteColor]];
    refreshButton.frame = CGRectMake(self.view.labWidth - 110, previousButton.labBottom + 20, 100, 50);
    [self.view addSubview:refreshButton];
    [refreshButton addTarget:self action:@selector(refreshCards) forControlEvents:UIControlEventTouchUpInside];
    /*
     self.cardView = [[TABCardView alloc] initWithFrame:CGRectMake(40, nextButton.labBottom, kScreenWidth - 120, 320)
     showCardsNumber:4];
     self.cardView.isShowNoDataView = YES;
     self.cardView.noDataView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"占位图"]];
     self.cardView.offsetY = 10;
     self.cardView.offsetX = 0;
     self.cardView.delegate = self;
     [self.view addSubview:self.cardView];
     // 模拟请求数据
     */
    [self performSelector:@selector(getData) withObject:nil afterDelay:3.0];

}

- (void)refreshCards {
    [_customCards reloadCardsView];
}

- (void)next {
//    [_customCards selectIndex:10 animated:YES];
//    [_customCards loadPreviousCard];
    [_customCards loadNextCard];
}

- (void)previousCard {
    [_customCards loadPreviousCard];
}

- (StackCardCell *)stackCardsView:(StackCardView *)cardView cellForCurrentIndex:(NSInteger)index displayIndex:(NSInteger)displayIndex {
    StackCardCell *cell = [cardView cellForIndex:index atDisplayIndex:displayIndex];
    cell.label.text = [NSString stringWithFormat:@"%ld", index];
    
    return cell;
}

- (NSInteger)numberOfCardsDataForCards:(StackCardView *)cardsView {
    return 20;
}

- (NSInteger)numberOfDisplayingCards {
    return 3;
}

- (UIEdgeInsets)edgeInsetsForCell:(StackCardView *)cardsView {
    return UIEdgeInsetsMake(10, 10, 50, 10);
}

- (CGFloat)distanceOfCellOffset:(StackCardView *)cardsView {
    return 20;
}

- (CGFloat)lastCellAlphaForCards:(StackCardView *)cardsView {
    return .3;
}

#pragma mark - Target Method

- (void)getData {
    [_customCards selectIndex:2 animated:NO];
//
//    NSMutableArray *array = [[NSMutableArray alloc] init];
//    for (int i = 0; i < 10; i ++) {
//        CardView *view = [[CardView alloc] init];
//        [view updateViewWithData:[NSString stringWithFormat:@"%d.jpg",i+1]];
//        view.clickBlock = ^{
//            NSLog(@"点击了卡片");
//        };
//        [array addObject:view];
//    }
//    [self.cardView loadCardViewWithData:array];
}

#pragma mark - TABCardViewDelegate

- (void)tabCardViewCurrentIndex:(NSInteger)index {
    NSLog(@"当前处于卡片数组下标:%ld",(long)index);
}
/*
 StackCardslayout *layout = [[StackCardslayout alloc] init];
 //    layout.itemSize = CGSizeMake(500, 500);
 
 UICollectionView *collection = [[UICollectionView alloc] initWithFrame:CGRectMake(0, LABNavBarHeight, SCREENWIDTH, SCREENHEIGHT - LABNavBarHeight) collectionViewLayout:layout];
 collection.delegate = self;
 collection.dataSource = self;
 [collection registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"hhdd"];
 collection.backgroundColor = [UIColor whiteColor];
 
 [self.view addSubview:collection];
 }
 
 - (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
 return CGSizeMake(collectionView.labWidth, collectionView.labWidth);
 }
 
 - (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
 UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"hhdd" forIndexPath:indexPath];
 cell.backgroundColor = [UIColor randomColor];
 
 return cell;
 }
 
 - (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
 return 4;
 }
 */

@end
