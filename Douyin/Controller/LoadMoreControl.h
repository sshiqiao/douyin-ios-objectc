//
//  LoadMoreControl.h
//  Douyin
//
//  Created by Qiao Shi on 2018/7/30.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import <objc/message.h>
typedef void (^OnLoad)(void);

@interface LoadMoreControl:UIControl
@property (nonatomic, assign) LoadingType                loadingType;
@property (nonatomic, strong) UIImageView                *indicatorView;
@property (nonatomic, strong) UILabel                    *label;
@property (nonatomic, strong) OnLoad                     onLoad;

-(instancetype)initWithFrame:(CGRect)frame surplusCount:(NSInteger)surplusCount;

- (void)setLoadingType:(LoadingType)loadingType;

- (void)setOnLoad:(OnLoad)onLoad;

- (void)reset;

- (void)startLoading;

- (void)endLoading;

- (void)loadingFailed;

- (void)loadingAll;
@end
