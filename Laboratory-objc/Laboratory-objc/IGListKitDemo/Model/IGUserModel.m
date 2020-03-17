//
//  IGUserModel.m
//  Laboratory-objc
//
//  Created by q huang on 2020/1/3.
//  Copyright © 2020 CodeZ. All rights reserved.
//

#import "IGUserModel.h"
#import <IGListKit.h>

@interface IGUserModel()<IGListDiffable>

@end

@implementation IGUserModel
- (id<NSObject>)diffIdentifier {
    return self;
}

- (BOOL)isEqualToDiffableObject:(id<IGListDiffable>)object {
    return [self isEqual:object];
}

+ (NSArray<IGUserModel *> *)userModels {
    IGUserModel *userOne = [[IGUserModel alloc] init];
    userOne.idstr = @"6170043328";
    userOne.uesrId = 6170043328;
    userOne.name = @"游戏肥宅200斤";
    
    IGUserModel *userTwo = [[IGUserModel alloc] init];
    userTwo.idstr = @"5163808365";
    userTwo.uesrId = 5163808365;
    userTwo.name = @"DC电影报道";
    
    IGUserModel *userThree = [[IGUserModel alloc] init];
    userThree.idstr = @"5163808365";
    userThree.uesrId = 5163808365;
    userThree.name = @"DC电影报道";
    
    return @[userOne, userTwo, userThree];
}

@end
