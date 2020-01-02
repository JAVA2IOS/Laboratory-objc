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
#import "NewCardCell.h"

@interface StackCardsViewController ()<TABCardViewDelegate, StackCardViewDelegate> {
    NSArray *cardArray;
}
@property (nonatomic,strong) TABCardView * cardView;
@property (nonatomic,strong) StackCardView *customCards;
@end

@implementation StackCardsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = LabColor(@"ffffff");
    cardArray = @[@[@"0,0", @"0,1", @"0,2", @"0,3"], @[@"1.0", @"1,1"], @[@"2.0", @"2.1"]];
    
    UIScrollView *scrollContainer = [[UIScrollView alloc] initWithFrame:CGRectMake(0, LABTopHeight, self.view.labWidth, self.view.labHeight - LABTopHeight)];
    scrollContainer.contentSize = CGSizeMake(self.view.labWidth, self.view.labHeight);
    [self.view addSubview:scrollContainer];
    
    _customCards = [[StackCardView alloc] initWithFrame:CGRectMake(40, self.labNavgationBar.labBottom + 10, self.view.labWidth - 80, self.view.labWidth - 80)];
    _customCards.stackDelegate = self;
    [_customCards registerClass:[StackCardCell class] reusableIdentifer:NSStringFromClass([StackCardCell class])];
    [_customCards registerClass:[NewCardCell class] reusableIdentifer:NSStringFromClass([NewCardCell class])];
    
    [scrollContainer addSubview:_customCards];
    _customCards.backgroundColor = [UIColor randomColor];
    [_customCards reloadData];
    
    CGFloat buttonWidth = self.view.labWidth / 3;
    UIButton *refreshButton = [UIButton lab_initButton:CGRectMake(self.view.labCenterX - buttonWidth / 2, _customCards.labBottom + 30, buttonWidth, 50) title:@"加载" font:[UIFont systemFontOfSize:18] titleColor:[UIColor blackColor] backgroundColor:[UIColor whiteColor]];
    [refreshButton buttonClick:self selector:@selector(refreshCards)];
    
    [scrollContainer addSubview:refreshButton];
    
    UIButton *lastButton = [UIButton lab_initButton:CGRectMake(0, _customCards.labBottom + 30, buttonWidth, 50) title:@"上一页" font:[UIFont systemFontOfSize:18] titleColor:[UIColor blackColor] backgroundColor:[UIColor whiteColor]];
    [lastButton buttonClick:self selector:@selector(previousCard)];
    
    [scrollContainer addSubview:lastButton];
    
    UIButton *nextButton = [UIButton lab_initButton:CGRectMake(buttonWidth * 2, _customCards.labBottom + 30, buttonWidth, 50) title:@"下一页" font:[UIFont systemFontOfSize:18] titleColor:[UIColor blackColor] backgroundColor:[UIColor whiteColor]];
    [nextButton buttonClick:self selector:@selector(next)];
    
    [scrollContainer addSubview:nextButton];
    
    UIButton *reloadButton = [UIButton lab_initButton:CGRectMake(self.view.labCenterX - buttonWidth / 2, refreshButton.labBottom + 30, buttonWidth, 50) title:@"刷新" font:[UIFont systemFontOfSize:18] titleColor:[UIColor blackColor] backgroundColor:[UIColor whiteColor]];
    [reloadButton buttonClick:self selector:@selector(reloadCard)];
    
    [scrollContainer addSubview:reloadButton];
}

- (void)refreshCards {
//    [_customCards selectIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] animated:YES];
    [_customCards scrollToLastIndexPath];
}

- (void)reloadCard {
    [_customCards reloadData];
}

- (void)next {
    [_customCards loadNextCard];
}

- (void)previousCard {
    [_customCards loadPreviousCard];
}

- (BOOL)stackCardView:(StackCardView *)cardsView shouldSwipeCell:(__kindof StackCardCell *)cell atIndexPath:(NSIndexPath *)indexPath direction:(StackScrollDirection)direction {
    if (direction == StackScrollDirectionCounterClockwise) {
        NSArray *stringArray = cardArray[indexPath.section];
        return indexPath.row != stringArray.count - 1;
    }
    
    return YES;
}

- (StackCardCell *)stackCardsView:(StackCardView *)cardView cellForCurrentIndexPath:(NSIndexPath *)indexPath {
    NewCardCell *cell = [cardView dequeueReusableIdentifier:NSStringFromClass([NewCardCell class]) indexPath:indexPath];
    cell.label.text = [NSString stringWithFormat:@"(%ld, %ld)", indexPath.section, indexPath.row];
    if (indexPath.section == 0) {
        cell.contentView.backgroundColor = [UIColor whiteColor];
    }else if (indexPath.section == 1) {
        cell.contentView.backgroundColor = [UIColor yellowColor];
    }else {
        cell.contentView.backgroundColor = [UIColor whiteColor];
    }
    
    return cell;
}

- (NSInteger)stackCardView:(StackCardView *)cardsView numberOfItemsInSection:(NSInteger)section {
    NSArray *stringArray = cardArray[section];
    return stringArray.count;
}

- (NSInteger)numberOfSectionsInStackCard:(StackCardView *)cardsView {
    return cardArray.count;
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

@end
