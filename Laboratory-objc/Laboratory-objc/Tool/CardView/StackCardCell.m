//
//  StackCardCell.m
//  Laboratory-objc
//
//  Created by qeeniao35 on 2019/4/28.
//  Copyright © 2019 CodeZ. All rights reserved.
//

#import "StackCardCell.h"

@interface StackCardCell()
@property (nonatomic, retain, readwrite) UIView *contentView;
@property (nonatomic, copy, readwrite) NSString *identifier;
@end

@implementation StackCardCell

+ (instancetype)initWithIdentifer:(NSString *)idenfitier atIndexPath:(NSIndexPath *)indexPath frame:(CGRect)frame {
    StackCardCell *cell = [[[self class] alloc] initWithFrame:frame];
    cell.indexPath = indexPath;
    cell.identifier = idenfitier;
    
    return cell;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
    }
    
    return self;
}

- (UIView *)contentView {
    return _contentView ?: ({
        _contentView = [[UIView alloc] initWithFrame:self.bounds];
        [self addSubview:_contentView];
        
        _contentView;
    });
}

@end
