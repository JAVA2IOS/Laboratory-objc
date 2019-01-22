//
//  NSDate+Laboratory.h
//  Laboratory-objc
//
//  Created by qeeniao35 on 2019/1/18.
//  Copyright © 2019 CodeZ. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 日期格式化

 - LABDateFormatterTypeYMD: yyyy-MM-dd
 - LABDateFormatterTypeYMDhms: yyy-MM-dd hh:mm:ss
 - LABDateFormatterTypehms: hh:mm:ss
 - LABDateFormatterTypehm: hh:mm
 */
typedef NS_ENUM(NSInteger, LABDateFormatterType) {
    LABDateFormatterTypeYMD,
    LABDateFormatterTypeYMDhms,
    LABDateFormatterTypehms,
    LABDateFormatterTypehm
};

@interface NSDate (Laboratory)
/**
 当前时间戳秒级

 @return 时间戳
 */
+ (NSTimeInterval)lab_currentTimeStamp;

/**
 当前时间戳毫秒级

 @return 毫秒级时间戳
 */
+ (NSTimeInterval)lab_currentTimeStampMS;

/**
 日期格式化

 @param formatterType 格式化类型
 @return 日期格式化对象
 */
+ (NSDateFormatter *)lab_dateformatter:(LABDateFormatterType)formatterType;

/**
 日期格式化

 @param formatterStyle 格式化字符串
 @return 日期格式化对象
 */
+ (NSDateFormatter *)lab_dateformatterStyle:(NSString *)formatterStyle;

/**
 将日期转化为字符串

 @param formatterType 格式化类型
 @return 日期格式化字符串
 */
- (NSString *)lab_dateStringFormatter:(LABDateFormatterType)formatterType;

/**
 将日期转化为字符串

 @param formatterStyle 格式化字符串
 @return 日期格式化字符串
 */
- (NSString *)lab_dateStringFormatterStyle:(NSString *)formatterStyle;

@end

