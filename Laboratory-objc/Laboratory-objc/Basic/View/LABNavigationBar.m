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
        [self addSubview:self.leftNavigationBarItem];
        [self addSubview:self.rightNavigationBarItem];
        self.seperatorLine = [self lab_addSubLayer:LabColor(@"4c97ff")
                                   RoundingCorners:UIRectCornerAllCorners
                                            inRect:CGRectMake(0, self.labHeight - .5, self.labWidth, .5)
                                       cornerRadii:0];
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
        _leftNavigationBarItem = [UIButton lab_initButton:CGRectMake(0, LABStatusBarHeight, LABNavBarHeight, LABNavBarHeight) image:LABBundleImage(LABImageBundleSourceType_Navigation_backDarkArrow)];
        WeakSelf(self)
        [_leftNavigationBarItem buttonClickCompletion:^{
            if (weakself.navigationBarItemBlock) {
                weakself.navigationBarItemBlock(LABNavigationBarItemTypeBackButton);
            }
        }];
    }
    
    return _leftNavigationBarItem;
}

- (UIButton *)rightNavigationBarItem {
    if (!_rightNavigationBarItem) {
        _rightNavigationBarItem = [UIButton lab_initButton:CGRectMake(self.labWidth - LABNavBarHeight, LABStatusBarHeight, LABNavBarHeight, LABNavBarHeight) image:LABBundleImage(LABImageBundleSourceTypeNone)];
        WeakSelf(self)
        [_rightNavigationBarItem buttonClickCompletion:^{
            if (weakself.navigationBarItemBlock) {
                weakself.navigationBarItemBlock(LABNavigationBarItemTypeRightButton);
            }
        }];
    }
    
    return _rightNavigationBarItem;
}

@end
