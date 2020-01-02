//
//  IMSocket.h
//  Laboratory-objc
//
//  Created by qeeniao35 on 2019/12/11.
//  Copyright © 2019 CodeZ. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SRWebSocket;

typedef void(^IMSocketReceivedMessage)(id _Nonnull message);

NS_ASSUME_NONNULL_BEGIN

@interface IMSocket : NSObject
@property (nonatomic, retain, readonly) SRWebSocket *webSocket;

+ (instancetype)sharedInstance;

/// 重新配置链接的地址,需要重新链接
/// @param url url地址
/// @param port 端口号
/// @param schema shema协议
+ (void)configureUrl:(NSString *)url port:(NSNumber *)port schema:(NSString *)schema;

/// 打开链接
+ (void)connect;

/// 关闭链接
+ (void)close;

+ (void)sendMessage:(id)message;


- (void)receivedMessage:(IMSocketReceivedMessage)block;

@end

NS_ASSUME_NONNULL_END
