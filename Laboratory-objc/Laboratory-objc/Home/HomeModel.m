//
//  HomeModel.m
//  Laboratory-objc
//
//  Created by qeeniao35 on 2019/1/15.
//  Copyright © 2019 CodeZ. All rights reserved.
//

#import "HomeModel.h"
#import "TransitionViewController.h"
#import "EmitterViewController.h"
#import "EditableViewController.h"
#import "EditableCollecitonController.h"
#import "AudioViewController.h"
#import "StackCardsViewController.h"
#import "IGListViewController.h"
#import "IGListBindingController.h"

@implementation HomeModel
+ (NSArray<HomeModel *> *)tableDatasource {
    NSArray *titles = @[@"转场动画", @"粒子效果", @"可排序", @"colleciton可排序", @"音频使用", @"卡片堆叠", @"IGListKit", @"队列"];
    NSArray *viewControllers = @[NSStringFromClass([TransitionViewController class]), NSStringFromClass([EmitterViewController class]), NSStringFromClass([EditableViewController class]), NSStringFromClass([EditableCollecitonController class]),NSStringFromClass([AudioViewController class]), NSStringFromClass([StackCardsViewController class]), NSStringFromClass([IGListBindingController class]), @"OperationViewController"];
    
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
