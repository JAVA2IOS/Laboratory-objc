//
//  IGListBindingController.m
//  Laboratory-objc
//
//  Created by q huang on 2020/4/17.
//  Copyright © 2020 CodeZ. All rights reserved.
//

#import "IGListBindingController.h"
#import <IGListKit/IGListKit.h>
#import "UserBindingSection.h"

#import "IGUserModel.h"

@interface IGListBindingController ()<IGListAdapterDelegate, IGListAdapterDataSource, IGListAdapterMoveDelegate>
@property (nonatomic, retain) IGListCollectionView *listView;
/// 数据源配置
@property (nonatomic, retain) IGListAdapter *adapter;
@property (nonatomic, retain) IGListAdapterUpdater *updater;
@property (nonatomic, retain) NSArray *userModels;
@property (nonatomic, retain) NSArray *sectionModels;
@end

@implementation IGListBindingController
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
- (void)listAdapter:(nonnull IGListAdapter *)listAdapter didEndDisplayingObject:(nonnull id)object atIndex:(NSInteger)index {
    
}

- (void)listAdapter:(nonnull IGListAdapter *)listAdapter willDisplayObject:(nonnull id)object atIndex:(NSInteger)index {
    
}

- (NSArray<id<IGListDiffable>> *)objectsForListAdapter:(IGListAdapter *)listAdapter {
    return _userModels;
}

- (IGListSectionController *)listAdapter:(IGListAdapter *)listAdapter sectionControllerForObject:(id)object {
    UserBindingSection *section = [[UserBindingSection alloc] init];
    section.userModels = _userModels;
    return section;
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
            NSLog(@"当前坐标(%ld, %ld)", (long)currentIndexPath.section, (long)currentIndexPath.row);
            
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

