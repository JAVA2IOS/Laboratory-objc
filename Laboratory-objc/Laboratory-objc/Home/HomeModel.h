//
//  HomeModel.h
//  Laboratory-objc
//
//  Created by qeeniao35 on 2019/1/15.
//  Copyright © 2019 CodeZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "LABIMTabViewController.h"
NS_ASSUME_NONNULL_BEGIN

@interface HomeModel : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *childViewControllerClassName;

+ (NSArray<HomeModel *> *)tableDatasource;

@end

NS_ASSUME_NONNULL_END
