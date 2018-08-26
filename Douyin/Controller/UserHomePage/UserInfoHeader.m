//
//  UserInfoHeader.m
//  Douyin
//
//  Created by Qiao Shi on 2018/7/30.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

#import "UserInfoHeader.h"

#define DEFAULT_ANIMATION_TIME 0.25

@interface UserInfoHeader ()

@property (nonatomic, strong) UIView       *containerView;
@property (nonatomic, strong) NSMutableArray<NSString *>       *constellations;

@end

@implementation UserInfoHeader
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self){
        _constellations = [[NSMutableArray alloc]initWithObjects:@"射手座",@"摩羯座",@"双鱼座",@"白羊座",@"水瓶座",@"金牛座",@"双子座",@"巨蟹座",@"狮子座",@"处女座",@"天秤座",@"天蝎座",nil];
        _isFollowed = NO;
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews {
    [self initAvatarBackground];
    
    _containerView = [[UIView alloc] initWithFrame:self.bounds];
    [self addSubview:_containerView];
    
    [self initAvatar];
    [self initActionsView];
    [self initInfoView];
}

- (void) initAvatarBackground {
    _avatarBackground = [[UIImageView alloc] initWithFrame:self.bounds];
    _avatarBackground.clipsToBounds = YES;
    _avatarBackground.image = [UIImage imageNamed:@"img_find_default"];
    _avatarBackground.backgroundColor = ColorThemeGray;
    _avatarBackground.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:_avatarBackground];
    
    UIBlurEffect *blurEffect =[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc]initWithEffect:blurEffect];
    visualEffectView.frame = self.bounds;
    visualEffectView.alpha = 1;
    [_avatarBackground addSubview:visualEffectView];
}

- (void) initAvatar {
    
    int avatarRadius = 45;
    _avatar = [[UIImageView alloc] init];
    _avatar.image = [UIImage imageNamed:@"img_find_default"];
    _avatar.userInteractionEnabled = YES;
    _avatar.tag = AVATAE_TAG;
    [_avatar addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapAction:)]];
    [_containerView addSubview:_avatar];
    
    CALayer *paddingLayer = [CALayer layer];
    paddingLayer.frame = CGRectMake(0, 0, avatarRadius*2, avatarRadius*2);
    paddingLayer.borderColor = ColorWhiteAlpha20.CGColor;
    paddingLayer.borderWidth = 2;
    paddingLayer.cornerRadius = avatarRadius;
    [_avatar.layer addSublayer:paddingLayer];
    
    [_avatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(25 + 44 + STATUS_BAR_HEIGHT);
        make.left.equalTo(self).offset(15);
        make.width.height.mas_equalTo(avatarRadius*2);
    }];
}

- (void) initActionsView {
    _settingIcon = [[UIImageView alloc] init];
    _settingIcon.image = [UIImage imageNamed:@"icon_titlebar_whitemore"];
    _settingIcon.contentMode = UIViewContentModeCenter;
    _settingIcon.layer.backgroundColor = ColorWhiteAlpha20.CGColor;
    _settingIcon.layer.cornerRadius = 2;
    _settingIcon.tag = SETTING_TAG;
    _settingIcon.userInteractionEnabled = YES;
    [_settingIcon addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onTapAction:)]];
    [_containerView addSubview:_settingIcon];
    [_settingIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.avatar);
        make.right.equalTo(self).inset(15);
        make.width.height.mas_equalTo(40);
    }];
    
    _focusIcon = [[UIImageView alloc] init];
    _focusIcon.image = [UIImage imageNamed:@"icon_titlebar_addfriend"];
    _focusIcon.contentMode = UIViewContentModeCenter;
    _focusIcon.userInteractionEnabled = YES;
    _focusIcon.clipsToBounds = YES;
    _focusIcon.hidden = !_isFollowed;
    _focusIcon.layer.backgroundColor = ColorWhiteAlpha20.CGColor;
    _focusIcon.layer.cornerRadius = 2;
    _focusIcon.tag = FOCUS_CANCEL_TAG;
    [_focusIcon addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onTapAction:)]];
    [_containerView addSubview:_focusIcon];
    [_focusIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.settingIcon);
        make.right.equalTo(self.settingIcon.mas_left).inset(5);
        make.width.height.mas_equalTo(40);
    }];
    
    _sendMessage = [[UILabel alloc] init];
    _sendMessage.text = @"发消息";
    _sendMessage.textColor = ColorWhiteAlpha60;
    _sendMessage.textAlignment = NSTextAlignmentCenter;
    _sendMessage.font = MediumFont;
    _sendMessage.hidden = !_isFollowed;
    _sendMessage.layer.backgroundColor = ColorWhiteAlpha20.CGColor;
    _sendMessage.layer.cornerRadius = 2;
    _sendMessage.tag = SEND_MESSAGE_TAG;
    _sendMessage.userInteractionEnabled = YES;
    [_sendMessage addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onTapAction:)]];
    [_containerView addSubview:_sendMessage];
    [_sendMessage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.focusIcon);
        make.right.equalTo(self.focusIcon.mas_left).inset(5);
        make.height.mas_equalTo(40);
        make.width.mas_equalTo(80);
    }];
    
    _focusButton = [[UIButton alloc] init];
    [_focusButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 2, 0, 0)];
    [_focusButton setTitle:@"关注" forState:UIControlStateNormal];
    [_focusButton setTitleColor:ColorWhite forState:UIControlStateNormal];
    _focusButton.titleLabel.font = MediumFont;
    _focusButton.hidden = _isFollowed;
    _focusButton.clipsToBounds = YES;
    [_focusButton setImage:[UIImage imageNamed:@"icon_personal_add_little"] forState:UIControlStateNormal];
    [_focusButton setImageEdgeInsets:UIEdgeInsetsMake(0, -2, 0, 0)];
    _focusButton.layer.backgroundColor = ColorThemeRed.CGColor;
    _focusButton.layer.cornerRadius = 2;
    _focusButton.tag = FOCUS_TAG;
    [_focusButton addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onTapAction:)]];
    [_containerView addSubview:_focusButton];
    [_focusButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.settingIcon);
        make.right.equalTo(self.settingIcon.mas_left).inset(5);
        make.height.mas_equalTo(40);
        make.width.mas_equalTo(80);
    }];
}

- (void)initInfoView {
    _nickName = [[UILabel alloc] init];
    _nickName.text = @"name";
    _nickName.textColor = ColorWhite;
    _nickName.font = SuperBigBoldFont;
    [_containerView addSubview:_nickName];
    [_nickName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.avatar.mas_bottom).offset(20);
        make.left.equalTo(self.avatar);
        make.right.equalTo(self.settingIcon);
    }];
    
    _douyinNum = [[UILabel alloc] init];
    _douyinNum.text = @"抖音号：";
    _douyinNum.textColor = ColorWhite;
    _douyinNum.font = SmallFont;
    [_containerView addSubview:_douyinNum];
    [_douyinNum mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nickName.mas_bottom).offset(3);
        make.left.right.equalTo(self.nickName);
    }];
    
    UIImageView *weiboArrow = [[UIImageView alloc] init];
    weiboArrow.image = [UIImage imageNamed:@"icon_arrow"];
    [_containerView addSubview:weiboArrow];
    [weiboArrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.right.equalTo(self.douyinNum);
        make.width.height.mas_equalTo(12);
    }];
    
    _github = [[UIButton alloc] init];
    [_github setTitleEdgeInsets:UIEdgeInsetsMake(0, 3, 0, 0)];
    [_github setTitle:@"Github主页" forState:UIControlStateNormal];
    [_github setTitleColor:ColorWhite forState:UIControlStateNormal];
    _github.titleLabel.font = SmallFont;
    [_github setImage:[UIImage imageNamed:@"icon_github"] forState:UIControlStateNormal];
    [_github setImageEdgeInsets:UIEdgeInsetsMake(0, -3, 0, 0)];
    _github.tag = GITHUB_TAG;
    [_github addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapAction:)]];
    [_containerView addSubview:_github];
    [_github mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.douyinNum);
        make.right.equalTo(weiboArrow).inset(5);
        make.width.mas_equalTo(92);
    }];
    
    UIView *splitView = [[UIView alloc] init];
    splitView.backgroundColor = ColorWhiteAlpha20;
    [_containerView addSubview:splitView];
    [splitView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.douyinNum.mas_bottom).offset(10);
        make.left.right.equalTo(self.nickName);
        make.height.mas_equalTo(0.5);
    }];
    
    _brief = [[UILabel alloc] init];
    _brief.text = @"本宝宝暂时还没想到个性的签名";
    _brief.textColor = ColorWhiteAlpha60;
    _brief.font = SmallFont;
    _brief.numberOfLines = 0;
    [_containerView addSubview:_brief];
    [_brief mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(splitView.mas_bottom).offset(10);
        make.left.right.equalTo(self.nickName);
    }];
    
    _genderIcon = [[UIImageView alloc] init];
    _genderIcon.image = [UIImage imageNamed:@"iconUserProfileGirl"];
    _genderIcon.layer.backgroundColor = ColorWhiteAlpha20.CGColor;
    _genderIcon.layer.cornerRadius = 9;
    _genderIcon.contentMode = UIViewContentModeCenter;
    [_containerView addSubview:_genderIcon];
    [_genderIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nickName);
        make.top.equalTo(self.brief.mas_bottom).offset(8);
        make.height.mas_equalTo(18);
        make.width.mas_equalTo(22);
    }];
    
    _constellation = [[UITextView alloc] init];
    _constellation.text = @"座";
    _constellation.textColor = ColorWhite;
    _constellation.font = SuperSmallFont;
    _constellation.scrollEnabled = NO;
    _constellation.editable = NO;
    _constellation.textContainerInset = UIEdgeInsetsMake(3, 6, 3, 6);
    _constellation.textContainer.lineFragmentPadding = 0;
    
    _constellation.layer.backgroundColor = ColorWhiteAlpha20.CGColor;
    _constellation.layer.cornerRadius = 9;
    [_constellation sizeToFit];
    [_containerView addSubview:_constellation];
    [_constellation mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.genderIcon.mas_right).offset(5);
        make.top.height.equalTo(self.genderIcon);
    }];
    
    _likeNum = [[UILabel alloc] init];
    _likeNum.text = @"0获赞";
    _likeNum.textColor = ColorWhite;
    _likeNum.font = BigBoldFont;
    [_containerView addSubview:_likeNum];
    [_likeNum mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.genderIcon.mas_bottom).offset(15);
        make.left.equalTo(self.avatar);
    }];
    
    _followNum = [[UILabel alloc] init];
    _followNum.text = @"0关注";
    _followNum.textColor = ColorWhite;
    _followNum.font = BigBoldFont;
    [_containerView addSubview:_followNum];
    [_followNum mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.likeNum);
        make.left.equalTo(self.likeNum.mas_right).offset(30);
    }];
    
    _followedNum = [[UILabel alloc] init];
    _followedNum.text = @"0粉丝";
    _followedNum.textColor = ColorWhite;
    _followedNum.font = BigBoldFont;
    [_containerView addSubview:_followedNum];
    [_followedNum mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.likeNum);
        make.left.equalTo(self.followNum.mas_right).offset(30);
    }];
}

- (void)initData:(User *)user {
    __weak __typeof(self) wself = self;
    [_avatar setImageWithURL:[NSURL URLWithString:user.avatar_medium.url_list.firstObject] completedBlock:^(UIImage *image, NSError *error) {
        [wself.avatarBackground setImage:image];
        [wself.avatar setImage:[image drawCircleImage]];
    }];
    [_nickName setText:user.nickname];
    [_douyinNum setText:[NSString stringWithFormat:@"抖音号:%@", user.short_id]];
    if(![user.signature isEqual: @""]) {
        [_brief setText:user.signature];
    }
    [_genderIcon setImage:[UIImage imageNamed:user.gender == 0 ? @"iconUserProfileBoy" : @"iconUserProfileGirl"]];
    [_constellation setText:[_constellations objectAtIndex:user.constellation]];
    [_likeNum setText:[NSString stringWithFormat:@"%ld%@",(long)user.total_favorited,@"获赞"]];
    [_followNum setText:[NSString stringWithFormat:@"%ld%@",(long)user.following_count,@"关注"]];
    [_followedNum setText:[NSString stringWithFormat:@"%ld%@",(long)user.follower_count,@"粉丝"]];
}

- (void)onTapAction:(UITapGestureRecognizer *)sender {
    if(self.delegate) {
        [self.delegate onUserActionTap:sender.view.tag];
    }
}

#pragma update position when over scroll

- (void)overScrollAction:(CGFloat) offsetY {
    CGFloat scaleRatio = fabs(offsetY)/370.0f;
    CGFloat overScaleHeight = (370.0f * scaleRatio)/2;
    _avatarBackground.transform = CGAffineTransformConcat(CGAffineTransformMakeScale(scaleRatio + 1.0f, scaleRatio + 1.0f), CGAffineTransformMakeTranslation(0, -overScaleHeight));
}

- (void)scrollToTopAction:(CGFloat) offsetY {
    CGFloat alphaRatio = offsetY/(370.0f - 44 - STATUS_BAR_HEIGHT);
    _containerView.alpha = 1.0f - alphaRatio;
}


#pragma animation

- (void)startFocusAnimation {
    [self showSendMessageAnimation];
    [self showFollowedAnimation];
    [self showUnFollowedAnimation];
}

- (void)showSendMessageAnimation {
    if(!_isFollowed) {
        [_focusIcon setHidden:NO];
        [_sendMessage setHidden:NO];
    }
    if(_isFollowed) {
        [_focusButton setHidden:NO];
    }
    
    _focusButton.userInteractionEnabled = NO;
    _focusIcon.userInteractionEnabled = NO;
    if(_isFollowed) {
        [UIView animateWithDuration:DEFAULT_ANIMATION_TIME animations:^{
            self.sendMessage.alpha = 0;
            CGRect frame = self.sendMessage.frame;
            frame.origin.x = frame.origin.x - 35;
            [self.sendMessage setFrame:frame];
        } completion:^(BOOL finished) {
            [self.focusIcon setHidden:self.isFollowed];
            [self.focusButton setHidden:!self.isFollowed];
            self.isFollowed = !self.isFollowed;
            
            CGRect frame = self.sendMessage.frame;
            frame.origin.x = frame.origin.x + 35;
            [self.sendMessage setFrame:frame];
            
            self.focusButton.userInteractionEnabled = YES;
            self.focusIcon.userInteractionEnabled = YES;
        }];
    }else {
        CGRect frame = _sendMessage.frame;
        frame.origin.x = frame.origin.x - 35;
        [_sendMessage setFrame:frame];
        [UIView animateWithDuration:DEFAULT_ANIMATION_TIME animations:^{
            self.sendMessage.alpha = 1;
            CGRect frame = self.sendMessage.frame;
            frame.origin.x = frame.origin.x + 35;
            [self.sendMessage setFrame:frame];
        } completion:^(BOOL finished) {
            [self.focusIcon setHidden:self.isFollowed];
            [self.focusButton setHidden:!self.isFollowed];
            self.isFollowed = !self.isFollowed;
            
            self.focusButton.userInteractionEnabled = YES;
            self.focusIcon.userInteractionEnabled = YES;
        }];
    }
}
- (void)showFollowedAnimation {
    CAAnimationGroup *animationGroup = [[CAAnimationGroup alloc] init];
    animationGroup.duration = DEFAULT_ANIMATION_TIME;
    animationGroup.removedOnCompletion = NO;
    animationGroup.fillMode = kCAFillModeForwards;
    
    CALayer *layer = _focusButton.layer;
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = [[UIBezierPath bezierPathWithRect:CGRectMake(0, 0 , _focusButton.frame.size.width, _focusButton.frame.size.height )] CGPath];
    layer.mask = maskLayer;
    
    CABasicAnimation *positionAnimation = [CABasicAnimation animation];
    positionAnimation.keyPath = @"position.x";
    if (_isFollowed){
        positionAnimation.fromValue = @(layer.frame.origin.x + layer.frame.size.width);
        positionAnimation.toValue = @(layer.frame.origin.x + layer.frame.size.width*0.5);
    }else {
        positionAnimation.fromValue = @(layer.frame.origin.x + layer.frame.size.width*0.5);
        positionAnimation.toValue = @(layer.frame.origin.x + layer.frame.size.width);
    }
    
    CABasicAnimation *sizeAnimation = [CABasicAnimation animation];
    sizeAnimation.keyPath = @"bounds.size.width";
    if (_isFollowed){
        sizeAnimation.fromValue = @(0);
        sizeAnimation.toValue = @(layer.frame.size.width);
    }else {
        sizeAnimation.fromValue = @(layer.frame.size.width);
        sizeAnimation.toValue = @(0);
    }
    
    [animationGroup setAnimations:@[positionAnimation, sizeAnimation]];
    [layer addAnimation:animationGroup forKey:nil];
}

- (void)showUnFollowedAnimation {
    CAAnimationGroup *animationGroup = [[CAAnimationGroup alloc] init];
    animationGroup.duration = DEFAULT_ANIMATION_TIME;
    animationGroup.removedOnCompletion = NO;
    animationGroup.fillMode = kCAFillModeForwards;
    
    CALayer *layer = _focusIcon.layer;
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = [[UIBezierPath bezierPathWithRect:CGRectMake(0, 0 , _focusIcon.frame.size.width, _focusIcon.frame.size.height )] CGPath];
    layer.mask = maskLayer;
    
    CABasicAnimation *positionAnimation = [CABasicAnimation animation];
    positionAnimation.keyPath = @"position.x";
    if (_isFollowed){
        positionAnimation.fromValue = @(layer.frame.origin.x + layer.frame.size.width*0.5);
        positionAnimation.toValue = @(layer.frame.origin.x - layer.frame.size.width);
    }else {
        positionAnimation.fromValue = @(layer.frame.origin.x - layer.frame.size.width);
        positionAnimation.toValue = @(layer.frame.origin.x + layer.frame.size.width*0.5);
    }
    
    CABasicAnimation *sizeAnimation = [CABasicAnimation animation];
    sizeAnimation.keyPath = @"bounds.size.width";
    if (_isFollowed){
        sizeAnimation.fromValue = @(layer.frame.size.width);
        sizeAnimation.toValue = @(0);
    }else {
        sizeAnimation.fromValue = @(0);
        sizeAnimation.toValue = @(layer.frame.size.width);
    }
    
    [animationGroup setAnimations:@[positionAnimation, sizeAnimation]];
    [layer addAnimation:animationGroup forKey:nil];
}


@end
