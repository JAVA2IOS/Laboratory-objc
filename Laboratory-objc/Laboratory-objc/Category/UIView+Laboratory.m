//
//  UIView+Laboratory.m
//  Laboratory-objc
//
//  Created by qeeniao35 on 2019/1/18.
//  Copyright © 2019 CodeZ. All rights reserved.
//

#import "UIView+Laboratory.h"

@implementation UIView (Laboratory)
@dynamic labX;
@dynamic labY;
@dynamic labRight;
@dynamic labWidth;
@dynamic labBottom;
@dynamic labHeight;
@dynamic labCenterX;
@dynamic labCenterY;

- (CALayer *)lab_addRoundingCorners:(UIRectCorner)corners cornerRadii:(CGFloat)radius {
    return [self lab_addRoundingCorners:corners inRect:self.bounds cornerRadii:radius];
}

- (CALayer *)lab_addRoundingCorners:(UIRectCorner)corners inRect:(CGRect)rect cornerRadii:(CGFloat)radius {
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:corners cornerRadii:CGSizeMake(radius, radius)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.path = maskPath.CGPath;
    self.layer.mask = maskLayer;
    
    return maskLayer;
}

- (CALayer *)lab_addSubLayer:(UIColor *)backgroundColor RoundingCorners:(UIRectCorner)corners cornerRadii:(CGFloat)radius {
    return [self lab_addSubLayer:backgroundColor RoundingCorners:corners inRect:self.bounds cornerRadii:radius];
}

- (CALayer *)lab_addSubLayer:(UIColor *)backgroundColor RoundingCorners:(UIRectCorner)corners inRect:(CGRect)rect cornerRadii:(CGFloat)radius {
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:corners cornerRadii:CGSizeMake(radius, radius)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.path = maskPath.CGPath;
    maskLayer.fillColor = backgroundColor.CGColor;
    [self.layer insertSublayer:maskLayer atIndex:0];
    
    return maskLayer;
}

#pragma mark 渐变
- (CAGradientLayer *)lab_addGradientLayer:(LABGradientDirection)direction colors:(NSArray<UIColor *> *)colors cornerRadius:(CGFloat)radius {
    switch (direction) {
        case LABGradientDirectionHorizontal:
            return [self lab_addGradientLayer:colors gradientPoints:@[[NSValue valueWithCGPoint:CGPointZero], [NSValue valueWithCGPoint:CGPointMake(1, 0)]] cornerRadius:radius];
            break;
        case LABGradientDirectionVertical:
            return [self lab_addGradientLayer:colors gradientPoints:@[[NSValue valueWithCGPoint:CGPointZero], [NSValue valueWithCGPoint:CGPointMake(0, 1)]] cornerRadius:radius];
            break;
        case LabGradientDirectionDiagonalTopLeftToBottomRight:
            return [self lab_addGradientLayer:colors gradientPoints:@[[NSValue valueWithCGPoint:CGPointZero], [NSValue valueWithCGPoint:CGPointMake(1, 1)]] cornerRadius:radius];
            break;
        case LABGradientDirectionDiagonalTopRightToBottomLeft:
            return [self lab_addGradientLayer:colors gradientPoints:@[[NSValue valueWithCGPoint:CGPointMake(0, 1)], [NSValue valueWithCGPoint:CGPointMake(1, 0)]] cornerRadius:radius];
            break;
        default:
            return [self lab_addGradientLayer:colors gradientPoints:@[[NSValue valueWithCGPoint:CGPointZero], [NSValue valueWithCGPoint:CGPointMake(1, 0)]] cornerRadius:radius];
            break;
    }
}

// 默认渐变圆角(四角)以及渐变的位置(均匀)和方向(斜向右下)
- (CAGradientLayer *)lab_addGradientLayer:(NSArray<UIColor *> *)colors cornerRadius:(CGFloat)radius {
    return [self lab_addGradientLayer:colors gradientPoints:@[[NSValue valueWithCGPoint:CGPointMake(0, 0)], [NSValue valueWithCGPoint:CGPointMake(1, 1)]] locations:@[@0, @1] corners:UIRectCornerAllCorners cornerRadius:radius];
}

// 默认圆角以及渐变位置
- (CAGradientLayer *)lab_addGradientLayer:(NSArray<UIColor *> *)colors gradientPoints:(NSArray<NSValue *> *)points cornerRadius:(CGFloat)radius {
    return [self lab_addGradientLayer:colors gradientPoints:points locations:@[@0, @1] corners:UIRectCornerAllCorners cornerRadius:radius];
}

- (CAGradientLayer *)lab_addGradientLayer:(NSArray<UIColor *> *)colors gradientPoints:(NSArray<NSValue *> *)points locations:(NSArray *)locations cornerRadius:(CGFloat)radius {
    return [self lab_addGradientLayer:colors gradientPoints:points locations:locations corners:UIRectCornerAllCorners cornerRadius:radius];
}

// 渐变色
- (CAGradientLayer *)lab_addGradientLayer:(NSArray<UIColor *> *)colors gradientPoints:(NSArray<NSValue *> *)points locations:(NSArray *)locations corners:(UIRectCorner)corners cornerRadius:(CGFloat)radius {
    return [self lab_addGradientLayer:colors gradientPoints:points locations:locations corners:corners cornerRadius:radius inRect:self.bounds];
}

- (CAGradientLayer *)lab_addGradientLayer:(NSArray<UIColor *> *)colors gradientPoints:(NSArray<NSValue *> *)points locations:(NSArray *)locations corners:(UIRectCorner)corners cornerRadius:(CGFloat)radius inRect:(CGRect)rect {
    CGPoint startPoint = CGPointZero;
    CGPoint endPoint = CGPointZero;
    if ([points.firstObject isKindOfClass:[NSValue class]]) {
        startPoint = [points.firstObject CGPointValue];
        endPoint = [points.lastObject CGPointValue];
    }
    NSMutableArray *cgColors = [[NSMutableArray alloc] init];
    [colors enumerateObjectsUsingBlock:^(UIColor * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[UIColor class]]) {
            [cgColors addObject:(id)obj.CGColor];
        }
    }];
    CAGradientLayer *gradientLayer = [[CAGradientLayer alloc] init];
    gradientLayer.frame = rect;
    gradientLayer.colors = cgColors;
    gradientLayer.locations = locations;
    gradientLayer.startPoint = startPoint;
    gradientLayer.endPoint = endPoint;
    gradientLayer.cornerRadius = radius;
    
    // CACornerMask 圆角 待定，iOS11以后才可用
    [self.layer insertSublayer:gradientLayer atIndex:0];
    
    return gradientLayer;
}

// 添加阴影
- (CALayer *)lab_addShadowLayer:(UIColor *)color cornerRadius:(CGFloat)radius {
    CALayer *shadowLayer = [[CALayer alloc] init];
    shadowLayer.frame = self.bounds;
    shadowLayer.shadowColor = color.CGColor;
    shadowLayer.shadowOpacity = 1;
    shadowLayer.shadowOffset = CGSizeMake(0, 0);
    shadowLayer.shadowRadius = 6;
    CGFloat shadowSize = 0;
    CGRect shadowSpreadRect0 = CGRectMake(-shadowSize, -shadowSize, self.bounds.size.width+shadowSize*2, self.bounds.size.height+shadowSize*2);
    CGFloat shadowSpreadRadius0 = radius;
    UIBezierPath *shadowPath0 = [UIBezierPath bezierPathWithRoundedRect:shadowSpreadRect0 cornerRadius:shadowSpreadRadius0];
    shadowLayer.shadowPath = shadowPath0.CGPath;
    [self.layer insertSublayer:shadowLayer atIndex:0];
    
    return shadowLayer;
}

#pragma mark 添加背景图片
- (CALayer *)lab_backgroundImageLayer:(UIImage *)image {
    CALayer *layer = [[CALayer alloc] init];
    layer.frame = self.bounds;
    layer.contents = (__bridge id _Nullable)(image.CGImage);
    
    [self.layer addSublayer:layer];
    
    return layer;
}

- (CALayer *)lab_backgroundImageLayerName:(NSString *)imageBundleName {
    return  [self lab_backgroundImageLayer:[UIImage imageNamed:imageBundleName]];
}


#pragma mark - 初始化
+ (instancetype)lab_initFrame:(CGRect)rect cornerRadius:(CGFloat)radius {
    return [[self class] lab_initFrame:rect backgourndColor:[UIColor clearColor] cornerRadius:radius];
}

+ (instancetype)lab_initFrame:(CGRect)rect backgourndColor:(UIColor *)color cornerRadius:(CGFloat)radius {
    UIView *instanceView =[[[self class] alloc] initWithFrame:rect];
    instanceView.backgroundColor = color;
    if (radius > 0) {
        [instanceView lab_addRoundingCorners:UIRectCornerAllCorners cornerRadii:radius];
    }
    
    return instanceView;
}

#pragma mark 渐变背景
+ (instancetype)lab_initFrame:(CGRect)rect gradientColor:(NSArray<UIColor *> *)colors gradientDirection:(LABGradientDirection)direction cornerRadius:(CGFloat)radius {
    UIView *instanceView =[[[self class] alloc] initWithFrame:rect];
    [instanceView lab_addGradientLayer:direction colors:colors cornerRadius:radius];
    
    return instanceView;
}

+ (instancetype)lab_initFrame:(CGRect)rect gradientColor:(NSArray<UIColor *> *)colors cornerRadius:(CGFloat)radius {
    return [[self class] lab_initFrame:rect gradientColor:colors gradientDirection:LABGradientDirectionHorizontal cornerRadius:radius];
}




- (CGFloat)labX {
    return CGRectGetMinX(self.frame);
}

- (CGFloat)labY {
    return CGRectGetMinY(self.frame);
}

- (CGFloat)labBottom {
    return CGRectGetMaxY(self.frame);
}

- (CGFloat)labRight {
    return CGRectGetMaxX(self.frame);
}

- (CGFloat)labWidth {
    return CGRectGetWidth(self.bounds);
}

- (CGFloat)labHeight {
    return CGRectGetHeight(self.bounds);
}

- (CGFloat)labCenterX {
    return self.center.x;
}

- (CGFloat)labCenterY {
    return self.center.y;
}

@end
