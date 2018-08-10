//
//  WebSocketManager.m
//  Douyin
//
//  Created by Qiao Shi on 2018/7/30.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

#import "WebSocketManager.h"
#import "Constants.h"
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
    }
    return self;
}

//KVO，观察SRWebSocket.readyState值变化来实时监听当前连接状态
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"readyState"]) {
        //状态为正在关闭SR_CLOSING或者关闭SR_CLOSED则重新建立连接，重连间隔时间为5s，最大重连次数为5次
        if(_webSocket.readyState == SR_CLOSING || _webSocket.readyState == SR_CLOSED) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if(self.webSocket.readyState == SR_OPEN) {
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
        if(_webSocket.readyState == SR_OPEN) {
            _reOpenCount = 0;
        }
    } else {
        return [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
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
    [_webSocket addObserver:self forKeyPath:@"readyState" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionPrior context:nil];
    [_webSocket open];
}

//重新连接
- (void)reConnect {
    [self disConnect];
    [self connect];
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

- (void)dealloc {
    [_webSocket removeObserver:self forKeyPath:@"readyState"];
}
@end
