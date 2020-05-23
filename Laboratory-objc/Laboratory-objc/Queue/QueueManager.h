//
//  QueueManager.h
//  Laboratory-objc
//
//  Created by huangqing on 2020/5/23.
//  Copyright © 2020 CodeZ. All rights reserved.
//

#import <Foundation/Foundation.h>
@class TaskOperation;
NS_ASSUME_NONNULL_BEGIN

@interface OperationTask : NSObject
@property (nonatomic, retain) TaskOperation *dependencyOperation;
@property (nonatomic, retain) TaskOperation *operation;
@end

@interface QueueManager : NSObject
+ (void)statQueue;
+ (void)endQueue;
@end

NS_ASSUME_NONNULL_END
