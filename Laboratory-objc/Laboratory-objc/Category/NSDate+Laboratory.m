//
//  NSDate+Laboratory.m
//  Laboratory-objc
//
//  Created by qeeniao35 on 2019/1/18.
//  Copyright © 2019 CodeZ. All rights reserved.
//

#import "NSDate+Laboratory.h"

@implementation NSDate (Laboratory)

+ (NSTimeInterval)lab_currentTimeStamp {
    return [NSDate timeIntervalSinceReferenceDate];
}

+ (NSTimeInterval)lab_currentTimeStampMS {
    return [self lab_currentTimeStamp] * 1000;
}


+ (NSDateFormatter *)lab_dateformatter:(LABDateFormatterType)formatterType {
    return [[self class] lab_dateformatterStyle:[[self class] lab_dateFormatterString:formatterType]];
}

+ (NSDateFormatter *)lab_dateformatterStyle:(NSString *)formatterStyle {
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    dateformatter.dateFormat = formatterStyle;
    
    return dateformatter;
}


- (NSString *)lab_dateStringFormatter:(LABDateFormatterType)formatterType {
    return [[[self class] lab_dateformatterStyle:[[self class] lab_dateFormatterString:formatterType]] stringFromDate:self];
}

- (NSString *)lab_dateStringFormatterStyle:(NSString *)formatterStyle {
    return [[[self class] lab_dateformatterStyle:formatterStyle] stringFromDate:self];
}


/**
 根据格式化类型获取格式化字符串

 @param formatterType 格式化枚举类型
 @return 格式化字符串
 */
+ (NSString *)lab_dateFormatterString:(LABDateFormatterType)formatterType {
    switch (formatterType) {
        case LABDateFormatterTypeYMD:
            return @"yyyy-MM-dd";
            break;
        case LABDateFormatterTypeYMDhms:
            return @"yyy-MM-dd HH:mm:ss";
            break;
        case LABDateFormatterTypehm:
            return @"HH:mm";
            break;
        case LABDateFormatterTypehms:
            return @"HH:mm:ss";
            break;
        default:
            break;
    }
    
    return @"yyyy";
}

@end
