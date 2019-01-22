//
//  UIButton+Laboratory.m
//  Laboratory-objc
//
//  Created by qeeniao35 on 2019/1/18.
//  Copyright © 2019 CodeZ. All rights reserved.
//

#import <objc/runtime.h>
#import "UIButton+Laboratory.h"


static const void *lab_button_callback_key = @"labButtonCallbackKey";

@implementation UIButton (Laboratory)

@dynamic clickCompletion;

+ (instancetype)lab_initButton:(CGRect)rect image:(NSString *)imageName {
    UIButton *button = [[UIButton alloc] initWithFrame:rect];
    if (imageName.length > 0 && imageName != nil) {
        [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    }
    button.adjustsImageWhenHighlighted = NO;
    
    return button;
}

+ (instancetype)lab_initButton:(NSString *)imageName {
    return [[self class] lab_initButton:CGRectZero image:imageName];
}


+ (instancetype)lab_initButton:(CGRect)rect title:(NSString *)title font:(UIFont *)font titleColor:(UIColor *)titleColor backgroundColor:(UIColor *)backgroundColor {
    UIButton *button = [[self class] p_initButton:rect backgroundColor:backgroundColor];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:titleColor forState:UIControlStateNormal];
    button.titleLabel.font = font;
    
    return button;
}

+ (instancetype)lab_initButtonTitile:(NSString *)title font:(UIFont *)font titleColor:(UIColor *)titleColor backgroundColor:(UIColor *)backgroundColor {
    return [[self class] lab_initButton:CGRectZero title:title font:font titleColor:titleColor backgroundColor:backgroundColor];
}


#pragma mark - 实例方法
- (void)lab_imageName:(NSString *)imageName {
    if (imageName.length > 0 && imageName != nil) {
        [self setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    }
}

- (void)buttonClick:(id)target selector:(SEL)selector {
    [self addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
}

- (void)buttonClickCompletion:(void (^)(void))completion {
    self.clickCompletion = completion;
    [self addTarget:self action:@selector(p_buttonHandler) forControlEvents:UIControlEventTouchUpInside];
}

- (void)p_buttonHandler {
    if (self.clickCompletion) {
        self.clickCompletion();
    }
}



#pragma mark - private methods
+ (instancetype)p_initButton:(CGRect)rect backgroundColor:(UIColor *)color {
    UIButton *button = [[UIButton alloc] initWithFrame:rect];
    button.adjustsImageWhenHighlighted = NO;
    button.backgroundColor = color;
    
    return button;
}

- (void)setClickCompletion:(LABbuttonClick)clickCompletion {
    [self willChangeValueForKey:@"clickCompletion"];
    objc_setAssociatedObject(self, lab_button_callback_key, clickCompletion, OBJC_ASSOCIATION_COPY);
    [self didChangeValueForKey:@"clickCompletion"];
}

- (LABbuttonClick)clickCompletion {
    return objc_getAssociatedObject(self, lab_button_callback_key);
}

@end
