//
//  UIButton+Laboratory.h
//  Laboratory-objc
//
//  Created by qeeniao35 on 2019/1/18.
//  Copyright © 2019 CodeZ. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^LABbuttonClick)(void);

@interface UIButton (Laboratory)

@property (nonatomic, copy) LABbuttonClick clickCompletion;

#pragma mark - button初始化
+ (instancetype)lab_initButton:(CGRect)rect title:(NSString *)title font:(UIFont *)font titleColor:(UIColor *)titleColor backgroundColor:(UIColor *)backgroundColor;

+ (instancetype)lab_initButtonTitile:(NSString *)title font:(UIFont *)font titleColor:(UIColor *)titleColor backgroundColor:(UIColor *)backgroundColor;

+ (instancetype)lab_initButtonTitile:(NSString *)title fontSize:(NSInteger)fontSize titleColor:(UIColor *)titleColor backgroundColor:(UIColor *)backgroundColor;

+ (instancetype)lab_initButton:(CGRect)rect image:(NSString *)imageName;

+ (instancetype)lab_initButton:(NSString *)imageName;

/**
 设置按钮图片

 @param imageName 图片名称
 */
- (void)lab_imageName:(NSString *)imageName;

/**
 设置按钮标题

 @param title 标题
 */
- (void)lab_title:(NSString *)title;

/**
 按钮点击响应

 @param target 响应对象
 @param selector 响应方法
 */
- (void)buttonClick:(id)target selector:(SEL)selector;

- (void)buttonClickCompletion:(void(^)(void))completion;

@end

