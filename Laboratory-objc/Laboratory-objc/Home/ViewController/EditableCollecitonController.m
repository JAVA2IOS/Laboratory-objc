//
//  EditableCollecitonController.m
//  Laboratory-objc
//
//  Created by qeeniao35 on 2019/3/11.
//  Copyright © 2019 CodeZ. All rights reserved.
//

#import "EditableCollecitonController.h"

@interface EditableCollecitonController ()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, retain) UICollectionView *collection;
@end
/* 复用标志服 */
static NSString *const kStaticConstCommon = @"kStaticConstCommon";

@implementation EditableCollecitonController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = LabColor(@"ffffff");
    [self.view addSubview:self.collection];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] init];
    [longPress addTarget:self action:@selector(handleLongPressGesture:)];
    [self.collection addGestureRecognizer:longPress];
}


- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)longGesture {
    CGPoint currentPoint = [longGesture locationInView:self.collection];
    switch (longGesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            NSIndexPath *currentIndexPath = [self.collection indexPathForItemAtPoint:currentPoint];
            
            if (currentIndexPath) {
                [self.collection beginInteractiveMovementForItemAtIndexPath:currentIndexPath];
            }
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            [self.collection updateInteractiveMovementTargetPosition:currentPoint];
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            [self.collection endInteractiveMovement];
        }
            break;
            
        default:
        {
            [self.collection cancelInteractiveMovement];
        }
            break;
    }
}


#pragma mark - getter & setter
- (UICollectionView *)collection {
    return _collection ?:({
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake((SCREENWIDTH - 10 * 5) / 3, (SCREENWIDTH - 10 * 5) / 3);
        layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
        layout.minimumLineSpacing = 10;
        layout.minimumInteritemSpacing = 10;
        
        _collection = [[UICollectionView alloc] initWithFrame:CGRectMake(0, LABTopHeight, SCREENWIDTH, SCREENHEIGHT - LABTopHeight - LABTabBarFootHeight) collectionViewLayout:layout];
        _collection.delegate = self;
        _collection.dataSource = self;
        _collection.backgroundColor = LabColor(@"ffffff");
        [_collection registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kStaticConstCommon];
        _collection;
    });
}


#pragma mark - delegate
- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kStaticConstCommon forIndexPath:indexPath];
    cell.backgroundColor = LabColor(@"#ffee8e");
    
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 10;
}

@end

