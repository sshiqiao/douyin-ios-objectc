//
//  FavoriteView.m
//  Douyin
//
//  Created by Qiao Shi on 2018/7/30.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

#import "FavoriteView.h"

static const NSInteger kFavoriteViewLikeBeforeTag  = 0x01;
static const NSInteger kFavoriteViewLikeAfterTag   = 0x02;

@implementation FavoriteView

- (instancetype)init {
    return [self initWithFrame:CGRectMake(0, 0, 50, 45)];
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self) {
        _favoriteBefore = [[UIImageView alloc]initWithFrame:frame];
        _favoriteBefore.contentMode = UIViewContentModeCenter;
        _favoriteBefore.image = [UIImage imageNamed:@"icon_home_like_before"];
        _favoriteBefore.userInteractionEnabled = YES;
        _favoriteBefore.tag = kFavoriteViewLikeBeforeTag;
        [_favoriteBefore addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)]];
        [self addSubview:_favoriteBefore];
        
        _favoriteAfter = [[UIImageView alloc]initWithFrame:frame];
        _favoriteAfter.contentMode = UIViewContentModeCenter;
        _favoriteAfter.image = [UIImage imageNamed:@"icon_home_like_after"];
        _favoriteAfter.userInteractionEnabled = YES;
        _favoriteAfter.tag = kFavoriteViewLikeAfterTag;
        [_favoriteAfter setHidden:YES];
        [_favoriteAfter addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)]];
        [self addSubview:_favoriteAfter];
    }
    return self;
}

- (void)handleGesture:(UITapGestureRecognizer *)sender {
    switch (sender.view.tag) {
        case kFavoriteViewLikeBeforeTag: {
            [self startLikeAnim:YES];
            break;
        }
        case kFavoriteViewLikeAfterTag: {
            [self startLikeAnim:NO];
            break;
        }
    }
}

-(void)startLikeAnim:(BOOL)isLike {
    
    _favoriteBefore.userInteractionEnabled = NO;
    _favoriteAfter.userInteractionEnabled = NO;
    if(isLike) {
        CGFloat length = 30;
        CGFloat duration = 0.5;
        for(int i=0;i<6;i++) {
            CAShapeLayer *layer = [[CAShapeLayer alloc]init];
            layer.position = _favoriteBefore.center;
            layer.fillColor = ColorThemeRed.CGColor;
            
            UIBezierPath *startPath = [UIBezierPath bezierPath];
            [startPath moveToPoint:CGPointMake(-2, -length)];
            [startPath addLineToPoint:CGPointMake(2, -length)];
            [startPath addLineToPoint:CGPointMake(0, 0)];
            
            UIBezierPath *endPath = [UIBezierPath bezierPath];
            [endPath moveToPoint:CGPointMake(-2, -length)];
            [endPath addLineToPoint:CGPointMake(2, -length)];
            [endPath addLineToPoint:CGPointMake(0, -length)];

            layer.path = startPath.CGPath;
            layer.transform = CATransform3DMakeRotation(M_PI / 3.0f * i, 0.0, 0.0, 1.0);
            [self.layer addSublayer:layer];
            
            CAAnimationGroup *group = [[CAAnimationGroup alloc] init];
            group.removedOnCompletion = NO;
            group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            group.fillMode = kCAFillModeForwards;
            group.duration = duration;
            
            CABasicAnimation *scaleAnim = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
            scaleAnim.fromValue = @(0.0);
            scaleAnim.toValue = @(1.0);
            scaleAnim.duration = duration * 0.2f;
            
            CABasicAnimation *pathAnim = [CABasicAnimation animationWithKeyPath:@"path"];
            pathAnim.fromValue = (__bridge id)layer.path;
            pathAnim.toValue = (__bridge id)endPath.CGPath;
            pathAnim.beginTime = duration * 0.2f;
            pathAnim.duration = duration * 0.8f;
            
            [group setAnimations:@[scaleAnim, pathAnim]];
            [layer addAnimation:group forKey:nil];
        }
        [_favoriteAfter setHidden:NO];
        _favoriteAfter.alpha = 0.0f;
        _favoriteAfter.transform = CGAffineTransformScale(CGAffineTransformMakeRotation(-M_PI/3*2), 0.5f, 0.5f);
        [UIView animateWithDuration:0.4f
                              delay:0.2f
             usingSpringWithDamping:0.6f
              initialSpringVelocity:0.8f
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.favoriteBefore.alpha = 0.0f;
                             self.favoriteAfter.alpha = 1.0f;
                             self.favoriteAfter.transform = CGAffineTransformScale(CGAffineTransformMakeRotation(0), 1.0f, 1.0f);
                         }
                         completion:^(BOOL finished) {
                             self.favoriteBefore.alpha = 1.0f;
                             self.favoriteBefore.userInteractionEnabled = YES;
                             self.favoriteAfter.userInteractionEnabled = YES;
                         }];
    }else {
        _favoriteAfter.alpha = 1.0f;
        _favoriteAfter.transform = CGAffineTransformScale(CGAffineTransformMakeRotation(0), 1.0f, 1.0f);
        [UIView animateWithDuration:0.35f
                              delay:0.0f
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.favoriteAfter.transform = CGAffineTransformScale(CGAffineTransformMakeRotation(-M_PI_4), 0.1f, 0.1f);
                         }
                         completion:^(BOOL finished) {
                             [self.favoriteAfter setHidden:YES];
                             self.favoriteBefore.userInteractionEnabled = YES;
                             self.favoriteAfter.userInteractionEnabled = YES;
                         }];
    }
}

- (void)resetView {
    [_favoriteBefore setHidden:NO];
    [_favoriteAfter setHidden:YES];
    [self.layer removeAllAnimations];
}

@end
