//
//  NSAttributedString+Laboratory.m
//  Laboratory-objc
//
//  Created by qeeniao35 on 2019/2/18.
//  Copyright © 2019 CodeZ. All rights reserved.
//

#import "NSAttributedString+Laboratory.h"

@implementation NSAttributedString (Laboratory)
- (CGFloat)lab_stringHeightLimitWidth:(CGFloat)width {
    return [self boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.width;
}

- (CGFloat)lab_stringWidthLimitHeight:(CGFloat)height {
    return [self boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, height) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.height;
}

@end
