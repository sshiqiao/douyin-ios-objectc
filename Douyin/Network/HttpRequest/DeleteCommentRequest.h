//
//  DeleteCommentRequest.h
//  Douyin
//
//  Created by Qiao Shi on 2018/7/30.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

#import "BaseRequest.h"

@interface DeleteCommentRequest:BaseRequest

@property (nonatomic, copy) NSString *cid;
@property (nonatomic, copy) NSString *udid;

@end
