//
//  LABBaseViewController.h
//  Laboratory-objc
//
//  Created by qeeniao35 on 2019/1/21.
//  Copyright © 2019 CodeZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LABNavigationBar.h"

@interface LABBaseViewController : UIViewController
/**
 自定义的导航栏视图
 */
@property (nonatomic, retain) LABNavigationBar *labNavgationBar;

/**
 返回上一页视图控制器
 */
- (void)lab_popViewController;

/**
 导航栏右按钮响应
 */
- (void)lab_rightBarItemHandler;


#pragma mark - public methods
/**
 配置子视图控件
 */
- (void)lab_addSubViews;

/**
 配置通知事件
 */
- (void)lab_addNotifications;

/**
 配置数据源
 */
- (void)lab_addDataSource;

@end

