//
//  LABIMCenter.h
//  Laboratory-objc
//
//  Created by qeeniao35 on 2019/3/1.
//  Copyright © 2019 CodeZ. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LABIMCenter : NSObject
@property (nonatomic, copy, readonly) NSString *addressIp;

@property (nonatomic, assign, readonly) NSInteger port;


+ (instancetype)defaultCenter;

- (void)connectServer:(NSString *)ip port:(NSInteger)port;


- (void)sendData:(id)data completion:(void(^)(BOOL success, NSError *error))completion;


/**
 断开连接(主动)
 */
- (void)disconnectServer;


/**
 重新连接
 */
- (void)reconnectServer;

@end

NS_ASSUME_NONNULL_END
