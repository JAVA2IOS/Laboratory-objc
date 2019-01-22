//
//  UITableViewCell+Laboratory.h
//  Laboratory-objc
//
//  Created by qeeniao35 on 2019/1/22.
//  Copyright © 2019 CodeZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableViewCell (Laboratory)

/**
 初始化复用tableCell基本参数

 @param table table列表
 @param resuableIdentifier 复用标识符
 @return 复用tableCell
 */
+ (instancetype)lab_tableView:(UITableView *)table dequeueReusableIdentifier:(NSString *)resuableIdentifier;

@end

