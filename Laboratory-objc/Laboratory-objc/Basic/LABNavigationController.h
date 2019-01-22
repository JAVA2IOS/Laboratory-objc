//
//  LABNavigationController.h
//  Laboratory-objc
//
//  Created by qeeniao35 on 2019/1/21.
//  Copyright © 2019 CodeZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LABNavigationBar.h"

@interface LABNavigationController : UINavigationController
/**
 自定义的导航栏视图
 */
@property (nonatomic, retain) LABNavigationBar *labNavgationBar;

@end

