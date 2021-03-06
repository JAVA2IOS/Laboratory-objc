//
//  IGListViewController.m
//  Laboratory-objc
//
//  Created by q huang on 2020/1/3.
//  Copyright © 2020 CodeZ. All rights reserved.
//

#import "IGListViewController.h"
#import <IGListKit.h>
#import "IGUserModel.h"
#import "UserSectionController.h"

@interface IGListViewController () <IGListAdapterDataSource, IGListAdapterMoveDelegate>
@property (nonatomic, retain) IGListCollectionView *listView;
/// 数据源配置
@property (nonatomic, retain) IGListAdapter *adapter;
@property (nonatomic, retain) IGListAdapterUpdater *updater;
@property (nonatomic, retain) NSArray *userModels;
@property (nonatomic, retain) NSArray *sectionModels;
@end

@implementation IGListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 数据
    _userModels = [IGUserModel userModels];
    // UI
    [self.view addSubview:self.listView];
    
    // 数据与UI关联
    _updater = [[IGListAdapterUpdater alloc] init];
    _adapter = [[IGListAdapter alloc] initWithUpdater:_updater viewController:self];
    _adapter.dataSource = self;
    _adapter.collectionView = self.listView;
    _adapter.moveDelegate = self;
    
    UIButton *button = [UIButton lab_initButton:CGRectMake(10, LABTopHeight + 30, 100, 50) title:@"切换" font:[UIFont systemFontOfSize:12] titleColor:[UIColor whiteColor] backgroundColor:[UIColor redColor]];
    [button addTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)buttonClick {
    [self.listView moveSection:0 toSection:1];
}


#pragma mark - IGListUpdatingDelegate
- (void)listAdapter:(IGListAdapter *)listAdapter moveObject:(id)object from:(NSArray *)previousObjects to:(NSArray *)objects {
    NSLog(@"移动了吗:");
    _userModels = objects;
}


#pragma mark - IGListAdapterDelegate
- (NSArray<id<IGListDiffable>> *)objectsForListAdapter:(IGListAdapter *)listAdapter {
    return _userModels;
}

- (IGListSectionController *)listAdapter:(IGListAdapter *)listAdapter sectionControllerForObject:(id)object {
    if ([object isKindOfClass:[IGUserModel class]]) {
        return [UserSectionController new];
    }

    return nil;
}

- (UIView *)emptyViewForListAdapter:(IGListAdapter *)listAdapter {
    return nil;
}

- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)longGesture {
    CGPoint currentPoint = [longGesture locationInView:longGesture.view];
    switch (longGesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            NSIndexPath *currentIndexPath = [self.listView indexPathForItemAtPoint:currentPoint];
            
            if (currentIndexPath) {
                [self.listView beginInteractiveMovementForItemAtIndexPath:currentIndexPath];
            }
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            [self.listView updateInteractiveMovementTargetPosition:currentPoint];
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            [self.listView endInteractiveMovement];
        }
            break;
            
        default:
        {
            [self.listView cancelInteractiveMovement];
        }
            break;
    }
}


#pragma mark - getter
- (IGListCollectionView *)listView {
    return _listView ?: ({
        _listView = [[IGListCollectionView alloc] initWithFrame:CGRectMake(0, LABTopHeight, self.view.labWidth, self.view.labHeight - LABTopHeight) listCollectionViewLayout:[UICollectionViewFlowLayout new]];
        _listView.backgroundColor = [UIColor whiteColor];
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] init];
        [longPress addTarget:self action:@selector(handleLongPressGesture:)];
        [_listView addGestureRecognizer:longPress];
        
        _listView;
    });
}

@end
