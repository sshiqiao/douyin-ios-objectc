//
//  SharePopView.m
//  Douyin
//
//  Created by Qiao Shi on 2018/7/30.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

#import "SharePopView.h"

@implementation SharePopView

- (instancetype)init {
    self = [super init];
    if (self) {
        NSArray *topIconsName = @[
                                 @"icon_profile_share_wxTimeline",
                                 @"icon_profile_share_wechat",
                                 @"icon_profile_share_qqZone",
                                 @"icon_profile_share_qq",
                                 @"icon_profile_share_weibo",
                                 @"iconHomeAllshareXitong"
                                 ];
        NSArray *topTexts = @[
                             @"朋友圈",
                             @"微信好友",
                             @"QQ空间",
                             @"QQ好友",
                             @"微博",
                             @"更多分享"
                             ];
        NSArray *bottomIconsName = @[
                                    @"icon_home_allshare_report",
                                    @"icon_home_allshare_download",
                                    @"icon_home_allshare_copylink",
                                    @"icon_home_all_share_dislike"
                                    ];
        NSArray *bottomTexts = @[
                                @"举报",
                                @"保存至相册",
                                @"复制链接",
                                @"不感兴趣"
                                ];
        
        self.frame = ScreenFrame;
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGuesture:)]];
        _container = [[UIView alloc] initWithFrame:CGRectMake(0, ScreenHeight, ScreenWidth, 280 + SafeAreaBottomHeight)];
        _container.backgroundColor = ColorBlackAlpha60;
        [self addSubview:_container];
        
        
        UIBezierPath* rounded = [UIBezierPath bezierPathWithRoundedRect:_container.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(10.0f, 10.0f)];
        CAShapeLayer* shape = [[CAShapeLayer alloc] init];
        [shape setPath:rounded.CGPath];
        _container.layer.mask = shape;
        
        UIBlurEffect *blurEffect =[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc]initWithEffect:blurEffect];
        visualEffectView.frame = self.bounds;
        visualEffectView.alpha = 1.0f;
        [_container addSubview:visualEffectView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 35)];
        label.textAlignment = NSTextAlignmentCenter;
        label.numberOfLines = 0;
        label.text = @"分享到";
        label.textColor = ColorGray;
        label.font = MediumFont;
        [_container addSubview:label];
        
        
        CGFloat itemWidth = 68;
        
        UIScrollView *topScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 35, ScreenWidth, 90)];
        topScrollView.contentSize = CGSizeMake(itemWidth * topIconsName.count, 80);
        topScrollView.showsHorizontalScrollIndicator = NO;
        topScrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 30);
        [_container addSubview:topScrollView];
        
        for (NSInteger i = 0; i < topIconsName.count; i++) {
            ShareItem *item = [[ShareItem alloc] initWithFrame:CGRectMake(20 + itemWidth*i, 0, 48, 90)];
            item.icon.image = [UIImage imageNamed:topIconsName[i]];
            item.label.text = topTexts[i];
            item.tag = i;
            [item addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onShareItemTap:)]];
            [item startAnimation:i*0.03f];
            [topScrollView addSubview:item];
        }
        
        UIView *splitLine = [[UIView alloc] initWithFrame:CGRectMake(0, 130, ScreenWidth, 0.5f)];
        splitLine.backgroundColor = ColorWhiteAlpha10;
        [_container addSubview:splitLine];
        
        UIScrollView *bottomScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 135, ScreenWidth, 90)];
        bottomScrollView.contentSize = CGSizeMake(itemWidth * bottomIconsName.count, 80);
        bottomScrollView.showsHorizontalScrollIndicator = NO;
        bottomScrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 30);
        [_container addSubview:bottomScrollView];
        
        for (NSInteger i = 0; i < bottomIconsName.count; i++) {
            ShareItem *item = [[ShareItem alloc] initWithFrame:CGRectMake(20 + itemWidth*i, 0, 48, 90)];
            item.icon.image = [UIImage imageNamed:bottomIconsName[i]];
            item.label.text = bottomTexts[i];
            item.tag = i;
            [item addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onActionItemTap:)]];
            [item startAnimation:i*0.03f];
            [bottomScrollView addSubview:item];
        }
        
        
        _cancel = [[UIButton alloc] initWithFrame:CGRectMake(0, 230, ScreenWidth, 50 + SafeAreaBottomHeight)];
        [_cancel setTitleEdgeInsets:UIEdgeInsetsMake(-SafeAreaBottomHeight, 0, 0, 0)];
        
        [_cancel setTitle:@"取消" forState:UIControlStateNormal];
        [_cancel setTitleColor:ColorWhite forState:UIControlStateNormal];
        _cancel.titleLabel.font = BigFont;

        _cancel.backgroundColor = ColorGrayLight;
        [_container addSubview:_cancel];
        
        UIBezierPath* rounded2 = [UIBezierPath bezierPathWithRoundedRect:_cancel.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(10.0f, 10.0f)];
        CAShapeLayer* shape2 = [[CAShapeLayer alloc] init];
        [shape2 setPath:rounded2.CGPath];
        _cancel.layer.mask = shape2;
        [_cancel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGuesture:)]];
    }
    return self;
}

- (void)onShareItemTap:(UITapGestureRecognizer *)sender {
    switch (sender.view.tag) {
        case 0:
            break;
        default:
            break;
    }
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/sshiqiao/douyin-ios-objectc"]];
    [self dismiss];
}
- (void)onActionItemTap:(UITapGestureRecognizer *)sender {
    switch (sender.view.tag) {
        case 0:
            break;
        default:
            break;
    }
    [self dismiss];
}

- (void)handleGuesture:(UITapGestureRecognizer *)sender {
    CGPoint point = [sender locationInView:_container];
    if(![_container.layer containsPoint:point]) {
        [self dismiss];
        return;
    }
    point = [sender locationInView:_cancel];
    if([_cancel.layer containsPoint:point]) {
        [self dismiss];
    }
}

- (void)show {
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    [window addSubview:self];
    [UIView animateWithDuration:0.15f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         CGRect frame = self.container.frame;
                         frame.origin.y = frame.origin.y - frame.size.height;
                         self.container.frame = frame;
                     }
                     completion:^(BOOL finished) {
                     }];
}

- (void)dismiss {
    [UIView animateWithDuration:0.15f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         CGRect frame = self.container.frame;
                         frame.origin.y = frame.origin.y + frame.size.height;
                         self.container.frame = frame;
                     }
                     completion:^(BOOL finished) {
                         [self removeFromSuperview];
                     }];
}

@end



#pragma Item view

@implementation ShareItem
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _icon = [[UIImageView alloc] init];
        _icon.image = [UIImage imageNamed:@"iconHomeAllshareCopylink"];
        _icon.contentMode = UIViewContentModeScaleToFill;
        _icon.userInteractionEnabled = YES;
        [self addSubview:_icon];
        
        _label = [[UILabel alloc] init];
        _label.text = @"TEXT";
        _label.textColor = ColorWhiteAlpha60;
        _label.font = MediumFont;
        _label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_label];
    }
    return self;
}
-(void)startAnimation:(NSTimeInterval)delayTime {
    CGRect originalFrame = self.frame;
    self.frame = CGRectMake(CGRectGetMinX(originalFrame), 35, originalFrame.size.width, originalFrame.size.height);
    [UIView animateWithDuration:0.9f
                          delay:delayTime
         usingSpringWithDamping:0.5f
          initialSpringVelocity:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.frame = originalFrame;
                     }
                     completion:^(BOOL finished) {
                     }];
}

-(void)layoutSubviews {
    [super layoutSubviews];
    [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(48);
        make.centerX.equalTo(self);
        make.top.equalTo(self).offset(10);
    }];
    [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self.icon.mas_bottom).offset(10);
    }];
}

@end
