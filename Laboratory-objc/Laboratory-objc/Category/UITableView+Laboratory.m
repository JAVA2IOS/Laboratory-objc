//
//  UITableView+Laboratory.m
//  Laboratory-objc
//
//  Created by qeeniao35 on 2019/1/18.
//  Copyright © 2019 CodeZ. All rights reserved.
//

#import "UITableView+Laboratory.h"

@implementation UITableView (Laboratory)

+ (instancetype)lab_initTable {
    UITableView *table = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    table.estimatedRowHeight = 0;
    table.estimatedSectionFooterHeight = 0;
    table.estimatedSectionHeaderHeight = 0;
    table.tableFooterView = [[UIView alloc] init];
    table.separatorStyle = UITableViewCellSeparatorStyleNone;
    table.showsVerticalScrollIndicator = NO;
    table.showsHorizontalScrollIndicator = NO;
    table.backgroundColor = [UIColor clearColor];
    
    return table;
}

@end
