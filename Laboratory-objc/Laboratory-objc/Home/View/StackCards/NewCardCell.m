//
//  NewCardCell.m
//  Laboratory-objc
//
//  Created by qeeniao35 on 2019/10/29.
//  Copyright © 2019 CodeZ. All rights reserved.
//

#import "NewCardCell.h"

@implementation NewCardCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self.contentView addSubview:self.label];
    }
    
    return self;
}

- (UILabel *)label {
    return _label ?: ({
        _label = [[UILabel alloc] initWithFrame:self.contentView.frame];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.font = [UIFont systemFontOfSize:18];
        _label.textColor = [UIColor blackColor];
        
        _label;
    });
}
@end
