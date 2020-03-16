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

@interface IGListViewController () <IGListAdapterDataSource, IGListAdapterMoveDelegate, UICollectionViewDelegate>
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
    _adapter.moveDelegate = self;
    _adapter.collectionView = self.listView;
}

- (void)buttonClick {
    [self.listView beginInteractiveMovementForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
}


#pragma mark - IGListUpdatingDelegate
- (void)listAdapter:(IGListAdapter *)listAdapter moveObject:(id)object from:(NSArray *)previousObjects to:(NSArray *)objects {
    NSLog(@"移动了吗:");
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (IGUserModel *user in objects) {
        [array addObject:user];
    }
    _userModels = [[NSArray alloc] initWithArray:array];
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


#pragma mark - getter
- (IGListCollectionView *)listView {
    return _listView ?: ({
        _listView = [[IGListCollectionView alloc] initWithFrame:CGRectMake(0, LABTopHeight, self.view.labWidth, self.view.labHeight - LABTopHeight)];
        _listView.backgroundColor = [UIColor whiteColor];
        
        _listView;
    });
}

@end
