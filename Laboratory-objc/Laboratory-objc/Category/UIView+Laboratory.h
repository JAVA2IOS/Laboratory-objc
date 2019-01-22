//
//  UIView+Laboratory.h
//  Laboratory-objc
//
//  Created by qeeniao35 on 2019/1/18.
//  Copyright © 2019 CodeZ. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 渐变方向
 
 - QNGradientDirectionHorizontal: 水平方向
 - QNGradientDirectionVertical: 垂直方向
 - QNGradientDirectionDiagonalTopLeftToBottomRight: 左上到右下
 - QNGradientDirectionDiagonalTopRightToBottomLeft: 坐下到右上
 */
typedef NS_ENUM(NSInteger, LABGradientDirection) {
    LABGradientDirectionHorizontal,
    LABGradientDirectionVertical,
    LabGradientDirectionDiagonalTopLeftToBottomRight,
    LABGradientDirectionDiagonalTopRightToBottomLeft
};

@interface UIView (Laboratory)

@property (nonatomic, assign) CGFloat labX;

@property (nonatomic, assign) CGFloat labY;

@property (nonatomic, assign) CGFloat labBottom;

@property (nonatomic, assign) CGFloat labRight;

@property (nonatomic, assign) CGFloat labWidth;

@property (nonatomic, assign) CGFloat labHeight;

@property (nonatomic, assign) CGFloat labCenterX;

@property (nonatomic, assign) CGFloat labCenterY;

#pragma mark - 图层
/**
 添加圆角遮罩层
 
 @param corners 需要添加圆角的方位(左上、左下、右上、右下)
 @param radius 圆角的半径
 */
- (CALayer *)lab_addRoundingCorners:(UIRectCorner)corners cornerRadii:(CGFloat)radius;

/**
 添加圆角遮罩层
 
 @param corners 需要添加圆角的方位(左上、左下、右上、右下)
 @param rect 圆角显示的rect，使用于masonary，无法得到正确的rect
 @param radius 圆角的半径
 */
- (CALayer *)lab_addRoundingCorners:(UIRectCorner)corners inRect:(CGRect)rect cornerRadii:(CGFloat)radius;

/**
 向当前的视图插入CAShaplyer，无法裁切子视图的圆角
 
 @param backgroundColor Layer的颜色
 @param corners 圆角方位
 @param radius 圆角半径
 @return 子图层
 */
- (CALayer *)lab_addSubLayer:(UIColor *)backgroundColor RoundingCorners:(UIRectCorner)corners cornerRadii:(CGFloat)radius;

/**
 向当前的视图插入CAShaplyer
 
 @param backgroundColor Layer的颜色
 @param corners 圆角方位
 @param rect 坐标
 @param radius 圆角半径
 @return 子图层
 */
- (CALayer *)lab_addSubLayer:(UIColor *)backgroundColor RoundingCorners:(UIRectCorner)corners inRect:(CGRect)rect cornerRadii:(CGFloat)radius;

#pragma mark 渐变
/**
 渐变颜色背景
 
 @param direction 渐变方向枚举
 @param colors 颜色数组
 @param radius 圆角半径
 @return 渐变图层
 */
- (CAGradientLayer *)lab_addGradientLayer:(LABGradientDirection)direction colors:(NSArray<UIColor *> *)colors cornerRadius:(CGFloat)radius;

/**
 渐变色背景，渐变方向默认向右下渐变
 
 @param colors 颜色数组
 @param radius 圆角半径
 */
- (CAGradientLayer *)lab_addGradientLayer:(NSArray<UIColor *> *)colors cornerRadius:(CGFloat)radius;

/**
 渐变色背景
 
 @param colors 颜色数组
 @param points 渐变方向坐标(CGPoint(0~1,0~1))
 @param radius 圆角半径
 */
- (CAGradientLayer *)lab_addGradientLayer:(NSArray<UIColor *> *)colors gradientPoints:(NSArray<NSValue *> *)points cornerRadius:(CGFloat)radius;

/**
 渐变色背景
 
 @param colors 颜色数组
 @param points 渐变方向坐标(CGPoint(0~1,0~1))
 @param locations 渐变的程度(@[@0, ...., @1])
 @param radius 圆角半径
 */
- (CAGradientLayer *)lab_addGradientLayer:(NSArray<UIColor *> *)colors gradientPoints:(NSArray<NSValue *> *)points locations:(NSArray *)locations cornerRadius:(CGFloat)radius;

/**
 渐变色背景
 
 @param colors 颜色数组(CGColor)
 @param points 渐变方向坐标(CGPoint(0~1,0~1))
 @param locations 渐变的程度(@[@0, ...., @1])
 @param corners 圆角方向(暂时默认四角)
 @param radius 圆角半径
 */
- (CAGradientLayer *)lab_addGradientLayer:(NSArray<UIColor *> *)colors gradientPoints:(NSArray<NSValue *> *)points locations:(NSArray *)locations corners:(UIRectCorner)corners cornerRadius:(CGFloat)radius;

/**
 渐变色背景
 
 @param colors 颜色数组(CGColor)
 @param points 渐变方向坐标(CGPoint(0~1,0~1))
 @param locations 渐变的程度(@[@0, ...., @1])
 @param corners 圆角方向(暂时默认四角)
 @param radius 圆角半径
 @param rect 渐变色区域
 */
- (CAGradientLayer *)lab_addGradientLayer:(NSArray<UIColor *> *)colors gradientPoints:(NSArray<NSValue *> *)points locations:(NSArray *)locations corners:(UIRectCorner)corners cornerRadius:(CGFloat)radius inRect:(CGRect)rect;

#pragma mark 阴影，慎用，有点问题
/**
 添加阴影
 
 @param color 阴影颜色
 @param radius 阴影圆角
 @return 阴影图层
 */
- (CALayer *)lab_addShadowLayer:(UIColor *)color cornerRadius:(CGFloat)radius;


#pragma mark 使用图片当背景颜色
/**
 在layer层添加一张背景图片的Layer
 
 @param imageBundleName 图片名称
 @return 图片layer
 */
- (CALayer *)lab_backgroundImageLayerName:(NSString *)imageBundleName;

/**
 在layer层添加一张背景图片的Layer
 
 @param image 图片
 @return 图片layer
 */
- (CALayer *)lab_backgroundImageLayer:(UIImage *)image;


#pragma mark - 初始化
/**
 初始化 并添加圆角以及背景颜色

 @param rect 视图尺寸
 @param color 背景颜色
 @param radius 圆角
 @return 初始化实例对象
 */
+ (instancetype)lab_initFrame:(CGRect)rect backgourndColor:(UIColor *)color cornerRadius:(CGFloat)radius;

/**
 初始化 并添加圆角以及默认透明背景颜色
 
 @param rect 视图尺寸
 @param radius 圆角
 @return 初始化实例对象
 */
+ (instancetype)lab_initFrame:(CGRect)rect cornerRadius:(CGFloat)radius;

/**
 初始化 并添加圆角以及背景渐变颜色，方向为水平方向渐变
 
 @param rect 视图尺寸
 @param colors 渐变颜色组
 @param radius 圆角
 @return 初始化实例对象
 */
+ (instancetype)lab_initFrame:(CGRect)rect gradientColor:(NSArray<UIColor*> *)colors cornerRadius:(CGFloat)radius;

/**
 初始化 并添加圆角以及背景渐变颜色，方向为水平方向渐变
 
 @param rect 视图尺寸
 @param direction 渐变方向
 @param colors 渐变颜色组
 @param radius 圆角
 @return 初始化实例对象
 */
+ (instancetype)lab_initFrame:(CGRect)rect gradientColor:(NSArray<UIColor*> *)colors gradientDirection:(LABGradientDirection)direction cornerRadius:(CGFloat)radius;

@end
