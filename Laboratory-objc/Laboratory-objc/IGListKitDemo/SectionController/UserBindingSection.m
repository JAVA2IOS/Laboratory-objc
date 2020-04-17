//
//  UserBindingSection.m
//  Laboratory-objc
//
//  Created by q huang on 2020/4/17.
//  Copyright © 2020 CodeZ. All rights reserved.
//

#import "UserBindingSection.h"
#import "UserBindingSectionCell.h"

@interface UserBindingSection()<IGListBindingSectionControllerDataSource, IGListBindingSectionControllerSelectionDelegate>

@end

@implementation UserBindingSection
- (instancetype)init {
    if (self = [super init]) {
        self.inset = UIEdgeInsetsMake(10, 0, 0, 0);
        self.minimumLineSpacing = 10;
        self.dataSource = self;
        self.selectionDelegate = self;
    }
    
    return self;
}


- (nonnull UICollectionViewCell<IGListBindable> *)sectionController:(nonnull IGListBindingSectionController *)sectionController cellForViewModel:(nonnull id)viewModel atIndex:(NSInteger)index {
    UserBindingSectionCell *cell = [self.collectionContext dequeueReusableCellOfClass:[UserBindingSectionCell class] forSectionController:self atIndex:index];
    
    return cell;
}

- (CGSize)sectionController:(nonnull IGListBindingSectionController *)sectionController sizeForViewModel:(nonnull id)viewModel atIndex:(NSInteger)index {
    return CGSizeMake(self.collectionContext.containerSize.width, 40);
}

- (nonnull NSArray<id<IGListDiffable>> *)sectionController:(nonnull IGListBindingSectionController *)sectionController viewModelsForObject:(nonnull id)object {
    return _userModels;
}

- (void)sectionController:(nonnull IGListBindingSectionController *)sectionController didDeselectItemAtIndex:(NSInteger)index viewModel:(nonnull id)viewModel {
    
}

- (void)sectionController:(nonnull IGListBindingSectionController *)sectionController didHighlightItemAtIndex:(NSInteger)index viewModel:(nonnull id)viewModel {
    
}

- (void)sectionController:(nonnull IGListBindingSectionController *)sectionController didSelectItemAtIndex:(NSInteger)index viewModel:(nonnull id)viewModel {
    
}

- (void)sectionController:(nonnull IGListBindingSectionController *)sectionController didUnhighlightItemAtIndex:(NSInteger)index viewModel:(nonnull id)viewModel {
    
}

@end
