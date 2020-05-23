//
//  UserBindingSection.h
//  Laboratory-objc
//
//  Created by q huang on 2020/4/17.
//  Copyright © 2020 CodeZ. All rights reserved.
//

#import <IGListKit/IGListKit.h>
@class IGUserModel;

NS_ASSUME_NONNULL_BEGIN

@interface UserBindingSection : IGListBindingSectionController
@property (nonatomic, retain) NSArray<IGUserModel *> *userModels;
@end

NS_ASSUME_NONNULL_END
