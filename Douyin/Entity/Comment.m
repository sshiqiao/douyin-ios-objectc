//
//  Comment.m
//  Douyin
//
//  Created by Qiao Shi on 2018/7/30.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

#import "Comment.h"

@implementation Comment

-(instancetype)init:(NSString *)awemeId text:(NSString *)text taskId:(NSInteger)taskId {
    self = [super init];
    if(self) {
        _aweme_id = awemeId;
        _text = text;
        _isTemp = YES;
        _taskId = taskId;
        
        _digg_count = 0;
        _create_time = [[NSDate new] timeIntervalSince1970];
        _user_digged = 0;
    }
    return self;
}

@end
