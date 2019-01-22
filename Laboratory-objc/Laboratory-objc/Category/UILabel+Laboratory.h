//
//  UILabel+Laboratory.h
//  Laboratory-objc
//
//  Created by qeeniao35 on 2019/1/21.
//  Copyright © 2019 CodeZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (Laboratory)

+ (instancetype)lab_initFrame:(CGRect)frame titleColor:(UIColor *)titleColor backgroundColor:(UIColor *)backgroundColor font:(UIFont *)font;

+ (instancetype)lab_initFrame:(CGRect)frame titleColor:(UIColor *)titleColor font:(UIFont *)font;

+ (instancetype)lab_initFrame:(CGRect)frame titleColor:(UIColor *)titleColor;

/**
 添加富文本 + 重新设置文本尺寸

 @param string 富文本字符串
 @param attributes 文本样式
 @param sizeToFit 是否重新设置文本尺寸大小
 */
- (void)lab_addAttributeString:(NSString *)string attributes:(NSDictionary *)attributes sizeToFit:(BOOL)sizeToFit;

/**
 添加富文本
 
 @param string 富文本字符串
 @param attributes 文本样式
 */
- (void)lab_addAttributeString:(NSString *)string attributes:(NSDictionary *)attributes;

@end

