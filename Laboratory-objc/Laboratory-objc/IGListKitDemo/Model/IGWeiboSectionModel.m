//
//  IGWeiboSectionModel.m
//  Laboratory-objc
//
//  Created by q huang on 2020/1/3.
//  Copyright © 2020 CodeZ. All rights reserved.
//

#import "IGWeiboSectionModel.h"
#import <IGListKit.h>

@interface IGWeiboSectionModel()<IGListDiffable>

@end

@implementation IGWeiboSectionModel

- (id<NSObject>)diffIdentifier {
    return self;
}

- (BOOL)isEqualToDiffableObject:(id<IGListDiffable>)object {
    return [self isEqual:object];
}

@end
