//
//  User.h
//  Douyin
//
//  Created by Qiao Shi on 2018/7/30.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

#import "BaseModel.h"


@class Avatar;
@class Policy_version;
@class Geofencing;
@class Video_icon;
@class Activity;

@interface User :BaseModel
@property (nonatomic , copy) NSString              * weibo_name;
@property (nonatomic , copy) NSString              * google_account;
@property (nonatomic , assign) NSInteger              special_lock;
@property (nonatomic , assign) BOOL              is_binded_weibo;
@property (nonatomic , assign) NSInteger              shield_follow_notice;
@property (nonatomic , assign) BOOL              user_canceled;
@property (nonatomic , strong) Avatar              * avatar_larger;
@property (nonatomic , assign) BOOL              accept_private_policy;
@property (nonatomic , assign) NSInteger              follow_status;
@property (nonatomic , assign) BOOL              with_commerce_entry;
@property (nonatomic , copy) NSString              * original_music_qrcode;
@property (nonatomic , assign) NSInteger              authority_status;
@property (nonatomic , copy) NSString              * youtube_channel_title;
@property (nonatomic , assign) BOOL              is_ad_fake;
@property (nonatomic , assign) BOOL              prevent_download;
@property (nonatomic , assign) NSInteger              verification_type;
@property (nonatomic , assign) BOOL              is_gov_media_vip;
@property (nonatomic , copy) NSString              * weibo_url;
@property (nonatomic , copy) NSString              * twitter_id;
@property (nonatomic , assign) NSInteger              need_recommend;
@property (nonatomic , assign) NSInteger              comment_setting;
@property (nonatomic , assign) NSInteger              status;
@property (nonatomic , copy) NSString              * unique_id;
@property (nonatomic , assign) BOOL              hide_location;
@property (nonatomic , copy) NSString              * enterprise_verify_reason;
@property (nonatomic , assign) NSInteger              aweme_count;
@property (nonatomic , assign) NSInteger              story_count;
@property (nonatomic , assign) NSInteger              unique_id_modify_time;
@property (nonatomic , assign) NSInteger              follower_count;
@property (nonatomic , assign) NSInteger              apple_account;
@property (nonatomic , copy) NSString              * short_id;
@property (nonatomic , copy) NSString              * account_region;
@property (nonatomic , copy) NSString              * signature;
@property (nonatomic , copy) NSString              * twitter_name;
@property (nonatomic , strong) Avatar              * avatar_medium;
@property (nonatomic , copy) NSString              * verify_info;
@property (nonatomic , assign) NSInteger              create_time;
@property (nonatomic , assign) BOOL              story_open;
@property (nonatomic , strong) Policy_version              * policy_version;
@property (nonatomic , copy) NSString              * region;
@property (nonatomic , assign) BOOL              hide_search;
@property (nonatomic , strong) Avatar              * avatar_thumb;
@property (nonatomic , copy) NSString              * school_poi_id;
@property (nonatomic , assign) NSInteger              shield_comment_notice;
@property (nonatomic , assign) NSInteger              total_favorited;
@property (nonatomic , strong) Video_icon              * video_icon;
@property (nonatomic , copy) NSString              * original_music_cover;
@property (nonatomic , assign) NSInteger              following_count;
@property (nonatomic , assign) NSInteger              shield_digg_notice;
@property (nonatomic , copy) NSArray<Geofencing *>              * geofencing;
@property (nonatomic , copy) NSString              * bind_phone;
@property (nonatomic , assign) BOOL              has_email;
@property (nonatomic , assign) NSInteger              live_verify;
@property (nonatomic , copy) NSString              * birthday;
@property (nonatomic , assign) NSInteger              duet_setting;
@property (nonatomic , copy) NSString              * ins_id;
@property (nonatomic , assign) NSInteger              follower_status;
@property (nonatomic , assign) NSInteger              live_agreement;
@property (nonatomic , assign) NSInteger              neiguang_shield;
@property (nonatomic , copy) NSString              * uid;
@property (nonatomic , assign) NSInteger              secret;
@property (nonatomic , assign) BOOL              is_phone_binded;
@property (nonatomic , assign) NSInteger              live_agreement_time;
@property (nonatomic , copy) NSString              * weibo_schema;
@property (nonatomic , assign) BOOL              is_verified;
@property (nonatomic , copy) NSString              * custom_verify;
@property (nonatomic , assign) NSInteger              commerce_user_level;
@property (nonatomic , assign) NSInteger              gender;
@property (nonatomic , assign) BOOL              has_orders;
@property (nonatomic , copy) NSString              * youtube_channel_id;
@property (nonatomic , assign) NSInteger              reflow_page_gid;
@property (nonatomic , assign) NSInteger              reflow_page_uid;
@property (nonatomic , copy) NSString              * nickname;
@property (nonatomic , assign) NSInteger              school_type;
@property (nonatomic , copy) NSString              * avatar_uri;
@property (nonatomic , copy) NSString              * weibo_verify;
@property (nonatomic , assign) NSInteger              favoriting_count;
@property (nonatomic , copy) NSString              * share_qrcode_uri;
@property (nonatomic , assign) NSInteger              room_id;
@property (nonatomic , assign) NSInteger              constellation;
@property (nonatomic , copy) NSString              * school_name;
@property (nonatomic , strong) Activity              * activity;
@property (nonatomic , assign) NSInteger              user_rate;
@property (nonatomic , copy) NSString              * video_icon_virtual_URI;

@end

@interface Avatar :BaseModel
@property (nonatomic , copy) NSArray<NSString *>              * url_list;
@property (nonatomic , copy) NSString              * uri;
@end

@interface Policy_version :BaseModel
@end

@interface Url_list :BaseModel
@end

@interface Video_icon :BaseModel
@property (nonatomic , copy) NSArray<Url_list *>               * url_list;
@property (nonatomic , copy) NSString              * uri;

@end

@interface Geofencing :BaseModel
@end

@interface Activity :BaseModel
@property (nonatomic , assign) NSInteger              digg_count;
@property (nonatomic , assign) NSInteger              use_music_count;

@end
