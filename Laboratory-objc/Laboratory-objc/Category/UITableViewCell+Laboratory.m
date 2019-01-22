//
//  UITableViewCell+Laboratory.m
//  Laboratory-objc
//
//  Created by qeeniao35 on 2019/1/22.
//  Copyright © 2019 CodeZ. All rights reserved.
//

#import "UITableViewCell+Laboratory.h"

@implementation UITableViewCell (Laboratory)

+ (instancetype)lab_tableView:(UITableView *)table dequeueReusableIdentifier:(NSString *)resuableIdentifier {
    UITableViewCell *cell = [table dequeueReusableCellWithIdentifier:resuableIdentifier];
    if (!cell) {
        cell = [[[self class] alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:resuableIdentifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

@end
