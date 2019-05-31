//
//  StackCardCell.m
//  Laboratory-objc
//
//  Created by qeeniao35 on 2019/4/28.
//  Copyright © 2019 CodeZ. All rights reserved.
//

#import "StackCardCell.h"

@interface StackCardCell()
@property (nonatomic, copy, readwrite) NSString *identifier;
@property (nonatomic, assign, readwrite) NSInteger index;
@end

@implementation StackCardCell
- (instancetype)initWithIndex:(NSInteger)index reusableIdentifier:(NSString *)reusableIdentifier {
    if (self = [super init]) {
        self.identifier = reusableIdentifier;
        self.index = index;
        
        self.backgroundColor = [UIColor randomColor];
    }
    
    return self;
}

@end
