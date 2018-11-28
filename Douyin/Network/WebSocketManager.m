//
//  WebSocketManager.m
//  Douyin
//
//  Created by Qiao Shi on 2018/7/30.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

#import "WebSocketManager.h"
#import "SocketRocket.h"
#import "NetworkHelper.h"

//赋值消息通知常量名称
NSString *const WebSocketDidReceiveMessageNotification = @"WebSocketDidReceiveMessageNotification";
//最大连接次数
NSInteger const MaxReConnectTime = 5;

@interface WebSocketManager ()<SRWebSocketDelegate>
@property (nonatomic, strong) SRWebSocket            *webSocket;  //Websocket对象
@property (nonatomic, strong) NSMutableURLRequest    *request;    //Websocket请求
@property (nonatomic, assign) NSInteger              reOpenCount; //已经重新建立连接的次数
@end

@implementation WebSocketManager

//WebSocketManager单例
+(instancetype)shareManager {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [self new];
    });
    return instance;
}

//初始化
-(instancetype)init {
    self = [super init];
    if(self) {
        //将http scheme改为ws scheme
        NSURLComponents *components = [[NSURLComponents alloc] initWithURL:[NSURL URLWithString:[BaseUrl stringByAppendingString:@"/groupchat"]] resolvingAgainstBaseURL:NO];
        components.scheme = @"ws";
        NSURL *url = [components URL];
        //初始化Websocket连接请求
        _request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30];
        //连接参数为udid
        [_request addValue:UDID forHTTPHeaderField:@"udid"];
        _reOpenCount = 0;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNetworkStatusChange:) name:NetworkStatesChangeNotification object:nil];
    }
    return self;
}

//网络状态发送变化，判断是否重新连接
-(void)onNetworkStatusChange:(NSNotification *)notification {
    if(_webSocket != nil && ![NetworkHelper isNotReachableStatus:[NetworkHelper networkStatus]] && [self isClosed]) {
        [self reConnect];
    }
}

//断开连接
- (void)disConnect {
    if(_webSocket.readyState == SR_CLOSING || _webSocket.readyState == SR_CLOSED) {
        return;
    }
    [_webSocket close];
    _webSocket = nil;
}

//连接
-(void)connect {
    if(_webSocket.readyState == SR_OPEN) {
        [self disConnect];
    }
    _webSocket = [[SRWebSocket alloc] initWithURLRequest:_request];
    _webSocket.delegate = self;
    [_webSocket open];
}

//重新连接
- (void)reConnect {
    [self disConnect];
    [self connect];
}

//判断连接是否断开
- (BOOL)isClosed {
    if(_webSocket.readyState == SR_OPEN || _webSocket.readyState == SR_CLOSED) {
        return YES;
    }
    return NO;
}

//开启多次重新连接
- (void)startReconnect {
    if(![NetworkHelper isNotReachableStatus:[NetworkHelper networkStatus]]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if(![self isClosed]) {
                self.reOpenCount = 0;
                return;
            }
            if(self.reOpenCount >= MaxReConnectTime) {
                self.reOpenCount = 0;
                return;
            }
            [self reConnect];
            self.reOpenCount++;
        });
    }
}

//发送消息
- (void)sendMessage:(id)msg {
    if(_webSocket.readyState == SR_OPEN) {
        [_webSocket send:msg];
    }
}

//SRWebSocketDelegate代理方法
- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    //发送消息接收通知
    [[NSNotificationCenter defaultCenter] postNotificationName:WebSocketDidReceiveMessageNotification object:message];
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    _reOpenCount = 0;
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    [self startReconnect];
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    [self startReconnect];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
