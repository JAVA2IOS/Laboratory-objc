//
//  TaskOperation.m
//  Laboratory-objc
//
//  Created by huangqing on 2020/5/23.
//  Copyright © 2020 CodeZ. All rights reserved.
//

#import "TaskOperation.h"

@interface TaskOperation()
@property (nonatomic, assign) BOOL stop;
@end

@implementation TaskOperation
@synthesize finished = _finished;

- (void)main {
    @autoreleasepool {
        if (self.isFinished) {
            return;
        }
        NSLog(@"当前[%@]进度: 1， 任务开始", self);
        [NSThread sleepForTimeInterval:2];
        if (self.isFinished) {
            return;
        }
        NSLog(@"当前[%@]进度: 2 ---", self);
        [NSThread sleepForTimeInterval:3];
        if (self.isFinished) {
            return;
        }
        NSLog(@"当前[%@]进度: 4 ---", self);
        [NSThread sleepForTimeInterval:5];
        if (self.isFinished) {
            return;
        }
        NSLog(@"当前[%@]进度: 5 ---", self);
        [NSThread sleepForTimeInterval:10];
        if (self.isFinished) {
            NSLog(@"任务[%@]取消了，不再执行", self);
            return;
        }
        NSLog(@"当前[%@]进度: 10, 任务完成", self);
    }
}

- (BOOL)asynchronous {
    return YES;
}

- (void)cancel {
    [super cancel];
    NSLog(@"接收到当前任务[%@]取消!", self);
    self.finished = YES;
}

- (void)setFinished:(BOOL)finished {
    [self willChangeValueForKey:@"finished"];
    _finished = finished;
    [self didChangeValueForKey:@"finished"];
}

@end
