//
//  IGUserModel.h
//  Laboratory-objc
//
//  Created by q huang on 2020/1/3.
//  Copyright © 2020 CodeZ. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface IGUserModel : NSObject
/**
 用户id字符串
 */
@property (nonatomic, copy) NSString *idstr;
/**
 用户id
 */
@property (nonatomic, assign) NSInteger uesrId;
/**
 用户名称
 */
@property (nonatomic, copy) NSString *name;

+ (NSArray<IGUserModel *> *)userModels;

@end

NS_ASSUME_NONNULL_END
