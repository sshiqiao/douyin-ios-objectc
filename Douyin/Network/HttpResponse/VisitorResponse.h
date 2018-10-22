//
//  VisitorResponse.h
//  Douyin
//
//  Created by Qiao Shi on 2018/7/30.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

#import "BaseResponse.h"
#import "Visitor.h"

@interface VisitorResponse:BaseResponse

@property (nonatomic, copy) Visitor   *data;

@end
