//
//  LABNavigationBar.m
//  Laboratory-objc
//
//  Created by qeeniao35 on 2019/1/21.
//  Copyright © 2019 CodeZ. All rights reserved.
//

#import "LABNavigationBar.h"

@implementation LABNavigationBar

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.navgationBar];
        [self addSubview:self.titleLabel];
    }
    
    return self;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel lab_initFrame:CGRectMake(0, LABStatusBarHeight, self.labWidth, LABNavBarHeight) titleColor:[UIColor colorWithHexString:@"4c97ff"] font:[UIFont systemFontOfSize:18]];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    return _titleLabel;
}

- (UIView *)navgationBar {
    if (!_navgationBar) {
        _navgationBar = [UIView lab_initFrame:CGRectMake(0, LABStatusBarHeight, self.labWidth, LABNavBarHeight) cornerRadius:0];
        _navgationBar.backgroundColor = [UIColor clearColor];
    }
    
    return _navgationBar;
}

- (UIButton *)leftNavigationBarItem {
    if (!_leftNavigationBarItem) {
        _leftNavigationBarItem = [UIButton lab_initButton:CGRectMake(0, 0, 0, 0) image:LABBundleImage(LABImageBundleSourceType_Navigation_backDarkArrow)];
    }
    
    return _leftNavigationBarItem;
}

- (UIButton *)rightNavigationBarItem {
    if (!_rightNavigationBarItem) {
        _rightNavigationBarItem = [UIButton lab_initButton:CGRectMake(0, 0, 0, 0) image:LABBundleImage(LABImageBundleSourceTypeNone)];
    }
    
    return _rightNavigationBarItem;
}

@end
