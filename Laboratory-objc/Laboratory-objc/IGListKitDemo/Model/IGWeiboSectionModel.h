//
//  IGWeiboSectionModel.h
//  Laboratory-objc
//
//  Created by q huang on 2020/1/3.
//  Copyright © 2020 CodeZ. All rights reserved.
//

#import <Foundation/Foundation.h>
@class IGUserModel;

NS_ASSUME_NONNULL_BEGIN

@interface IGWeiboSectionModel : NSObject
/// 用户信息
@property (nonatomic, retain) IGUserModel *user;
/**
 文案内容
 */
@property (nonatomic, copy) NSString *text;

@end

NS_ASSUME_NONNULL_END
