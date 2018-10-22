//
//  AwemeListResponse.h
//  Douyin
//
//  Created by Qiao Shi on 2018/7/30.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

#import "BaseResponse.h"
#import "Aweme.h"

@interface AwemeListResponse:BaseResponse

@property (nonatomic, copy) NSArray<Aweme *> <Aweme>   *data;

@end
