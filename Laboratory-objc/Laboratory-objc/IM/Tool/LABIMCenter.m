//
//  LABIMCenter.m
//  Laboratory-objc
//
//  Created by qeeniao35 on 2019/3/1.
//  Copyright © 2019 CodeZ. All rights reserved.
//

#import "LABIMCenter.h"
#import <GCDAsyncSocket.h>


@interface LABIMCenter()<GCDAsyncSocketDelegate>

@property (nonatomic, retain) GCDAsyncSocket *socket;

@property (nonatomic, copy, readwrite) NSString *addressIp;

@property (nonatomic, assign, readwrite) NSInteger port;

@end

@implementation LABIMCenter

+ (instancetype)defaultCenter {
    static LABIMCenter *instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[LABIMCenter alloc] init];
    });
    
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    }
    
    return self;
}


#pragma mark - 操作请求
- (void)connectServer:(NSString *)ip port:(NSInteger)port {
    if (ip == nil) {
        
        return;
    }
    NSError *error = nil;
    [_socket connectToHost:self.addressIp onPort:self.port error:&error];
    
    if (error) {
        
        return;
    }
}

/**
 断开连接
 */
- (void)disconnectServer {
    [_socket disconnect];
}

/**
 重新连接
 */
- (void)reconnectServer {
}


/**
 发送请求

 @param data 发送的数据
 @param completion 回调方法
 */
- (void)sendData:(id)data completion:(void (^)(BOOL, NSError * _Nonnull))completion {
    [_socket writeData:data withTimeout:-1 tag:1];
}





#pragma mark - GCDAsyncSocketDelegate

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    // 发送数据
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    // 读取数据
}

- (void)socketDidCloseReadStream:(GCDAsyncSocket *)sock {
    
}

@end
