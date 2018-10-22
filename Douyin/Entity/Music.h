//
//  Music.h
//  Douyin
//
//  Created by Qiao Shi on 2018/7/30.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

#import "BaseModel.h"

@class Cover_large;
@class Cover_thumb;
@class Cover_medium;
@class Cover_hd;
@class Play_url;

@interface Music :BaseModel
@property (nonatomic , copy) NSString              * extra;
@property (nonatomic , strong) Cover_large              * cover_large;
@property (nonatomic , assign) NSInteger              id;
@property (nonatomic , strong) Cover_thumb              * cover_thumb;
@property (nonatomic , copy) NSString              * mid;
@property (nonatomic , strong) Cover_hd              * cover_hd;
@property (nonatomic , copy) NSString              * author;
@property (nonatomic , assign) NSInteger              user_count;
@property (nonatomic , strong) Play_url              * play_url;
@property (nonatomic , strong) Cover_medium              * cover_medium;
@property (nonatomic , copy) NSString              * id_str;
@property (nonatomic , copy) NSString              * title;
@property (nonatomic , copy) NSString              * offline_desc;
@property (nonatomic , assign) BOOL              is_restricted;
@property (nonatomic , copy) NSString              * schema_url;
@property (nonatomic , assign) NSInteger              source_platform;
@property (nonatomic , assign) NSInteger              duration;
@property (nonatomic , assign) NSInteger              status;
@property (nonatomic , assign) BOOL              is_original;
@end

@interface Cover_large :BaseModel
@property (nonatomic , copy) NSArray<NSString *>              * url_list;
@property (nonatomic , copy) NSString              * uri;
@end

@interface Cover_thumb :BaseModel
@property (nonatomic , copy) NSArray<NSString *>              * url_list;
@property (nonatomic , copy) NSString              * uri;
@end

@interface Cover_medium :BaseModel
@property (nonatomic , copy) NSArray<NSString *>              * url_list;
@property (nonatomic , copy) NSString              * uri;
@end


@interface Cover_hd :BaseModel
@property (nonatomic , copy) NSArray<NSString *>              * url_list;
@property (nonatomic , copy) NSString              * uri;
@end

@interface Play_url :BaseModel
@property (nonatomic , copy) NSArray<NSString *>              * url_list;
@property (nonatomic , copy) NSString              * uri;
@end
