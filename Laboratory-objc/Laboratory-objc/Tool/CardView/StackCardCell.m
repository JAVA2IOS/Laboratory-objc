//
//  StackCardCell.m
//  Laboratory-objc
//
//  Created by qeeniao35 on 2019/4/28.
//  Copyright © 2019 CodeZ. All rights reserved.
//

#import "StackCardCell.h"

@interface StackCardCell()
@property (nonatomic, retain, readwrite) UILabel *label;
@property (nonatomic, copy, readwrite) NSString *identifier;
@end

@implementation StackCardCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.identifier = [[self class] reusableIdenfier];
        
        _label = [[UILabel alloc] initWithFrame:self.bounds];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.textColor = LabColor(@"#9196a1");
        [self addSubview:_label];
        
        self.backgroundColor = [UIColor randomColor];
    }
    
    return self;
}

- (NSString *)identifier {
    return [[self class] reusableIdenfier];
}

+ (NSString *)reusableIdenfier {
    return [NSStringFromClass([self class]) stringByAppendingString:@"_god_of_meow"];
}

@end
