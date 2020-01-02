//
//  QHKeyboardView.m
//  Laboratory-objc
//
//  Created by q huang on 2019/12/17.
//  Copyright © 2019 CodeZ. All rights reserved.
//

#import "QHKeyboardView.h"
@interface QHKeyboardView()<UIInputViewAudioFeedback>

@end

@implementation QHKeyboardView


#pragma mark - 按键声音
- (BOOL)enableInputClicksWhenVisible {
    return YES;
}

@end
