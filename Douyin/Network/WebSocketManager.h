//
//  WebSocketManager.h
//  Douyin
//
//  Created by Qiao Shi on 2018/7/30.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

#import <UIKit/UIKit.h>

//定义消息通知常量名称
extern NSString *const WebSocketDidReceiveMessageNotification;

@interface WebSocketManager:NSObject
//WebSocketManager单例
+ (instancetype)shareManager;
//断开连接
- (void)disConnect;
//连接
- (void)connect;
//发送消息
- (void)sendMessage:(id)msg;

@end
