//
//  ImageMessageCell.m
//  Douyin
//
//  Created by Qiao Shi on 2018/7/30.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

#import "ImageMessageCell.h"
#import "PhotoView.h"

#define COMMON_MSG_PADDING         8
#define MAX_MSG_IMAGE_WIDTH        200
#define MAX_MSG_IMAGE_HEIGHT       200
#define MSG_IMAGE_CORNOR_RADIUS    10

@interface ImageMessageCell ()
@property (nonatomic, assign) CGFloat imageWidth;
@property (nonatomic, assign) CGFloat imageHeight;
@property (nonatomic, strong) UIImage *rectImage;
@end
@implementation ImageMessageCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = ColorClear;
        _avatar = [[UIImageView alloc] init];
        _avatar.image = [UIImage imageNamed:@"img_find_default"];
        _avatar.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_avatar];
        
        _imageMsg = [[UIImageView alloc] init];
        _imageMsg.backgroundColor = ColorGray;
        _imageMsg.contentMode = UIViewContentModeScaleAspectFit;
        _imageMsg.layer.cornerRadius = MSG_IMAGE_CORNOR_RADIUS;
        _imageMsg.userInteractionEnabled = YES;
        
        [_imageMsg addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showMenu)]];
        [_imageMsg addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showPhotoView)]];
        [self addSubview:_imageMsg];
        
        _progressView = [CircleProgressView new];
        [self addSubview:_progressView];
    }
    return self;
}

-(void)prepareForReuse {
    [super prepareForReuse];
    _imageMsg.image = nil;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    if([MD5_UDID isEqualToString:_chat.visitor.udid]){
        _avatar.frame = CGRectMake(SCREEN_WIDTH - COMMON_MSG_PADDING - 30, COMMON_MSG_PADDING, 30, 30);
    }else {
        _avatar.frame = CGRectMake(COMMON_MSG_PADDING, COMMON_MSG_PADDING, 30, 30);
    }
    [self updateImageFrame];
    [_progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.imageMsg);
        make.width.height.mas_equalTo(50);
    }];
}
-(void)updateImageFrame {
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    if([MD5_UDID isEqualToString:_chat.visitor.udid]){
        _imageMsg.frame = CGRectMake(CGRectGetMinX(self.avatar.frame) - COMMON_MSG_PADDING - _imageWidth, COMMON_MSG_PADDING, _imageWidth, _imageHeight);
    }else {
        _imageMsg.frame = CGRectMake(CGRectGetMaxX(self.avatar.frame) + COMMON_MSG_PADDING, COMMON_MSG_PADDING, _imageWidth, _imageHeight);
    }
    [CATransaction commit];
}
-(void)initData:(GroupChat *)chat {
    _chat = chat;
    _imageWidth = [ImageMessageCell imageWidth:_chat];
    _imageHeight = [ImageMessageCell imageHeight:_chat];
    
    _rectImage = nil;
    [_progressView setHidden:NO];
    [_progressView setTipHidden:YES];
    
    __weak __typeof(self) wself = self;
    
    if(chat.picImage) {
        _rectImage = chat.picImage;
        UIImage *image = [chat.picImage drawRoundedRectImage:MSG_IMAGE_CORNOR_RADIUS width:_imageWidth height:_imageHeight];
        [_imageMsg setImage:image];
        [self updateImageFrame];
    }
    
    if(_chat.isTemp) {
        [_progressView setProgress:_chat.percent];
        if(_chat.isFailed) {
            [_progressView setTipHidden:NO];
            return;
        }
        if(_chat.isCompleted) {
            [_progressView setHidden:YES];
            return;
        }
    }else {
        [_imageMsg setImageWithURL:[NSURL URLWithString:chat.pic_medium.url] progressBlock:^(CGFloat percent) {
            [wself.progressView setProgress:percent];
        } completedBlock:^(UIImage *image, NSError *error) {
            if(!error) {
                wself.chat.picImage = image;
                wself.rectImage = image;
                wself.imageMsg.image = [image drawRoundedRectImage:MSG_IMAGE_CORNOR_RADIUS width:wself.imageWidth height:wself.imageHeight];
                [wself updateImageFrame];
                [wself.progressView setHidden:YES];
            }else {
                [wself.progressView setTipHidden:NO];
            }
        }];
    }
    [_avatar setImageWithURL:[NSURL URLWithString:chat.visitor.avatar_thumbnail.url] completedBlock:^(UIImage *image, NSError *error) {
        wself.avatar.image = [image drawCircleImage];
    }];
}


+(CGFloat)imageWidth:(GroupChat *)chat {
    NSInteger width = chat.pic_large.width;
    NSInteger height = chat.pic_large.height;
    CGFloat ratio = (CGFloat)width/(CGFloat)height;
    if(width > height) {
        if(width > MAX_MSG_IMAGE_WIDTH) {
            width = MAX_MSG_IMAGE_WIDTH;
        }
    }else {
        if(height > MAX_MSG_IMAGE_HEIGHT) {
            width = MAX_MSG_IMAGE_WIDTH*ratio;
        }
    }
    return width;
}

+(CGFloat)imageHeight:(GroupChat *)chat {
    NSInteger width = chat.pic_large.width;
    NSInteger height = chat.pic_large.height;
    CGFloat ratio = (CGFloat)width/(CGFloat)height;
    if(width > height) {
        if(width > MAX_MSG_IMAGE_WIDTH) {
            height = MAX_MSG_IMAGE_WIDTH/ratio;
        }
    }else {
        if(height > MAX_MSG_IMAGE_HEIGHT) {
            height = MAX_MSG_IMAGE_HEIGHT;
        }
    }
    return height;
}
-(void)showMenu {
    if([MD5_UDID isEqualToString:_chat.visitor.udid]) {
        UIMenuController *menu = [UIMenuController sharedMenuController];
        if(!menu.isMenuVisible) {
            [self becomeFirstResponder];
            [menu setTargetRect:[self menuFrame] inView:_imageMsg];
            UIMenuItem *delete = [[UIMenuItem alloc] initWithTitle:@"删除" action:@selector(onMenuDelete)];
            menu.menuItems = @[delete];
            [menu setMenuVisible:YES animated:YES];
            
        }
    }
}

-(void)showPhotoView {
    PhotoView *photoView = [[PhotoView alloc] initWithImage:_rectImage urlPath:_chat.pic_original.url];
    [photoView show];
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
    if (action == @selector(onMenuDelete)){
        return YES;
    }
    return NO;
}
- (CGRect)menuFrame {
    return CGRectMake(CGRectGetMidX(_imageMsg.bounds) - 60, 10, 120, 50);
}

+(CGFloat)cellHeight:(GroupChat *)chat {
    return [self imageHeight:chat] + COMMON_MSG_PADDING*2;
}

@end
