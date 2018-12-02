//
//  NetworkHelper.m
//  Douyin
//
//  Created by Qiao Shi on 2018/7/30.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

#import "NetworkHelper.h"

NSString *const NetworkStatesChangeNotification = @"NetworkStatesChangeNotification";

NSString *const NetworkDomain = @"com.start.douyin";

//请求地址
NSString *const BaseUrl = @"http://116.62.9.17:8080/douyin/";

//创建访客用户接口
NSString *const CreateVisitorPath = @"visitor/create";


//根据用户id获取用户信息
NSString *const FindUserByUidPath = @"user";


//获取用户发布的短视频列表数据
NSString *const FindAwemePostByPagePath = @"aweme/post";
//获取用户喜欢的短视频列表数据
NSString *const FindAwemeFavoriteByPagePath = @"aweme/favorite";


//发送文本类型群聊消息
NSString *const PostGroupChatTextPath = @"groupchat/text";
//发送单张图片类型群聊消息
NSString *const PostGroupChatImagePath = @"groupchat/image";
//发送多张图片类型群聊消息
NSString *const PostGroupChatImagesPath = @"groupchat/images";
//根据id获取指定图片
NSString *const FindImageByIdPath = @"groupchat/image";
//获取群聊列表数据
NSString *const FindGroupChatByPagePath = @"groupchat/list";
//根据id删除指定群聊消息
NSString *const DeleteGroupChatByIdPath = @"groupchat/delete";


//根据视频id发送评论
NSString *const PostComentPath = @"comment/post";
//根据id删除评论
NSString *const DeleteComentByIdPath = @"comment/delete";
//获取评论列表
NSString *const FindComentByPagePath = @"comment/list";


@implementation NetworkHelper

+(AFHTTPSessionManager *)sharedManager{
    static dispatch_once_t once;
    static AFHTTPSessionManager *manager;
    dispatch_once(&once, ^{
        manager = [AFHTTPSessionManager manager];
        manager.requestSerializer.timeoutInterval = 15.0f;
        
    });
    return manager;
}

//porcess response data
+(void)processResponseData:(id)responseObject success:(HttpSuccess)success failure:(HttpFailure)failure {
    NSInteger code = -1;
    NSString *message = @"response data error";
    if([responseObject isKindOfClass:NSDictionary.class]) {
        NSDictionary *dic = (NSDictionary *)responseObject;
        code = [(NSNumber *)[dic objectForKey:@"code"] integerValue];
        message = (NSString *)[dic objectForKey:@"message"];
    }
    if(code == 0){
        success(responseObject);
    }else{
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:message                                                                     forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:NetworkDomain code:HttpResquestFailed userInfo:userInfo];
        failure(error);
    }
}

+(NSURLSessionDataTask *)getWithUrlPath:(NSString *)urlPath request:(BaseRequest *)request success:(HttpSuccess)success failure:(HttpFailure)failure {
    NSDictionary *parameters = [request toDictionary];
    return [[NetworkHelper sharedManager] GET:[BaseUrl stringByAppendingString:urlPath] parameters:parameters progress:^(NSProgress *downloadProgress) {
    } success:^(NSURLSessionDataTask *task, id responseObject) {
        [NetworkHelper processResponseData:responseObject success:success failure:failure];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        AFNetworkReachabilityStatus status = [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus;
        //未连接到网络
        if(status == AFNetworkReachabilityStatusNotReachable) {
            [UIWindow showTips:@"未连接到网络"];
            failure(error);
            return ;
        }
        //当服务器无法响应时，使用本地json数据
        NSString *path = task.originalRequest.URL.path;
        if ([path containsString:FindUserByUidPath]) {
            success([NSString readJson2DicWithFileName:@"user"]);
        }else if ([path containsString:FindAwemePostByPagePath]) {
            success([NSString readJson2DicWithFileName:@"awemes"]);
        }else if ([path containsString:FindAwemeFavoriteByPagePath]) {
            success([NSString readJson2DicWithFileName:@"favorites"]);
        }else if ([path containsString:FindComentByPagePath]) {
            success([NSString readJson2DicWithFileName:@"comments"]);
        }else if ([path containsString:FindGroupChatByPagePath]) {
            success([NSString readJson2DicWithFileName:@"groupchats"]);
        }else {
            failure(error);
        }
    }];
}

+(NSURLSessionDataTask *)deleteWithUrlPath:(NSString *)urlPath request:(BaseRequest *)request success:(HttpSuccess)success failure:(HttpFailure)failure {
    NSDictionary *parameters = [request toDictionary];
    return [[NetworkHelper sharedManager] DELETE:[BaseUrl stringByAppendingString:urlPath] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        [NetworkHelper processResponseData:responseObject success:success failure:failure];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failure(error);
    }];
}

+(NSURLSessionDataTask *)postWithUrlPath:(NSString *)urlPath request:(BaseRequest *)request success:(HttpSuccess)success failure:(HttpFailure)failure {
    NSDictionary *parameters = [request toDictionary];
    return [[NetworkHelper sharedManager] POST:[BaseUrl stringByAppendingString:urlPath] parameters:parameters progress:^(NSProgress *uploadProgress) {
    } success:^(NSURLSessionDataTask * task, id responseObject) {
        [NetworkHelper processResponseData:responseObject success:success failure:failure];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failure(error);
    }];
}

+(NSURLSessionDataTask *)uploadWithUrlPath:(NSString *)urlPath data:(NSData *)data request:(BaseRequest *)request progress:(UploadProgress)progress success:(HttpSuccess)success failure:(HttpFailure)failure {
    NSDictionary *parameters = [request toDictionary];
    return [[NetworkHelper sharedManager] POST:[BaseUrl stringByAppendingString:urlPath] parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:data name:@"file" fileName:@"file" mimeType:@"multipart/form-data"];
    } progress:^(NSProgress *uploadProgress) {
        dispatch_main_sync_safe(^{
            progress(uploadProgress.fractionCompleted);
        });
    } success:^(NSURLSessionDataTask *task, id responseObject) {
        [NetworkHelper processResponseData:responseObject success:success failure:failure];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failure(error);
    }];
}

+(NSURLSessionDataTask *)uploadWithUrlPath:(NSString *)urlPath dataArray:(NSArray<NSData *> *)dataArray request:(BaseRequest *)request progress:(UploadProgress)progress success:(HttpSuccess)success failure:(HttpFailure)failure {
    NSDictionary *parameters = [request toDictionary];
    return [[NetworkHelper sharedManager] POST:[BaseUrl stringByAppendingString:urlPath] parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        for(NSData *data in dataArray) {
            NSString *fileName = [NSString  stringWithFormat:@"%@.jpg", [NSString currentTime]];
            [formData appendPartWithFileData:data name:@"files" fileName:fileName mimeType:@"multipart/form-data"];
        }
    } progress:^(NSProgress *uploadProgress) {
        progress(uploadProgress.fractionCompleted);
    } success:^(NSURLSessionDataTask *task, id responseObject) {
        [NetworkHelper processResponseData:responseObject success:success failure:failure];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failure(error);
    }];
}

//Reachability
+(AFNetworkReachabilityManager *)shareReachabilityManager {
    static dispatch_once_t once;
    static AFNetworkReachabilityManager *manager;
    dispatch_once(&once, ^{
        manager = [AFNetworkReachabilityManager manager];
    });
    return manager;
}

+ (void)startListening {
    [[NetworkHelper shareReachabilityManager] startMonitoring];
    [[NetworkHelper shareReachabilityManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NetworkStatesChangeNotification object:nil];
        if(![NetworkHelper isNotReachableStatus:status]) {
            [NetworkHelper registerUserInfo];
        }
    }];
}

+ (AFNetworkReachabilityStatus)networkStatus {
    return [NetworkHelper shareReachabilityManager].networkReachabilityStatus;
}

+ (BOOL)isWifiStatus {
    return [NetworkHelper shareReachabilityManager].networkReachabilityStatus == AFNetworkReachabilityStatusReachableViaWiFi;
}

+ (BOOL)isNotReachableStatus:(AFNetworkReachabilityStatus)status {
    return status == AFNetworkReachabilityStatusNotReachable;
}

//visitor
+ (void)registerUserInfo {
    VisitorRequest *request = [VisitorRequest new];
    request.udid = UDID;
    [NetworkHelper postWithUrlPath:CreateVisitorPath request:request success:^(id data) {
        VisitorResponse *response = [[VisitorResponse alloc] initWithDictionary:data error:nil];
        writeVisitor(response.data);
    } failure:^(NSError *error) {
        NSLog(@"Register visitor failed.");
    }];
}

@end
