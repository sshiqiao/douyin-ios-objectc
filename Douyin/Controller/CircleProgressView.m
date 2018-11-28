//
//  CircleProgressView.m
//  Douyin
//
//  Created by Qiao Shi on 2018/7/30.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

#import "CircleProgressView.h"

@interface CircleProgressView ()

@property (nonatomic, strong) CAShapeLayer   *progressLayer;
@property (nonatomic, strong) UIImageView    *tipIcon;

@end

@implementation CircleProgressView

- (instancetype)init {
    return [self initWithFrame:CGRectMake(0, 0, 50, 50)];
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self) {
        self.layer.backgroundColor = ColorBlackAlpha40.CGColor;
        self.layer.borderColor = ColorWhiteAlpha80.CGColor;
        self.layer.borderWidth = 1.0f;
        
        _progressLayer = [CAShapeLayer new];
        _progressLayer.fillColor = ColorWhiteAlpha80.CGColor;
        [self.layer addSublayer:_progressLayer];
        
        _tipIcon = [UIImageView new];
        _tipIcon.image = [UIImage imageNamed:@"icon_warn_white"];
        _tipIcon.contentMode = UIViewContentModeCenter;
        [self setTipHidden:YES];
        [self addSubview:_tipIcon];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.layer.cornerRadius = self.bounds.size.width/2;
    self.tipIcon.frame = self.bounds;
}

- (UIBezierPath *)bezierPath:(CGFloat)progress {
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithArcCenter:center radius:self.frame.size.width/2 - 2 startAngle:-M_PI/2 endAngle:progress * (M_PI * 2) - (M_PI / 2) clockwise:YES];
    [bezierPath addLineToPoint:center];
    [bezierPath closePath];
    return bezierPath;
}

- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    _progressLayer.path = [self bezierPath:progress].CGPath;
}

- (void)setTipHidden:(BOOL)isTipHidden {
    _isTipHidden = isTipHidden;
    [_tipIcon setHidden:isTipHidden];
}

- (void)resetView {
    [self setProgress:0];
    [self setTipHidden:YES];
}

@end
