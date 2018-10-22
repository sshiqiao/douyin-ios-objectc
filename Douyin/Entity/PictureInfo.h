//
//  PictureInfo.h
//  Douyin
//
//  Created by Qiao Shi on 2018/7/30.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

#import "BaseModel.h"

@interface PictureInfo :BaseModel

@property (nonatomic, copy) NSString      *file_id;
@property (nonatomic, copy) NSString      *url;
@property (nonatomic, assign) NSInteger   width;
@property (nonatomic, assign) NSInteger   height;
@property (nonatomic, copy) NSString      *type;

@end
