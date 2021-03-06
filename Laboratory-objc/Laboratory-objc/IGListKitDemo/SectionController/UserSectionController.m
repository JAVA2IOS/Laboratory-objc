//
//  UserSectionController.m
//  Laboratory-objc
//
//  Created by q huang on 2020/1/3.
//  Copyright © 2020 CodeZ. All rights reserved.
//

#import "UserSectionController.h"
#import "UserCollectionCell.h"
#import "IGUserModel.h"

@interface UserSectionController()
@property (nonatomic, retain) IGUserModel *user;

@end

@implementation UserSectionController
- (instancetype)init {
    if (self = [super init]) {
        self.inset = UIEdgeInsetsMake(10, 0, 0, 0);
        self.minimumLineSpacing = 10;
//        self.minimumInteritemSpacing = self.collectionContext.containerSize.width;
    }
    
    return self;
}

- (void)didUpdateToObject:(id)object {
    if ([object isKindOfClass:[IGUserModel class]]) {
        _user = object;
    }
}

- (BOOL)canMoveItemAtIndex:(NSInteger)index {
    return YES;
}

- (void)moveObjectFromIndex:(NSInteger)sourceIndex toIndex:(NSInteger)destinationIndex {
    NSLog(@"从[%d]移动到[%d]", (int)sourceIndex, (int)destinationIndex);
}

- (CGSize)sizeForItemAtIndex:(NSInteger)index {
    return CGSizeMake(self.collectionContext.containerSize.width, 40);
}

- (UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index {
    UserCollectionCell *cell = [self.collectionContext dequeueReusableCellOfClass:[UserCollectionCell class] forSectionController:self atIndex:index];
    cell.userModel = _user;
    cell.titleLabel.text = [cell.titleLabel.text stringByAppendingFormat:@"- %d", (int)index];

    return cell;
}

- (void)didSelectItemAtIndex:(NSInteger)index {
//    [self.collectionContext performBatchAnimated:YES updates:^(id<IGListBatchContext>  _Nonnull batchContext) {
    /*
     // 数据更新
     // _user = ...
     // 逻辑更新
     // 插入
     [batchContext insertInSectionController:self atIndexes:[NSIndexSet indexSetWithIndex:0]];
     // 删除
     [batchContext deleteInSectionController:self atIndexes:[NSIndexSet indexSetWithIndex:self.section]];
     
     //        [batchContext moveInSectionController:self fromIndex:0 toIndex:1];
     */
//    } completion:nil];
}

- (void)didDeselectItemAtIndex:(NSInteger)index {
    
}

- (void)didHighlightItemAtIndex:(NSInteger)index {
    
}

- (void)didUnhighlightItemAtIndex:(NSInteger)index {
    
}

@end
