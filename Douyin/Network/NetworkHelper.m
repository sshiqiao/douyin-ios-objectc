//
//  NetworkHelper.m
//  Douyin
//
//  Created by Qiao Shi on 2018/7/30.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

#import "NetworkHelper.h"
@implementation NetworkHelper

+(AFHTTPSessionManager *)sharedManager{
    static dispatch_once_t once;
    static AFHTTPSessionManager *manager;
    dispatch_once(&once, ^{
        manager = [AFHTTPSessionManager manager];
        manager.requestSerializer.timeoutInterval = 60.0f;
        
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
        if ([path containsString:FIND_USER_BY_UID_URL]) {
            success([NSString readJson2DicWithFileName:@"user"]);
        }else if ([path containsString:FIND_AWEME_POST_BY_PAGE_URL]) {
            success([NSString readJson2DicWithFileName:@"awemes"]);
        }else if ([path containsString:FIND_AWEME_FAVORITE_BY_PAGE_URL]) {
            success([NSString readJson2DicWithFileName:@"favorites"]);
        }else if ([path containsString:FIND_COMMENT_BY_PAGE_URL]) {
            success([NSString readJson2DicWithFileName:@"comments"]);
        }else if ([path containsString:FIND_GROUP_CHAT_BY_PAGE_URL]) {
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

@end
