//
//  WebPQueueManager.m
//  Douyin
//
//  Created by Qiao Shi on 2018/7/30.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

#import "WebPQueueManager.h"
@interface WebPQueueManager()
@property (nonatomic, assign) NSInteger                            maxQueueCount;       //最大执行中的NSOperationQueue数量
@property (nonatomic, strong) NSMutableArray<NSOperationQueue *>   *requestQueueArray;  //用于存储NSOperationQueue的数组
@end

@implementation WebPQueueManager
//WebPQueueManager单例
+(WebPQueueManager *)shareWebPQueueManager {
    static dispatch_once_t once;
    static WebPQueueManager *manager;
    dispatch_once(&once, ^{
        manager = [WebPQueueManager new];
    });
    return manager;
}
- (instancetype)init {
    self = [super init];
    if (self) {
        _requestQueueArray = [NSMutableArray array];
        _maxQueueCount = 3;
    }
    return self;
}

//添加NSOperationQueue队列
- (void)addQueue:(NSOperationQueue *)queue {
    @synchronized(_requestQueueArray) {
        if([_requestQueueArray containsObject:queue]) {
            NSInteger index = [_requestQueueArray indexOfObject:queue];
            [_requestQueueArray replaceObjectAtIndex:index withObject:queue];
        }else {
            [_requestQueueArray addObject:queue];
            [queue addObserver:self forKeyPath:@"operations" options:NSKeyValueObservingOptionNew context:nil];
        }
        [self processQueues];
    }
}

//取消指定NSOperationQueue队列
-(void)cancelQueue:(NSOperationQueue *)queue {
    @synchronized(_requestQueueArray) {
        if([_requestQueueArray containsObject:queue]) {
            [queue cancelAllOperations];
        }
    }
}

//挂起NSOperationQueue队列
-(void)suspendQueue:(NSOperationQueue *)queue suspended:(BOOL)suspended {
    @synchronized(_requestQueueArray) {
        if([_requestQueueArray containsObject:queue]) {
            [queue setSuspended:suspended];
        }
    }
}

//对当前并发的所有队列进行处理，保证正在执行的队列数量不超过最大执行的队列数
-(void)processQueues {
    [_requestQueueArray enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSOperationQueue *queue, NSUInteger idx, BOOL *stop) {
        if(self.requestQueueArray.count <= self.maxQueueCount) {
            [self suspendQueue:queue suspended:NO];
        }else {
            //判断队列是否在中间，是的话就唤醒，在两边的话则刮起，保证队列从中间开始执行，依次向两端扩散执行
            if((self.requestQueueArray.count/2 - self.maxQueueCount/2) <= idx && idx <= (self.requestQueueArray.count/2 + self.maxQueueCount/2)) {
                [self suspendQueue:queue suspended:NO];
            }else {
                [self suspendQueue:queue suspended:YES];
            }
        }
    }];
}

//移除任务已经完成的队列，并更新当前正在执行的队列
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"operations"]) {
        NSOperationQueue *queue = object;
        if ([queue.operations count] == 0) {
            @synchronized(_requestQueueArray) {
                [_requestQueueArray removeObject:queue];
            }
            [self processQueues];
        }
    }else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)dealloc {
    for (NSOperationQueue *queue in _requestQueueArray) {
        [queue removeObserver:self forKeyPath:@"operations"];
    }
}
@end
