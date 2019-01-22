//
//  LABNavigationBar.h
//  Laboratory-objc
//
//  Created by qeeniao35 on 2019/1/21.
//  Copyright © 2019 CodeZ. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 导航栏按钮类型

 - LABNavigationBarItemTypeDefault: 默认类型(没有样式)
 - LABNavigationBarItemTypeBackButton: 左按钮
 - LABNavigationBarItemTypeRightButton: 右按钮
 */
typedef NS_ENUM(NSInteger, LABNavigationBarItemType) {
    LABNavigationBarItemTypeDefault,
    LABNavigationBarItemTypeBackButton,
    LABNavigationBarItemTypeRightButton
};

@interface LABNavigationBar : UIView

/**
 标题文本
 */
@property (nonatomic, retain) UILabel *titleLabel;

/**
 导航栏中间视图
 */
@property (nonatomic, retain) UIView *navgationBar;

/**
 顶部分割线
 */
@property (nonatomic, retain) CALayer *seperatorLine;

/**
 导航栏左键
 */
@property (nonatomic, retain) UIButton *leftNavigationBarItem;

/**
 导航栏右键
 */
@property (nonatomic, retain) UIButton *rightNavigationBarItem;

@property (nonatomic, copy) void(^navigationBarItemBlock)(LABNavigationBarItemType);

@end

