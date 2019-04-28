//
//  NSString+Laboratory.h
//  Laboratory-objc
//
//  Created by qeeniao35 on 2019/1/18.
//  Copyright © 2019 CodeZ. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef LABSystemParameters

#define LABSystemParameters(args) [NSString lab_systemName:args]

#endif

/**
 系统参数类型

 - LABSystemBundleIdentity: bundleId
 - LABSystemBundleDisplayName: bundleName
 - LABSystemAppVersion: app版本号
 - LABSystemiOSVersion: iOS系统版本号
 - LABSystemName: 系统名称
 - LABSystemUUID: 广告版本号
 - LABSystemIDFA: 跟广告版本号一样
 - LABSystemDeviceName: 手机设备名称
 */
typedef NS_ENUM(NSInteger, LABSystemParameters) {
    LABSystemBundleIdentity,
    LABSystemBundleDisplayName,
    LABSystemAppVersion,
    LABSystemiOSVersion,
    LABSystemName,
    LABSystemUUID,
    LABSystemIDFA,
    LABSystemDeviceName
};

@interface NSString (Laboratory)
/**
 获取字符串的宽度

 @param font 字体样式
 @param height 限制高度
 @return 字符串的宽度
 */
- (CGFloat)lab_stringWidth:(UIFont *)font limitHeight:(CGFloat)height;

/**
 获取字符串的高度

 @param font 字体样式
 @param width 限制宽度
 @return 字符串的高度
 */
- (CGFloat)lab_stringHeight:(UIFont *)font limitWidth:(CGFloat)width;


#pragma mark - 系统参数
+ (NSString *)lab_systemName:(LABSystemParameters)systemParameters;



@end
