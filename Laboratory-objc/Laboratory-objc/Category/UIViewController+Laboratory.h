//
//  UIViewController+Laboratory.h
//  Laboratory-objc
//
//  Created by qeeniao35 on 2019/1/18.
//  Copyright © 2019 CodeZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Laboratory)

/**
 push到子视图控制器

 @param conrollerName 子视图控制器类型字符串
 */
- (void)lab_pushChildViewControllerName:(NSString *)conrollerName;

/**
 push到子视图控制器

 @param className 子视图控制器类
 */
- (void)lab_pushChildViewController:(Class)className;

@end
