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
    
    _customCards = [[StackCardView alloc] initWithFrame:CGRectMake(0, self.labNavgationBar.labBottom, self.view.labWidth, self.view.labWidth)];
    [self.view addSubview:_customCards];
    _customCards.stackDelegate = self;
    [_customCards reloadCardsView];
    
//    self.view.backgroundColor = kBackColor;
//
//
//
//    self.cardView = [[TABCardView alloc] initWithFrame:CGRectMake(40, (kScreenHeight - 320)/2, kScreenWidth - 120, 320)
//                                       showCardsNumber:4];
//    self.cardView.isShowNoDataView = YES;
//    self.cardView.noDataView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"占位图"]];
//    self.cardView.delegate = self;
//    [self.view addSubview:self.cardView];
//
//    // 模拟请求数据
//    [self performSelector:@selector(getData) withObject:nil afterDelay:3.0];
}

- (StackCardCell *)stackCardsView:(StackCardView *)cardView cellForCurrentIndex:(NSInteger)index {
    StackCardCell *cell = [cardView cellForIndex:index reusableIdentifier:@"hahha"];
    
    return cell;
}

- (NSInteger)numberOfCardsDataForCards:(StackCardView *)cardsView {
    return 5;
}

#pragma mark - Target Method

- (void)getData {
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i = 0; i < 10; i ++) {
        CardView *view = [[CardView alloc] init];
        [view updateViewWithData:[NSString stringWithFormat:@"%d.jpg",i+1]];
        view.clickBlock = ^{
            NSLog(@"点击了卡片");
        };
        [array addObject:view];
    }
    [self.cardView loadCardViewWithData:array];
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
