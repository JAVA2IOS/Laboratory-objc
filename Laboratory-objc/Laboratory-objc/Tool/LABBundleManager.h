//
//  LABBundleManager.h
//  Laboratory-objc
//
//  Created by qeeniao35 on 2019/1/21.
//  Copyright © 2019 CodeZ. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 关于所有图片资源文件名的类型枚举

 - LABImageBundleSourceTypeNone: 资源类型无
 - LABImageBundleSourceType_Navigation_backLightArrow: 导航栏左箭头浅色
 - LABImageBundleSourceType_Navigation_backDarkArrow: 导航栏左箭头深色
 */
typedef NS_ENUM(NSInteger, LABImageBundleSourceType) {
    LABImageBundleSourceTypeNone,
    LABImageBundleSourceType_Navigation_backLightArrow,
    LABImageBundleSourceType_Navigation_backDarkArrow,
};

@interface LABBundleManager : NSObject

/**
 图片资源文件名

 @param bundleType 图片资源类型枚举
 @return 图片资源文件名
 */
+ (NSString *)bundleName:(LABImageBundleSourceType)bundleType;

@end

