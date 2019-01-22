//
//  UIViewController+Laboratory.m
//  Laboratory-objc
//
//  Created by qeeniao35 on 2019/1/18.
//  Copyright © 2019 CodeZ. All rights reserved.
//

#import "UIViewController+Laboratory.h"

@implementation UIViewController (Laboratory)
- (void)lab_pushChildViewController:(Class)className {
    if (self.navigationController) {
        UIViewController *viewController = [[className alloc] init];
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

- (void)lab_pushChildViewControllerName:(NSString *)conrollerName {
    [self lab_pushChildViewController:NSClassFromString(conrollerName)];
}

@end
