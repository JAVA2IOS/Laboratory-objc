//
//  UIColor+Laboratory.m
//  Laboratory-objc
//
//  Created by qeeniao35 on 2019/1/18.
//  Copyright © 2019 CodeZ. All rights reserved.
//

#import "UIColor+Laboratory.h"

@implementation UIColor (Laboratory)
+ (UIColor *)randomColor {
    CGFloat red = arc4random() % 256 / 255.0;
    CGFloat green = arc4random() % 256 / 255.0;
    CGFloat blue = arc4random() % 256 / 255.0;
    return [UIColor colorWithRed:red green:green blue:blue alpha:1];
}

+ (UIColor * _Nullable)colorWithHexString:(NSString * _Nonnull)string {
    
    //Color with string and a defualt alpha value of 1.0
    return [self colorWithHexString:string withAlpha:1.0];
}

+ (UIColor * _Nullable)colorWithHexString:(NSString * _Nonnull)string withAlpha:(CGFloat)alpha {
    
    //Quick return in case string is empty
    if (string.length == 0) {
        return nil;
    }
    
    //Check to see if we need to add a hashtag
    if('#' != [string characterAtIndex:0]) {
        string = [NSString stringWithFormat:@"#%@", string];
    }
    
    //Make sure we have a working string length
    if (string.length != 7 && string.length != 4) {
        
#ifdef DEBUG
        NSLog(@"Unsupported string format: %@", string);
#endif
        
        return nil;
    }
    
    //Check for short hex strings
    if(string.length == 4) {
        
        //Convert to full length hex string
        string = [NSString stringWithFormat:@"#%@%@%@%@%@%@",
                  [string substringWithRange:NSMakeRange(1, 1)],[string substringWithRange:NSMakeRange(1, 1)],
                  [string substringWithRange:NSMakeRange(2, 1)],[string substringWithRange:NSMakeRange(2, 1)],
                  [string substringWithRange:NSMakeRange(3, 1)],[string substringWithRange:NSMakeRange(3, 1)]];
    }
    
    NSString *redHex = [NSString stringWithFormat:@"0x%@", [string substringWithRange:NSMakeRange(1, 2)]];
    unsigned red = [[self class] hexValueToUnsigned:redHex];
    
    NSString *greenHex = [NSString stringWithFormat:@"0x%@", [string substringWithRange:NSMakeRange(3, 2)]];
    unsigned green = [[self class] hexValueToUnsigned:greenHex];
    
    NSString *blueHex = [NSString stringWithFormat:@"0x%@", [string substringWithRange:NSMakeRange(5, 2)]];
    unsigned blue = [[self class] hexValueToUnsigned:blueHex];
    
    return [UIColor colorWithRed:(float)red/255 green:(float)green/255 blue:(float)blue/255 alpha:alpha];
}

+ (unsigned)hexValueToUnsigned:(NSString *)hexValue {
    
    //Define default unsigned value
    unsigned value = 0;
    
    //Scan unsigned value
    NSScanner *hexValueScanner = [NSScanner scannerWithString:hexValue];
    [hexValueScanner scanHexInt:&value];
    
    //Return found value
    return value;
}


#pragma mark - 随机颜色
+ (UIColor * _Nullable)colorWithRandomColorInArray:(NSArray<UIColor *> *)colors {
    
    UIColor *randomColor;
    if (colors.count) {
        
        //Pick a random index
        NSInteger randomIndex = arc4random() % colors.count;
        
        //Return the color at the random index
        randomColor = colors[randomIndex];
        
    } else {
        return nil;
    }
    
    NSAssert([randomColor isKindOfClass:[UIColor class]], @"Hmm... one of your objects in your 'colors' array is not a UIColor object.");
    
    //Return
    return randomColor;
}


#pragma mark - 从图片中抓取颜色
+ (UIColor *)colorWithAverageColorFromImage:(UIImage *)image {
    
    return [self colorWithAverageColorFromImage:image withAlpha:1.0];
}

+ (UIColor *)colorWithAverageColorFromImage:(UIImage *)image withAlpha:(CGFloat)alpha {
    
    //Work within the RGB colorspoace
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char rgba[4];
    CGContextRef context = CGBitmapContextCreate(rgba, 1, 1, 8, 4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    //Draw our image down to 1x1 pixels
    CGContextDrawImage(context, CGRectMake(0, 0, 1, 1), image.CGImage);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    //Check if image alpha is 0
    if (rgba[3] == 0) {
        
        CGFloat imageAlpha = ((CGFloat)rgba[3])/255.0;
        CGFloat multiplier = imageAlpha/255.0;
        
        UIColor *averageColor = [UIColor colorWithRed:((CGFloat)rgba[0])*multiplier green:((CGFloat)rgba[1])*multiplier blue:((CGFloat)rgba[2])*multiplier alpha:imageAlpha];
        
        //Improve color
        averageColor = [averageColor colorWithMinimumSaturation:0.15];
        
        //Return average color
        return averageColor;
    }
    
    else {
        
        //Get average
        UIColor *averageColor = [UIColor colorWithRed:((CGFloat)rgba[0])/255.0 green:((CGFloat)rgba[1])/255.0 blue:((CGFloat)rgba[2])/255.0 alpha:alpha];
        
        //Improve color
        averageColor = [averageColor colorWithMinimumSaturation:0.15];
        
        //Return average color
        return averageColor;
    }
}

- (UIColor *)colorWithMinimumSaturation:(CGFloat)saturation {
    if (!self)
        return nil;
    
    CGFloat h, s, b, a;
    [self getHue:&h saturation:&s brightness:&b alpha:&a];
    
    if (s < saturation)
        return [UIColor colorWithHue:h saturation:saturation brightness:b alpha:a];
    
    return self;
}


/**
 颜色值

 @return 十六位制颜色编码字符串
 */
- (NSString *)hexValue {
    
    UIColor *currentColor = self;
    if (CGColorGetNumberOfComponents(self.CGColor) < 4) {
        const CGFloat *components = CGColorGetComponents(self.CGColor);
        currentColor = [UIColor colorWithRed:components[0] green:components[0] blue:components[0] alpha:components[1]];
    }
    
    if (CGColorSpaceGetModel(CGColorGetColorSpace(currentColor.CGColor)) != kCGColorSpaceModelRGB) {
        return [NSString stringWithFormat:@"#FFFFFF"];
    }
    
    return [NSString stringWithFormat:@"#%02X%02X%02X", (int)((CGColorGetComponents(currentColor.CGColor))[0]*255.0), (int)((CGColorGetComponents(currentColor.CGColor))[1]*255.0), (int)((CGColorGetComponents(currentColor.CGColor))[2]*255.0)];
    
}


// 颜色深浅
- (BOOL)lab_deepColor {
    CGFloat red = 0.0, green = 0.0, blue = 0.0, alpha = 0.0;
    if ([self getRed:&red green:&green blue:&blue alpha:&alpha]) {
        float referenceValue = 0.411;
        float colorDelta = ((red * 0.299) + (green * 0.587) + (blue * 0.114));
        
        return 1.0 - colorDelta > referenceValue;
    }
    
    return YES;
}


// 透明度
- (CGFloat)lab_alpha {
    CGFloat a;
    if ([self getRed:0 green:0 blue:0 alpha:&a]) {
        return a;
    }
    
    return 0;
}


// 颜色不透明
- (UIColor *)lab_withoutAlphaColor {
    CGFloat r;
    CGFloat g;
    CGFloat b;
    if ([self getRed:&r green:&g blue:&b alpha:0]) {
        return [UIColor colorWithRed:r green:g blue:b alpha:1];
    } else {
        return nil;
    }
}

@end
