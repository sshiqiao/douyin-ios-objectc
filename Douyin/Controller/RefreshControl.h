//
//  RefreshControl.h
//  Douyin
//
//  Created by Qiao Shi on 2018/7/30.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"

typedef void (^OnRefresh)(void);
@interface RefreshControl:UIControl
@property (nonatomic, strong) UIImageView       *indicatorView;
@property (nonatomic, strong) OnRefresh         onRefresh;
@property (nonatomic, assign) RefreshingType    refreshingType;

- (void)setOnRefresh:(OnRefresh)onRefresh;

- (void)startRefresh;

- (void)endRefresh;

- (void)loadAll;

@end
