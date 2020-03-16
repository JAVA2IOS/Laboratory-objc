//
//  UserCollectionCell.m
//  Laboratory-objc
//
//  Created by q huang on 2020/1/3.
//  Copyright © 2020 CodeZ. All rights reserved.
//

#import "UserCollectionCell.h"
#import "IGUserModel.h"

@interface UserCollectionCell()
@property (nonatomic, retain) UILabel *idLabel;
@end

@implementation UserCollectionCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self.contentView addSubview:self.titleLabel];
    }
    
    return self;
}


#pragma mark - getter & setter
- (void)setUserModel:(IGUserModel *)userModel {
    _userModel = userModel;
    _titleLabel.text = _userModel.name;
}

- (UILabel *)titleLabel {
    return _titleLabel ?: ({
        _titleLabel = [UILabel lab_initFrame:self.contentView.bounds titleColor:[UIColor colorWithHexString:@"#262a33"] backgroundColor:[UIColor colorWithHexString:@"#d3d9e6" withAlpha:.6] font:[UIFont systemFontOfSize:12]];

        _titleLabel;
    });
}

@end
