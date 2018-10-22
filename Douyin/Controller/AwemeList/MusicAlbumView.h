//
//  MusicAlbumView.h
//  Douyin
//
//  Created by Qiao Shi on 2018/7/30.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Aweme;

@interface MusicAlbumView : UIView

@property (nonatomic, strong) UIImageView      *album;

- (void)startAnimation:(CGFloat)rate;
- (void)resetView;

@end
