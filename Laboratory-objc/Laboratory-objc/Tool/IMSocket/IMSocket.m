//
//  IMSocket.m
//  Laboratory-objc
//
//  Created by qeeniao35 on 2019/12/11.
//  Copyright © 2019 CodeZ. All rights reserved.
//

#import "IMSocket.h"
#import "SocketRocket/SRWebSocket.h"
#import <SocketRocket/SocketRocket.h>

#define IMSocketAddress @"172.18.1.244"
//#define IMSocketAddress @"127.0.0.1"
#define IMSocketPort 8080

@interface IMSocket()<SRWebSocketDelegate>
@property (nonatomic, retain, readwrite) SRWebSocket *webSocket;
@property (nonatomic, retain, readwrite) NSURL *url;
@property (nonatomic, retain, readwrite) NSTimer *heartTimer;
@property (nonatomic, assign, readwrite) NSTimeInterval reconnectTime;
/**
 接收到消息
 */
@property (nonatomic, copy) IMSocketReceivedMessage callBack;

@end

@implementation IMSocket

+ (instancetype)sharedInstance {
    static IMSocket *instacne = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instacne = [[IMSocket alloc] init];
    });
    
    return instacne;
}

- (instancetype)init {
    if (self = [super init]) {
        
        NSURLComponents *urlComponents = [NSURLComponents componentsWithString:[NSString stringWithFormat:@"http://%@:%@/api/v0/ws?uid=12&name=user", IMSocketAddress, @(IMSocketPort)]];

        self.url = [NSURL URLWithString:urlComponents.string];
    }
    
    return self;
}

- (void)_initUrl {
    _webSocket.delegate = nil;
    [[self class] configureUrl:IMSocketAddress port:@(IMSocketPort) schema:@"http"];
    [_webSocket open];
}


#pragma mark - public
- (void)receivedMessage:(IMSocketReceivedMessage)block {
    _callBack = block;
}

+ (void)configureUrl:(NSString *)url port:(NSNumber *)port schema:(NSString *)schema {
    [[self class] close];
    NSURLComponents *urlComponents = [NSURLComponents componentsWithString:[NSString stringWithFormat:@"%@://%@:%@/api/v0/ws?uid=12&name=user", schema, url, port]];
    
    [IMSocket sharedInstance].url = [NSURL URLWithString:urlComponents.string];
}

+ (void)connect {
    [[IMSocket sharedInstance].webSocket close];
    [[IMSocket sharedInstance] _initUrl];
}

+ (void)close {
    [[IMSocket sharedInstance].webSocket close];
}

+ (void)sendMessage:(id)message {
    if ([IMSocket sharedInstance].webSocket.readyState != SR_OPEN) {
        NSLog(@"没有打开啊");
        if ([IMSocket sharedInstance].callBack) {
            [IMSocket sharedInstance].callBack(@"没有打开通讯");
        }
        return;
    }
    
    [[IMSocket sharedInstance].webSocket send:@"发送消息了"];
}

#pragma mark - private
- (void)_addHeartTimer {
    [self _closeHeartTimer];
    NSLog(@"开启定时器发送心跳");
    // 定时时长需要跟后台协商，如果后台有设置超时时限，要保证当前时长不超过后台设置的超时时长，否则会造成断开连接
    _heartTimer = [NSTimer timerWithTimeInterval:25 target:self selector:@selector(_sendHeartPong) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_heartTimer forMode:NSRunLoopCommonModes];
}

- (void)_sendHeartPong {
    NSLog(@"定时心跳发送，保持长链接---");
    [_webSocket sendPing:[@"IM heart pong" dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)_closeHeartTimer {
    [_heartTimer invalidate];
    _heartTimer = nil;
}

- (void)_reconnect {
    if (_reconnectTime > 64) {
        return;
    }
    
    WeakSelf(self)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_reconnectTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self->_callBack) {
            self->_callBack(@"正在重新连接服务器");
        }
        [[weakself class] connect];
    });
    
    if (_reconnectTime <= 0) {
        _reconnectTime = 2;
    }else {
        _reconnectTime *= 2;
    }
}


#pragma mark - gettet & setter
- (void)setUrl:(NSURL *)url {
    _url = [url copy];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:_url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20];

    _webSocket = [[SRWebSocket alloc] initWithURLRequest:request protocols:@[@"chat"]];
    [_webSocket setDelegate:self];
//    [_webSocket setDelegateDispatchQueue:dispatch_get_main_queue()];
}


#pragma mark - delegate
- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    if (_callBack) {
        _callBack(message);
    }
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
//    NSLog(@"是否打开了链接");
    [self _addHeartTimer];
    _reconnectTime = 0;

    SRReadyState state = webSocket.readyState;
    NSString *message = @"";
    switch (state) {
        case SR_CLOSED:
        {
            message = @"链接中断了";
        }
            break;
        case SR_OPEN:
            message = @"正常链接";
            break;
        case SR_CONNECTING:
            message = @"正在链接，需要等待";
            break;
        case SR_CLOSING:
            message = @"正在关闭，不能处理";
            break;
            
        default:
            break;
    }
    
    if (_callBack) {
        _callBack(message);
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    if (_callBack) {
        _callBack([NSString stringWithFormat:@"链接关闭: %d, %@",(int)code, reason]);
    }
    [self _closeHeartTimer];
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    [self _closeHeartTimer];
    [[self class] close];
    NSLog(@"链接失败: %@", error);
    if (_callBack) {
        _callBack([NSString stringWithFormat:@"链接失败: %@", error]);
    }
    [self _reconnect];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload {
    NSLog(@"心跳返回响应");
}

@end
