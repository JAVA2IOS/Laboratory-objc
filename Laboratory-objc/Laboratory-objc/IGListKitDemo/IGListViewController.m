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

@interface IGListViewController () <IGListAdapterDataSource>
@property (nonatomic, retain) IGListCollectionView *listView;
/// 数据源配置
@property (nonatomic, retain) IGListAdapter *adapter;
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
    IGListAdapterUpdater *updater = [[IGListAdapterUpdater alloc] init];
    _adapter = [[IGListAdapter alloc] initWithUpdater:updater viewController:self];
    _adapter.dataSource = self;
    _adapter.collectionView = self.listView;
}


#pragma mark - IGListUpdatingDelegate


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
