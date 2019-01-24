//
//  LABBundleManager.m
//  Laboratory-objc
//
//  Created by qeeniao35 on 2019/1/21.
//  Copyright © 2019 CodeZ. All rights reserved.
//

#import "LABBundleManager.h"

@implementation LABBundleManager

+ (NSString *)bundleName:(LABImageBundleSourceType)bundleType {
    switch (bundleType) {
        case LABImageBundleSourceTypeNone:
            return @"";
            break;
        case LABImageBundleSourceType_Navigation_backDarkArrow:
            return [[self class] p_prefixNavigationIcon:@"icon_leftDarkArrow"];
            break;
        case LABImageBundleSourceType_Navigation_backLightArrow:
            return [[self class] p_prefixNavigationIcon:@"icon_leftLightArrow"];
            break;
        case LABImageBundleSourceType_Table_icon_sortable:
            return [[self class] p_prefixTableIcon:@"icon_sortable"];
            break;
        default:
            break;
    }
    
    return @"";
}

/*
 lab_area(视图的区域)_imageName(资源名称)
 */

+ (NSString *)p_prefixNavigationIcon:(NSString *)suffixName {
    return [@"lab_navigation_" stringByAppendingString:suffixName];
}


+ (NSString *)p_prefixTableIcon:(NSString *)suffixName {
    return [@"lab_table_" stringByAppendingString:suffixName];
}

@end
