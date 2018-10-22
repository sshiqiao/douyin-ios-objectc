//
//  DeleteGroupChatRequest.h
//  Douyin
//
//  Created by Qiao Shi on 2018/7/30.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

#import "BaseRequest.h"

@interface DeleteGroupChatRequest:BaseRequest

@property (nonatomic, copy) NSString *id;
@property (nonatomic, copy) NSString *udid;

@end
