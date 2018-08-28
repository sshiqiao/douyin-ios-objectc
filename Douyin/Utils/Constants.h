//
//  Constants.h
//  Douyin
//
//  Created by Qiao Shi on 2018/7/30.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

#import "UIWindow+Extension.h"
#import "NSString+Extension.h"
#import "NSDate+Extension.h"
#import "UIImage+Extension.h"
#import "NSNotification+Extension.h"
#import "NSAttributedString+Extension.h"
#import "UIImageView+WebCache.h"

#define NetworkDomain @"com.start.douyin"

//请求地址
#define BaseUrl @"http://116.62.9.17:8080/douyin/"
//#define BaseUrl @"http://192.168.1.2:8080/"

//创建访客用户接口
#define CREATE_VISITOR_BY_UDID_URL             @"visitor/create"

//根据用户id获取用户信息
#define FIND_USER_BY_UID_URL                   @"user"

//获取用户发布的短视频列表数据
#define FIND_AWEME_POST_BY_PAGE_URL            @"aweme/post"
//获取用户喜欢的短视频列表数据
#define FIND_AWEME_FAVORITE_BY_PAGE_URL        @"aweme/favorite"

//发送文本类型群聊消息
#define POST_GROUP_CHAT_TEXT_URL               @"groupchat/text"
//发送单张图片类型群聊消息
#define POST_GROUP_CHAT_IMAGE_URL              @"groupchat/image"
//发送多张图片类型群聊消息
#define POST_GROUP_CHAT_IMAGES_URL             @"groupchat/images"
//根据id获取指定图片
#define FIND_GROUP_CHAT_BY_IMAGE_ID_URL        @"groupchat/image"
//获取群聊列表数据
#define FIND_GROUP_CHAT_BY_PAGE_URL            @"groupchat/list"
//根据id删除指定群聊消息
#define DELETE_GROUP_CHAT_BY_ID_URL            @"groupchat/delete"

//根据视频id发送评论
#define POST_COMMENT_URL                       @"comment/post"
//根据id删除评论
#define DELETE_COMMENT_BY_ID_URL               @"comment/delete"
//获取评论列表
#define FIND_COMMENT_BY_PAGE_URL               @"comment/list"

#define StatusBarTouchBeginNotification        @"StatusBarTouchBeginNotification"

//loading type enum
typedef NS_ENUM(NSUInteger,LoadingType) {
    LoadStateIdle                   = 0,
    LoadStateLoading                = 1,
    LoadStateAll                    = 2,
    LoadStateFailed                 = 3
};

//refreshing type enum
typedef NS_ENUM(NSUInteger,RefreshingType) {
    RefreshHeaderStateIdle          = 0,
    RefreshHeaderStatePulling       = 1,
    RefreshHeaderStateRefreshing    = 2,
    RefreshHeaderStateAll           = 3
};

//chat edit message type enum
typedef NS_ENUM(NSUInteger,ChatEditMessageType) {
    EditTextMessage        = 0,
    EditPhotoMessage       = 1,
    EditEmotionMessage     = 2,
    EditNoneMessage        = 3,
};

typedef NS_ENUM(NSUInteger,MenuActionType) {
    DeleteAction        = 0,
    CopyAction         = 1,
    PasteAction         = 2
};

#define writeVisitor(visitor)\
({\
NSDictionary *dic = [visitor toDictionary];\
NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];\
[defaults setObject:dic forKey:@"visitor"];\
[defaults synchronize];\
})


#define readVisitor()\
({\
NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];\
NSDictionary *dic = [defaults objectForKey:@"visitor"];\
Visitor *visitor = [[Visitor alloc] initWithDictionary:dic error:nil];\
(visitor);\
})


#define dispatch_main_sync_safe(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_sync(dispatch_get_main_queue(), block);\
}

#define dispatch_main_async_safe(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_async(dispatch_get_main_queue(), block);\
}


//UDID MD5_UDID
#define UDID [[[UIDevice currentDevice] identifierForVendor] UUIDString]
#define MD5_UDID [UDID md5]

//width
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

#define STATUS_BAR_HEIGHT [UIApplication sharedApplication].statusBarFrame.size.height

#define SCREEN_FRAME [UIScreen mainScreen].bounds

#define UIViewX(control) (control.frame.origin.x)
#define UIViewY(control) (control.frame.origin.y)


#define UIViewWidth(view) CGRectGetWidth(view.frame)
#define UIViewHeight(view) CGRectGetHeight(view.frame)

#define UIViewMaxX(view) CGRectGetMaxX(view.frame)
#define UIViewMaxY(view) CGRectGetMaxY(view.frame)

#define UIViewMinX(view) CGRectGetMinX(view.frame)
#define UIViewMinY(view) CGRectGetMinY(view.frame)

#define UIViewMidX(view) CGRectGetMidX(view.frame)
#define UIViewMidY(view) CGRectGetMidY(view.frame)

//color
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0 \
green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0    \
blue:((float)(rgbValue & 0xFF)) / 255.0             \
alpha:1.0]

#define RGBA(R, G, B, A) [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:A]

#define ColorWhiteAlpha10 RGBA(255.0, 255.0, 255.0, 0.1)
#define ColorWhiteAlpha20 RGBA(255.0, 255.0, 255.0, 0.2)
#define ColorWhiteAlpha40 RGBA(255.0, 255.0, 255.0, 0.4)
#define ColorWhiteAlpha60 RGBA(255.0, 255.0, 255.0, 0.6)
#define ColorWhiteAlpha80 RGBA(255.0, 255.0, 255.0, 0.8)

#define ColorBlackAlpha1 RGBA(0.0, 0.0, 0.0, 0.01)
#define ColorBlackAlpha5 RGBA(0.0, 0.0, 0.0, 0.05)
#define ColorBlackAlpha10 RGBA(0.0, 0.0, 0.0, 0.1)
#define ColorBlackAlpha20 RGBA(0.0, 0.0, 0.0, 0.2)
#define ColorBlackAlpha40 RGBA(0.0, 0.0, 0.0, 0.4)
#define ColorBlackAlpha60 RGBA(0.0, 0.0, 0.0, 0.6)
#define ColorBlackAlpha80 RGBA(0.0, 0.0, 0.0, 0.8)
#define ColorBlackAlpha90 RGBA(0.0, 0.0, 0.0, 0.9)

#define ColorThemeGrayLight RGBA(104.0, 106.0, 120.0, 1.0)
#define ColorThemeGray RGBA(92.0, 93.0, 102.0, 1.0)
#define ColorThemeGrayDark RGBA(20.0, 21.0, 30.0, 1.0)
#define ColorThemeYellow RGBA(250.0, 206.0, 21.0, 1.0)
#define ColorThemeYellowDark RGBA(235.0, 181.0, 37.0, 1.0)
#define ColorThemeBackground RGBA(14.0, 15.0, 26.0, 1.0)

#define ColorThemeRed RGBA(241.0, 47.0, 84.0, 1.0)

#define ColorRoseRed RGBA(220.0, 46.0, 123.0, 1.0)
#define ColorClear [UIColor clearColor]
#define ColorBlack [UIColor blackColor]
#define ColorWhite [UIColor whiteColor]
#define ColorGray  [UIColor grayColor]
#define ColorBlue RGBA(40.0, 120.0, 255.0, 1.0)
#define ColorGrayLight RGBA(40.0, 40.0, 40.0, 1.0)
#define ColorGrayDark RGBA(25.0, 25.0, 35.0, 1.0)
#define ColorSmoke RGBA(230.0, 230.0, 230.0, 1.0)


//Font
#define SuperSmallFont [UIFont systemFontOfSize:10.0]
#define SuperSmallBoldFont [UIFont boldSystemFontOfSize:10.0]

#define SmallFont [UIFont systemFontOfSize:12.0]
#define SmallBoldFont [UIFont boldSystemFontOfSize:12.0]

#define MediumFont [UIFont systemFontOfSize:14.0]
#define MediumBoldFont [UIFont boldSystemFontOfSize:14.0]

#define BigFont [UIFont systemFontOfSize:16.0]
#define BigBoldFont [UIFont boldSystemFontOfSize:16.0]

#define LargeFont [UIFont systemFontOfSize:18.0]
#define LargeBoldFont [UIFont boldSystemFontOfSize:18.0]

#define SuperBigFont [UIFont systemFontOfSize:26.0]
#define SuperBigBoldFont [UIFont boldSystemFontOfSize:26.0]
