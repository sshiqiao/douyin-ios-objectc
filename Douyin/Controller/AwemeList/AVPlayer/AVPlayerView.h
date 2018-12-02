//
//  AVPlayerView.h
//  Douyin
//
//  Created by Qiao Shi on 2018/7/30.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

//自定义Delegate，用于进度、播放状态更新回调
@protocol AVPlayerUpdateDelegate

@required
//播放进度更新回调方法
-(void)onProgressUpdate:(CGFloat)current total:(CGFloat)total;

//播放状态更新回调方法
-(void)onPlayItemStatusUpdate:(AVPlayerItemStatus)status;

@end



//封装了AVPlayerLayer的自定义View
@interface AVPlayerView : UIView

//播放进度、状态更新代理
@property(nonatomic, weak) id<AVPlayerUpdateDelegate> delegate;

//设置播放路径
- (void)setPlayerWithUrl:(NSString *)url;

//取消播放
- (void)cancelLoading;

//开始视频资源下载任务
- (void)startDownloadTask:(NSURL *)URL isBackground:(BOOL)isBackground;

//更新AVPlayer状态，当前播放则暂停，当前暂停则播放
- (void)updatePlayerState;

//播放
- (void)play;

//暂停
- (void)pause;

//重新播放
- (void)replay;

//播放速度
- (CGFloat)rate;

//重新请求
- (void)retry;


@end
