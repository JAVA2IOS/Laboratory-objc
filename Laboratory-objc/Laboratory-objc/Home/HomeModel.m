//
//  HomeModel.m
//  Laboratory-objc
//
//  Created by qeeniao35 on 2019/1/15.
//  Copyright © 2019 CodeZ. All rights reserved.
//

#import "HomeModel.h"
#import "TransitionViewController.h"

@implementation HomeModel
+ (NSArray<HomeModel *> *)tableDatasource {
    NSArray *titles = @[@"转场动画"];
    NSArray *viewControllers = @[NSStringFromClass([TransitionViewController class])];
    
    NSMutableArray *childVC = [[NSMutableArray alloc] init];
    for (int i = 0; i < MIN(titles.count, viewControllers.count); i ++) {
        HomeModel *model = [[HomeModel alloc] init];
        model.title = titles[i];
        model.childViewControllerClassName = viewControllers[i];
        [childVC addObject:model];
    }
    
    return [childVC copy];
}

@end