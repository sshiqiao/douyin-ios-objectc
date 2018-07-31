//
//  Header.h
//  Douyin
//
//  Created by Qiao Shi on 2018/7/30.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseResponse.h"
#import "Comment.h"
@interface CommentListResponse:BaseResponse
@property (nonatomic, copy) NSArray<Comment>   *data;
@end
