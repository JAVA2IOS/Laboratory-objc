//
//  UserCollectionCell.h
//  Laboratory-objc
//
//  Created by q huang on 2020/1/3.
//  Copyright © 2020 CodeZ. All rights reserved.
//

#import <UIKit/UIKit.h>
@class IGUserModel;

NS_ASSUME_NONNULL_BEGIN

@interface UserCollectionCell : UICollectionViewCell
@property (nonatomic, retain) IGUserModel *userModel;
@end

NS_ASSUME_NONNULL_END
