//
//  TextMessageCell.m
//  Douyin
//
//  Created by Qiao Shi on 2018/7/30.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

#import "TextMessageCell.h"
#import "EmotionHelper.h"

#define COMMON_MSG_PADDING         8
#define USER_MSG_CORNER_RADIUS     10
#define MAX_USER_MSG_WIDTH         SCREEN_WIDTH - 160

@implementation TextMessageCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = ColorClear;
        _avatar = [[UIImageView alloc] init];
        _avatar.image = [UIImage imageNamed:@"img_find_default"];
        _avatar.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_avatar];
        
        _textView = [[UITextView alloc] init];
        _textView.textColor = [[TextMessageCell attributes] valueForKey:NSForegroundColorAttributeName];
        _textView.font = [[TextMessageCell attributes] valueForKey:NSFontAttributeName];
        _textView.scrollEnabled = NO;
        _textView.editable = NO;
        _textView.selectable = NO;
        _textView.backgroundColor = ColorClear;
        _textView.textContainerInset = UIEdgeInsetsMake(USER_MSG_CORNER_RADIUS, USER_MSG_CORNER_RADIUS, USER_MSG_CORNER_RADIUS, USER_MSG_CORNER_RADIUS);
        _textView.textContainer.lineFragmentPadding = 0;
        [_textView addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showMenu)]];
        [self addSubview:_textView];
        
        _backgroundlayer = [[CAShapeLayer alloc]init];
        _backgroundlayer.zPosition = -1;
        [_textView.layer addSublayer:_backgroundlayer];
        
        _indicatorView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon30WhiteSmall"]];
        [_indicatorView setHidden:YES];
        [self addSubview:_indicatorView];
        
        _tipIcon = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icWarning"]];
        [_tipIcon setHidden:YES];
        [self addSubview:_tipIcon];
    }
    return self;
}

-(void)prepareForReuse {
    [super prepareForReuse];
    [_indicatorView setHidden:YES];
    [_tipIcon setHidden:YES];
}

-(void)layoutSubviews {
    [super layoutSubviews];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString: _textView.attributedText];
    [attributedString addAttributes:[TextMessageCell attributes] range:NSMakeRange(0, attributedString.length)];
    attributedString = [EmotionHelper stringToEmotion:attributedString];
    CGSize size = [attributedString multiLineSize:MAX_USER_MSG_WIDTH];
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.backgroundlayer.path = [self createBezierPath:USER_MSG_CORNER_RADIUS width:size.width height:size.height].CGPath;
    self.backgroundlayer.frame = CGRectMake(0, 0, size.width + USER_MSG_CORNER_RADIUS * 2, size.height + USER_MSG_CORNER_RADIUS * 2);
    self.backgroundlayer.transform = CATransform3DIdentity;
    if([MD5_UDID isEqualToString:_chat.visitor.udid]){
        _avatar.frame = CGRectMake(SCREEN_WIDTH - COMMON_MSG_PADDING - 30, COMMON_MSG_PADDING, 30, 30);
        _textView.frame = CGRectMake(CGRectGetMinX(self.avatar.frame) - COMMON_MSG_PADDING - (size.width + USER_MSG_CORNER_RADIUS * 2), COMMON_MSG_PADDING, size.width + USER_MSG_CORNER_RADIUS * 2, size.height + USER_MSG_CORNER_RADIUS * 2);
        _backgroundlayer.transform = CATransform3DMakeRotation(M_PI, 0, 1, 0);
        _backgroundlayer.fillColor = ColorThemeYellow.CGColor;
        
    }else {
        _avatar.frame = CGRectMake(COMMON_MSG_PADDING, COMMON_MSG_PADDING, 30, 30);
        _textView.frame = CGRectMake(CGRectGetMaxX(self.avatar.frame) + COMMON_MSG_PADDING, COMMON_MSG_PADDING, size.width + USER_MSG_CORNER_RADIUS * 2, size.height + USER_MSG_CORNER_RADIUS * 2);
        _backgroundlayer.fillColor = ColorWhite.CGColor;
    }
    [CATransaction commit];
    [_indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.textView);
        make.right.equalTo(self.textView.mas_left).inset(10);
        make.width.height.mas_equalTo(15);
    }];
    [_tipIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.textView);
        make.right.equalTo(self.textView.mas_left).inset(10);
        make.width.height.mas_equalTo(15);
    }];
}

-(void)initData:(GroupChat *)chat {
    _chat = chat;
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:chat.msg_content];
    [attributedString addAttributes:[TextMessageCell attributes] range:NSMakeRange(0, attributedString.length)];
    attributedString = [EmotionHelper stringToEmotion:attributedString];
    _textView.attributedText = attributedString;
    
    if(chat.isTemp) {
        [self startAnim];
        if(chat.isFailed) {
            [_tipIcon setHidden:NO];
        }
        if(chat.isCompleted) {
            [self stopAnim];
        }
    }else {
        [self stopAnim];
    }
    
    __weak __typeof(self) wself = self;
    [_avatar setImageWithURL:[NSURL URLWithString:chat.visitor.avatar_thumbnail.url] progressBlock:^(CGFloat persent) {
    } completedBlock:^(UIImage *image, NSError *error) {
        wself.avatar.image = [image drawCircleImage];
    }];
}

- (void)startAnim {
    [self.indicatorView setHidden:NO];
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0];
    rotationAnimation.duration = 1.5;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = MAXFLOAT;
    [self.indicatorView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}
- (void)stopAnim {
    [self.indicatorView setHidden:YES];
    [self.indicatorView.layer removeAllAnimations];
}

-(UIBezierPath *)createBezierPath:(CGFloat)cornerRadius width:(CGFloat)width height:(CGFloat)height {
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:CGPointMake(0, cornerRadius)];
    [bezierPath addArcWithCenter:CGPointMake(cornerRadius, cornerRadius) radius:cornerRadius startAngle:M_PI endAngle:-M_PI_2 clockwise:YES];
    [bezierPath addLineToPoint:CGPointMake(cornerRadius + width, 0)];
    [bezierPath addArcWithCenter:CGPointMake(cornerRadius + width, cornerRadius) radius:cornerRadius startAngle:-M_PI_2 endAngle:0 clockwise:YES];
    [bezierPath addLineToPoint:CGPointMake(cornerRadius + width + cornerRadius , cornerRadius + height)];
    [bezierPath addArcWithCenter:CGPointMake(cornerRadius + width, cornerRadius + height) radius:cornerRadius startAngle:0 endAngle:M_PI_2 clockwise:YES];
    [bezierPath addLineToPoint:CGPointMake(cornerRadius + cornerRadius/4.0f, cornerRadius + height + cornerRadius)];
    [bezierPath addArcWithCenter:CGPointMake(cornerRadius + cornerRadius/4.0f, cornerRadius + height) radius:cornerRadius startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
    [bezierPath addLineToPoint:CGPointMake(cornerRadius/4.0f, cornerRadius + cornerRadius/4.0f)];
    [bezierPath addArcWithCenter:CGPointMake(0, cornerRadius + cornerRadius/4.0f) radius:cornerRadius/4.0f startAngle:0 endAngle:-M_PI_2 clockwise:NO];
    return bezierPath;
}
-(void)showMenu {
    [self becomeFirstResponder];
    UIMenuController *menu = [UIMenuController sharedMenuController];
    if(!menu.isMenuVisible) {
        [menu setTargetRect:[self menuFrame] inView:_textView];
        UIMenuItem *copy = [[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(onMenuCopy)];
        if([MD5_UDID isEqualToString:_chat.visitor.udid]) {
            UIMenuItem *delete = [[UIMenuItem alloc] initWithTitle:@"删除" action:@selector(onMenuDelete)];
            menu.menuItems = @[copy, delete];
        }else {
            menu.menuItems = @[copy];
        }
        [menu setMenuVisible:YES animated:YES];
    }
}

- (void)onMenuCopy {
    if(_onMenuAction) {
        _onMenuAction(CopyAction);
    }
}

- (void)onMenuDelete {
    if(_onMenuAction) {
        _onMenuAction(DeleteAction);
    }
}

-(BOOL)canBecomeFirstResponder{
    return YES;
}

-(BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    if (action == @selector(onMenuCopy) || action == @selector(onMenuDelete)){
        return YES;
    }
    return NO;
}

- (CGRect)menuFrame {
    return CGRectMake(CGRectGetMidX(_textView.bounds) - 60, 10, 120, 50);
}

+(NSDictionary* ) attributes {
    return @{NSFontAttributeName:BigFont,NSForegroundColorAttributeName:ColorBlack};
}

+(CGFloat)cellHeight:(GroupChat *)chat {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:chat.msg_content];
    [attributedString addAttributes:[TextMessageCell attributes] range:NSMakeRange(0, attributedString.length)];
    attributedString = [EmotionHelper stringToEmotion:attributedString];
    CGSize size = [attributedString multiLineSize:MAX_USER_MSG_WIDTH];
    CGFloat height = size.height + USER_MSG_CORNER_RADIUS * 2 + COMMON_MSG_PADDING * 2;
    return height;
}
@end
