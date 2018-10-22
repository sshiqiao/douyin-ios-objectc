//
//  AwemeCollectionCell.m
//  Douyin
//
//  Created by Qiao Shi on 2018/7/30.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

#import "AwemeCollectionCell.h"
#import "Constants.h"
#import "Masonry.h"
#import "WebPImageView.h"
#import "Aweme.h"

@implementation AwemeCollectionCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self){
        self.clipsToBounds = YES;
        _imageView = [[WebPImageView alloc] init];
        _imageView.backgroundColor = ColorThemeGray;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:_imageView];
        
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.colors = @[(__bridge id)ColorClear.CGColor, (__bridge id)ColorBlackAlpha20.CGColor, (__bridge id)ColorBlackAlpha60.CGColor];
        gradientLayer.locations = @[@0.3, @0.6, @1.0];
        gradientLayer.startPoint = CGPointMake(0.0f, 0.0f);
        gradientLayer.endPoint = CGPointMake(0.0f, 1.0f);
        gradientLayer.frame = CGRectMake(0, self.frame.size.height - 100, self.frame.size.width, 100);
        [_imageView.layer addSublayer:gradientLayer];
        
        _favoriteNum = [[UIButton alloc] init];
        [_favoriteNum setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [_favoriteNum setTitleEdgeInsets:UIEdgeInsetsMake(0, 2, 0, 0)];
        [_favoriteNum setTitle:@"0" forState:UIControlStateNormal];
        [_favoriteNum setTitleColor:ColorWhite forState:UIControlStateNormal];
        _favoriteNum.titleLabel.font = SmallFont;
        [_favoriteNum setImage:[UIImage imageNamed:@"icon_home_likenum"] forState:UIControlStateNormal];
        [_favoriteNum setImageEdgeInsets:UIEdgeInsetsMake(0, -2, 0, 0)];
        [self addSubview:_favoriteNum];
    }
    return self;
}

-(void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:NO];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _imageView.frame = self.bounds;
    _favoriteNum.frame = CGRectMake(10, self.bounds.size.height - 20, self.bounds.size.width - 20, 12);
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.imageView setImage:nil];
}

- (void)initData:(Aweme *)aweme {
    __weak __typeof(self) wself = self;
    [self.imageView setWebPImageWithURL:[NSURL URLWithString:aweme.video.dynamic_cover.url_list.firstObject] progressBlock:^(CGFloat percent) {
    } completedBlock:^(UIImage *image, NSError *error) {
        if(!error) {
            [wself.imageView setImage:image];
        }
    }];
    [self.favoriteNum setTitle:[NSString formatCount:aweme.statistics.digg_count] forState:UIControlStateNormal];
}

@end
