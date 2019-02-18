//
//  NSAttributedString+Laboratory.h
//  Laboratory-objc
//
//  Created by qeeniao35 on 2019/2/18.
//  Copyright © 2019 CodeZ. All rights reserved.
//



#import <Foundation/Foundation.h>

@interface NSAttributedString (Laboratory)
/**
 富文本的宽度
 
 @param height 高度限制
 @return 富文本的宽度
 */
- (CGFloat)lab_stringWidthLimitHeight:(CGFloat)height;

/**
 富文本的高度
 
 @param width 宽度限制
 @return 富文本的高度
 */
- (CGFloat)lab_stringHeightLimitWidth:(CGFloat)width;

@end

