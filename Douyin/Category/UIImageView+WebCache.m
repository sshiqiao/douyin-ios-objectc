//
//  UIImageView+WebCache.m
//  Douyin
//
//  Created by Qiao Shi on 2018/7/30.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

#import "UIImageView+WebCache.h"
#import "objc/runtime.h"
#import "WebPImage.h"

@implementation UIImageView (WebCache)

- (void)setImageWithURL:(NSURL *)imageURL {
    [self cancelOperation];
    __weak __typeof(self) wself = self;
    WebCombineOperation *operation = [[WebDownloader sharedDownloader] downloadWithURL:imageURL progressBlock:nil
                                                                        completedBlock:^(NSData *data, NSError *error, BOOL finished) {
                                                                            UIImage *image = [[UIImage alloc] initWithData:data];
                                                                            dispatch_main_sync_safe(^{
                                                                                wself.image = image;
                                                                            });
                                                                        } cancelBlock:nil];
    objc_setAssociatedObject(self, &loadOperationKey, operation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setImageWithURL:(NSURL *)imageURL completedBlock:(WebImageCompletedBlock)completedBlock {
    [self cancelOperation];
    WebCombineOperation *operation = [[WebDownloader sharedDownloader] downloadWithURL:imageURL progressBlock:nil
                                                                        completedBlock:^(NSData *data, NSError *error, BOOL finished) {
                                                                            UIImage *image = [[UIImage alloc] initWithData:data];
                                                                            dispatch_main_sync_safe(^{
                                                                                completedBlock(image, error);
                                                                            });
                                                                        } cancelBlock:nil];
    objc_setAssociatedObject(self, &loadOperationKey, operation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setImageWithURL:(NSURL *)imageURL progressBlock:(WebImageProgressBlock)progressBlock completedBlock:(WebImageCompletedBlock)completedBlock {
    [self cancelOperation];
    WebCombineOperation *operation = [[WebDownloader sharedDownloader] downloadWithURL:imageURL progressBlock:^(NSInteger receivedSize, NSInteger expectedSize, NSData *data) {
        NSString *percentStr = [NSString stringWithFormat:@"%.1fw",(CGFloat)receivedSize/(CGFloat)expectedSize];
        CGFloat percent = [percentStr floatValue];
        dispatch_main_sync_safe(^{
            progressBlock(percent);
        });
    } completedBlock:^(NSData *data, NSError *error, BOOL finished) {
        UIImage *image = [[UIImage alloc] initWithData:data];
        dispatch_main_sync_safe(^{
            completedBlock(image, error);
        });
    } cancelBlock:^{
        
    }];
    objc_setAssociatedObject(self, &loadOperationKey, operation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setWebPImageWithURL:(NSURL *)imageURL progressBlock:(WebImageProgressBlock)progressBlock completedBlock:(WebImageCompletedBlock)completedBlock {
    [self cancelOperation];
    WebCombineOperation *operation = [[WebDownloader sharedDownloader] downloadWithURL:imageURL progressBlock:^(NSInteger receivedSize, NSInteger expectedSize, NSData *data) {
        NSString *percentStr = [NSString stringWithFormat:@"%.1fw",(CGFloat)receivedSize/(CGFloat)expectedSize];
        CGFloat percent = [percentStr floatValue];
        dispatch_main_sync_safe(^{
            progressBlock(percent);
        });
    } completedBlock:^(NSData *data, NSError *error, BOOL finished) {
        WebPImage *image = nil;
        if (finished) {
            image = [[WebPImage alloc] initWithData:data];
        }
        dispatch_main_sync_safe(^{
            completedBlock(image, error);
        });
    } cancelBlock:^{
        
    }];
    objc_setAssociatedObject(self, &loadOperationKey, operation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)cancelOperation {
    WebCombineOperation *operation = objc_getAssociatedObject(self, &loadOperationKey);
    if(operation) {
        [operation cancel];
    }
}

@end
