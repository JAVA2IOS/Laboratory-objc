//
//  QueueManager.m
//  Laboratory-objc
//
//  Created by huangqing on 2020/5/23.
//  Copyright © 2020 CodeZ. All rights reserved.
//

#import "QueueManager.h"
#import "TaskOperation.h"

@implementation OperationTask
@end


@interface QueueManager()
@property (nonatomic, retain) NSOperationQueue *queue;
@property (nonatomic, retain) NSMutableDictionary<NSString *, OperationTask *> *operations;
@property (nonatomic, retain) OperationTask *task;

@end

@implementation QueueManager
+ (instancetype)instance {
    static dispatch_once_t onceToken;
    static QueueManager *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[QueueManager alloc] init];
    });
    
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _queue = [[NSOperationQueue alloc] init];
        _queue.maxConcurrentOperationCount = 3;
        _task = [[OperationTask alloc] init];
    }
    return self;
}


+ (void)statQueue {
    if ([QueueManager instance].task.dependencyOperation) {
        if ([[QueueManager instance].task.dependencyOperation isExecuting]) {
            NSLog(@"取消当前执行的任务[%@]", [QueueManager instance].task.dependencyOperation);
            [[QueueManager instance].task.dependencyOperation cancel];
        }
    }
    
    if ([QueueManager instance].task.operation) {
        if ([[QueueManager instance].task.operation isExecuting]) {
            NSLog(@"取消当前执行的任务[%@]", [QueueManager instance].task.operation);
            [[QueueManager instance].task.operation cancel];
        }
    }
    
    TaskOperation *dependencyOperation = [[TaskOperation alloc] init];
    [QueueManager instance].task.dependencyOperation = dependencyOperation;
    Weak(dependencyOperation)
    dependencyOperation.completionBlock = ^{
        NSLog(@"依赖任务[%@]完成", weakdependencyOperation);
    };
    NSLog(@"初始化依赖任务任务[%@]", dependencyOperation);
    
    TaskOperation *operation = [[TaskOperation alloc] init];
    [QueueManager instance].task.operation = operation;
    Weak(operation)
    operation.completionBlock = ^{
        NSLog(@"任务[%@]完成", weakoperation);
    };
    NSLog(@"初始化最后的任务[%@]", operation);
    
    [operation addDependency:dependencyOperation];
    [[QueueManager instance].queue addOperation:dependencyOperation];
    [[QueueManager instance].queue addOperation:operation];
}

+ (void)endQueue {
    NSLog(@"起始队列汇总的任务:[%@]", [QueueManager instance].queue.operations);
    if (![[QueueManager instance].task.dependencyOperation isFinished]) {
        NSLog(@"任务[%@]主动取消", [QueueManager instance].task.dependencyOperation);
        [[QueueManager instance].task.dependencyOperation cancel];
    }
    if (![[QueueManager instance].task.operation isFinished]) {
        NSLog(@"任务[%@]主动取消", [QueueManager instance].task.operation);
        [[QueueManager instance].task.operation cancel];
    }
    
    NSLog(@"最后的队列汇总的任务:[%@]", [QueueManager instance].queue.operations);
}

@end
