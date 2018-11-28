//
//  WebPImageView.m
//  Douyin
//
//  Created by Qiao Shi on 2018/7/30.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//
#import "WebPImageView.h"
#import "WebPImage.h"
#import "WebPQueueManager.h"

//解码完后的回调用的block
typedef void(^WebPCompletedBlock)(WebPFrame *frame);

//专门用于解码WebP画面的NSOperation子类
@interface WebPImageOperation : NSOperation

-(instancetype)initWithWebImage:(WebPImage *)image completedBlock:(WebPCompletedBlock)completedBlock;

@end


@interface WebPImageOperation()

@property (atomic, copy) WebPCompletedBlock completedBlock;   //解码完后的回调用的block
@property (atomic, copy) WebPImage          *image;           //WebImageView用于显示的WebPImage
@property (assign, nonatomic) BOOL          executing;        //判断NSOperation是否执行
@property (assign, nonatomic) BOOL          finished;         //判断NSOperation是否结束

@end


@implementation WebPImageOperation

@synthesize executing  = _executing;      //指定executing别名为_executing
@synthesize finished   = _finished;       //指定finished别名为_finished

-(instancetype)initWithWebImage:(WebPImage *)image completedBlock:(WebPCompletedBlock)completedBlock {
    if ((self = [super init])) {
        _image = [image copy];
        _completedBlock = [completedBlock copy];
    }
    return self;
}

- (void)start {
    [self willChangeValueForKey:@"isExecuting"];
    _executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
    
    //判断任务执行前是否取消了任务
    if(self.isCancelled) {
        [self done];
        return;
    }
    //解码WebP当前索引对应的帧画面
    WebPFrame *frame = [_image decodeCurFrame];
    
    //由于上一步是耗时步骤，在真机上测试的时间为0.05-0.1s之间，所以在结束任务前再判断一次任务执行前是否取消了任务
    if(self.isCancelled) {
        [self done];
        return;
    }
    //解码结束后回调结果
    if(_completedBlock) {
        _completedBlock(frame);
        [self done];
    }
}

-(BOOL)isExecuting {
    return _executing;
}

- (BOOL)isFinished {
    return _finished;
}

- (BOOL)isAsynchronous {
    return YES;
}

//取消NSOperation任务
-(void)cancel {
    @synchronized(self) {
        [self done];
    }
}

//更新NSOperation状态
- (void)done {
    [super cancel];
    if(_executing) {
        [self willChangeValueForKey:@"isFinished"];
        [self willChangeValueForKey:@"isExecuting"];
        _finished = YES;
        _executing = NO;
        [self didChangeValueForKey:@"isFinished"];
        [self didChangeValueForKey:@"isExecuting"];
    }
}

@end


@interface WebPImageView ()

@property (nonatomic, strong) CADisplayLink      *displayLink;        //CADisplayLink用于更新画面
@property (nonatomic, strong) NSOperationQueue   *requestQueue;       //用于解码剩余图片的NSOperationQueue
@property (nonatomic, strong) NSOperationQueue   *firstFrameQueue;    //用于专门解码WebP第一帧画面的NSOperationQueue
@property (nonatomic, strong) WebPImage          *webPImage;          //WebPImageView控件对应的WebPImage数据
@property (nonatomic, assign) NSTimeInterval     time;                //用于记录每帧时间间隔
@property (nonatomic, assign) NSInteger          operationCount;      //当前添加进队列的NSOperation数量
@end

@implementation WebPImageView

- (instancetype)init {
    self = [self initWithFrame:CGRectZero];
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        self.backgroundColor = [UIColor clearColor];
        
        //CADisplayLink类似NSTimer，在指定时间内对指定方法进调用，但是相对NSTimer而言更稳定，不会因为处理其他事件导致延误执行方法，默认情况下每1/60s调用一次指定方法
        //设置CADisplayLink的RunLoop模式为NSRunLoopCommonModes，指定调用方法为startAnimation:，并停止循环调用
        __weak __typeof(self) wself = self;
        _displayLink = [CADisplayLink displayLinkWithExecuteBlock:^(CADisplayLink *displayLink) {
            __strong __typeof(self) sself = wself;
            [sself startAnimation:displayLink];
        }];
        [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        _displayLink.paused = YES;
        
        //初始化用于解码剩余图片的NSOperationQueue，最大并发数设置为1，表示窜行处理每个解码任务，这样可以保证每帧解码顺序正确，最后将优先级设置为最低，以此来避免与进行网络请求的线程发生资源争抢
        _requestQueue = [[NSOperationQueue alloc] init];
        _requestQueue.maxConcurrentOperationCount = 1;
        _requestQueue.qualityOfService = NSQualityOfServiceUtility;
        
        //初始化用于专门解码WebP第一帧画面的NSOperationQueue，将优先级设置为最高，以此来快速解码第一帧图片
        _firstFrameQueue = [[NSOperationQueue alloc] init];
        _firstFrameQueue.maxConcurrentOperationCount = 1;
        _firstFrameQueue.qualityOfService = NSQualityOfServiceUserInteractive;
        
        _time = 0;             //初始化记录每帧时间间隔
        _operationCount = 0;   //初始化添加进队列的NSOperation数量
        
    }
    return self;
}

//重写initWithImage方法
- (instancetype)initWithImage:(UIImage *)image {
    CGRect frame = (CGRect) {CGPointZero, image.size };
    self = [self initWithFrame:frame];
    self.image = image;
    return self;
}

//重写setImage方法
- (void)setImage:(UIImage *)image {
    [super setImage:image];
    
    //避免WebPImageView控件在UICollectionView或UITableView中复用时队列任务错乱，先取消当前队列正在执行的任务以及循环调用方法
    _displayLink.paused = YES;
    [_firstFrameQueue cancelAllOperations];
    [[WebPQueueManager shareWebPQueueManager] cancelQueue:_requestQueue];
    
    //初始化数据
    _webPImage = (WebPImage *)image;
    _time = 0;
    _operationCount = 0;
    _displayLink.paused = NO;
    
    //开始解码WebP格式动图
    [self decodeFrames];
}

//解码WebP格式动图
- (void)decodeFrames {
    __weak typeof (self) wself = self;
    //在_firstFrameQueue中添加解码第一帧的任务
    _operationCount++;
    WebPImageOperation *operation = [[WebPImageOperation alloc] initWithWebImage:_webPImage completedBlock:^(WebPFrame *frame) {
        dispatch_async(dispatch_get_main_queue(), ^{
            wself.layer.contents = (__bridge id _Nullable)(frame.image.CGImage);
        });
    }];
    [_firstFrameQueue addOperation:operation];
    
    //在_requestQueue中添加解码剩余帧画面的任务
    while (_operationCount++ < _webPImage.frameCount) {
        WebPImageOperation *operation = [[WebPImageOperation alloc] initWithWebImage:_webPImage completedBlock:^(WebPFrame *frame) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [wself.layer setNeedsDisplay];
            });
        }];
        [_requestQueue addOperation:operation];
    }
    [[WebPQueueManager shareWebPQueueManager] addQueue:_requestQueue];
}

//CADisplayLink指定回调的方法
- (void)startAnimation:(CADisplayLink *)link {
    //判断是否所有帧都解码完毕
    if([_webPImage isAllFrameDecoded]) {
        //调用setNeedsDisplay方法更新画面
        [self.layer setNeedsDisplay];
    }
}

//重写setNeedsDisplay方法
- (void)displayLayer:(CALayer *)layer {
    //当间隔时间为0时表示当前画面需要更新
    if(_time == 0) {
        //获取当前帧所对应的UIImage然后更新WebPImage当前显示画面索引
        if (_webPImage && _webPImage.curDisplayFrame) {
            self.layer.contents = (__bridge id)_webPImage.curDisplayFrame.image.CGImage;
            [_webPImage incrementCurDisplayIndex];
        }
    }
    //递增用于记录每帧间隔时长的_time
    _time += _displayLink.duration;
    //当时间大于等于当前帧时长时，表示用于记录每帧间隔时长的_time需重制为0
    if(_time >= _webPImage.curDisplayFrameDuration) {
        _time = 0;
    }
}

@end
