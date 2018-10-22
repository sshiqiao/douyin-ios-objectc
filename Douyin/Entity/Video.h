//
//  Video.h
//  Douyin
//
//  Created by Qiao Shi on 2018/7/30.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

#import "BaseModel.h"

@class Dynamic_cover;
@class Play_addr_lowbr;
@class Play_addr;
@class Cover;
@class Bit_rate;
@class Origin_cover;
@class Download_addr;

@interface Video :BaseModel
@property (nonatomic , strong) Dynamic_cover              * dynamic_cover;
@property (nonatomic , strong) Play_addr_lowbr              * play_addr_lowbr;
@property (nonatomic , assign) NSInteger              width;
@property (nonatomic , copy) NSString              * ratio;
@property (nonatomic , strong) Play_addr              * play_addr;
@property (nonatomic , strong) Cover              * cover;
@property (nonatomic , assign) NSInteger              height;
@property (nonatomic , copy) NSArray<Bit_rate *>              * bit_rate;
@property (nonatomic , strong) Origin_cover              * origin_cover;
@property (nonatomic , assign) NSInteger              duration;
@property (nonatomic , strong) Download_addr              * download_addr;
@property (nonatomic , assign) BOOL              has_watermark;
@end

@interface Dynamic_cover :BaseModel
@property (nonatomic , copy) NSArray<NSString *>              * url_list;
@property (nonatomic , copy) NSString              * uri;
@end

@interface Play_addr_lowbr :BaseModel
@property (nonatomic , copy) NSArray<NSString *>              * url_list;
@property (nonatomic , copy) NSString              * uri;
@end

@interface Play_addr :BaseModel
@property (nonatomic , copy) NSArray<NSString *>              * url_list;
@property (nonatomic , copy) NSString              * uri;
@end

@interface Cover :BaseModel
@property (nonatomic , copy) NSArray<NSString *>              * url_list;
@property (nonatomic , copy) NSString              * uri;
@end

@interface Bit_rate :BaseModel
@property (nonatomic , assign) NSInteger              bit_rate;
@property (nonatomic , copy) NSString              * gear_name;
@property (nonatomic , assign) NSInteger              quality_type;
@end

@interface Origin_cover :BaseModel
@property (nonatomic , copy) NSArray<NSString *>              * url_list;
@property (nonatomic , copy) NSString              * uri;
@end

@interface Download_addr :BaseModel
@property (nonatomic , copy) NSArray<NSString *>              * url_list;
@property (nonatomic , copy) NSString              * uri;
@end

