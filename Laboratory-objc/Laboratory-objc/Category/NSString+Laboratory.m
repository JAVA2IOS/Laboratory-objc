//
//  NSString+Laboratory.m
//  Laboratory-objc
//
//  Created by qeeniao35 on 2019/1/18.
//  Copyright © 2019 CodeZ. All rights reserved.
//

#import "NSString+Laboratory.h"

@implementation NSString (Laboratory)
- (CGFloat)lab_stringHeight:(UIFont *)font limitWidth:(CGFloat)width {
    return [self lab_attrubteStringHeight:@{NSFontAttributeName : font} limitWidth:width];
}

- (CGFloat)lab_attrubteStringHeight:(NSDictionary *)attributes limitWidth:(CGFloat)width {
    CGSize size = [self boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    
    return size.height;
}

- (CGFloat)lab_stringWidth:(UIFont *)font limitHeight:(CGFloat)height {
    return [self lab_attributeStringWidth:@{NSFontAttributeName : font} limitHeight:height];
}

- (CGFloat)lab_attributeStringWidth:(NSDictionary *)attributes limitHeight:(CGFloat)height {
    CGSize size = [self boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, height) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    
    return size.height;
}

+ (NSString *)lab_systemName:(LABSystemParameters)systemParameters {
    switch (systemParameters) {
        case LABSystemBundleIdentity:
            return [NSBundle mainBundle].bundleIdentifier;
            break;
        case LABSystemBundleDisplayName:
            return [NSBundle mainBundle].infoDictionary[@"CFBundleDisplayName"];
            break;
        case LABSystemAppVersion:
            return [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"];
            break;
        case LABSystemiOSVersion:
            return [UIDevice currentDevice].systemVersion;
            break;
        case LABSystemName:
            return [UIDevice currentDevice].systemName;
            break;
        case LABSystemDeviceName:
            return [UIDevice currentDevice].name;
            break;
        case LABSystemIDFA:
            return [UIDevice currentDevice].identifierForVendor.UUIDString;
            break;
        case LABSystemUUID:
            return [UIDevice currentDevice].identifierForVendor.UUIDString;
            break;
        default:
            break;
    }
    
    return @"";
}
@end
