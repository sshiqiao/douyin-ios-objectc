//
//  NetworkHelper.h
//  Douyin
//
//  Created by Qiao Shi on 2018/7/30.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPSessionManager.h"
#import "Constants.h"

#import "BaseResponse.h"
#import "VisitorResponse.h"
#import "UserResponse.h"
#import "AwemeResponse.h"
#import "AwemeListResponse.h"
#import "AwemeResponse.h"
#import "GroupChatResponse.h"
#import "GroupChatListResponse.h"
#import "CommentResponse.h"
#import "CommentListResponse.h"

#import "BaseRequest.h"
#import "VisitorRequest.h"
#import "UserRequest.h"
#import "AwemeListRequest.h"
#import "GroupChatListRequest.h"
#import "PostGroupChatTextRequest.h"
#import "PostGroupChatImageRequest.h"
#import "DeleteGroupChatRequest.h"
#import "CommentListRequest.h"
#import "PostCommentRequest.h"
#import "DeleteCommentRequest.h"

extern NSString *const NetworkStatesChangeNotification;

typedef enum {
    HttpResquestFailed = -1000,
    UrlResourceFailed = -2000
} NetworkError;

#define NetworkDomain @"com.start.douyin"

typedef void (^UploadProgress)(CGFloat percent);
typedef void (^HttpSuccess)(id data);
typedef void (^HttpFailure)(NSError *error);

@interface NetworkHelper : NSObject


+(AFHTTPSessionManager *)sharedManager;


+(NSURLSessionDataTask *)getWithUrlPath:(NSString *)urlPath request:(BaseRequest *)request success:(HttpSuccess)success failure:(HttpFailure)failure;


+(NSURLSessionDataTask *)deleteWithUrlPath:(NSString *)urlPath request:(BaseRequest *)request success:(HttpSuccess)success failure:(HttpFailure)failure;

+(NSURLSessionDataTask *)postWithUrlPath:(NSString *)urlPath request:(BaseRequest *)request success:(HttpSuccess)success failure:(HttpFailure)failure;

+(NSURLSessionDataTask *)uploadWithUrlPath:(NSString *)urlPath data:(NSData *)data request:(BaseRequest *)request progress:(UploadProgress)progress success:(HttpSuccess)success failure:(HttpFailure)failure;


+(NSURLSessionDataTask *)uploadWithUrlPath:(NSString *)urlPath dataArray:(NSArray<NSData *> *)dataArray request:(BaseRequest *)request progress:(UploadProgress)progress success:(HttpSuccess)success failure:(HttpFailure)failure;


//Reachability
+ (AFNetworkReachabilityManager *)shareReachabilityManager;

+ (void)startListening;

+ (AFNetworkReachabilityStatus)networkStatus;

+ (BOOL)isNotReachableStatus:(AFNetworkReachabilityStatus)status;

@end
