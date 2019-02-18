//
//  UILabel+Laboratory.m
//  Laboratory-objc
//
//  Created by qeeniao35 on 2019/1/21.
//  Copyright © 2019 CodeZ. All rights reserved.
//

#import "UILabel+Laboratory.h"

@implementation UILabel (Laboratory)
+ (instancetype)lab_initFrame:(CGRect)frame titleColor:(UIColor *)titleColor backgroundColor:(UIColor *)backgroundColor font:(UIFont *)font {
    UILabel *label = [UILabel lab_initFrame:frame backgourndColor:backgroundColor cornerRadius:0];
    if (font == nil) {
        label.font = [UIFont systemFontOfSize:frame.size.height - 1];
    }else {
        label.font = font;
    }
    
    label.textColor = titleColor;
    
    return label;
}

+ (instancetype)lab_initFrame:(CGRect)frame titleColor:(UIColor *)titleColor font:(UIFont *)font {
    return [[self class] lab_initFrame:frame titleColor:titleColor backgroundColor:[UIColor clearColor] font:font];
}

+ (instancetype)lab_initFrame:(CGRect)frame titleColor:(UIColor *)titleColor {
    return [[self class] lab_initFrame:frame titleColor:titleColor font:nil];
}

- (void)lab_addAttributeString:(NSString *)string attributes:(NSDictionary *)attributes {
    [self lab_addAttributeString:string attributes:attributes sizeToFit:NO];
}

- (void)lab_addAttributeString:(NSString *)string attributes:(NSDictionary *)attributes sizeToFit:(BOOL)sizeToFit {
    self.numberOfLines = 0;
    NSMutableAttributedString *mutAttributeString = [[NSMutableAttributedString alloc] initWithString:string attributes:attributes];
    self.attributedText = mutAttributeString;
    if (sizeToFit) {
        CGFloat height = [self.attributedText lab_stringHeightLimitWidth:self.labWidth];
        self.frame = CGRectMake(self.labX, self.labY, self.labWidth, height);
    }
}

- (void)sizeToFit {
    if (self.text.length > 0) {
        CGFloat width = [self.text lab_stringWidth:self.font limitHeight:self.labHeight];
        self.frame = CGRectMake(self.labX, self.labY, width, self.labHeight);
        return;
    }
    
    self.frame = CGRectMake(self.labX, self.labY, 0, self.labHeight);
}

@end
