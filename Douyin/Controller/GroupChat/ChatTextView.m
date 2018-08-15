//
//  ChatTextView.m
//  Douyin
//
//  Created by Qiao Shi on 2018/7/30.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

#import "ChatTextView.h"
#import "Masonry.h"
#import "EmotionSelector.h"
#import "PhotoSelector.h"
#import "EmotionHelper.h"

#define EMOTION_TAG                1000
#define PHOTO_TAG                  2000

#define LEFT_INSET                 15
#define RIGHT_INSET                85
#define TOP_BOTTOM_INSET           15


@interface ChatTextView ()<UITextViewDelegate, UIGestureRecognizerDelegate, EmotionSelectorDelegate, PhotoSelectorDelegate> {
    EmotionSelector        *emotionSelector;
    PhotoSelector          *photoSelector;
}
@property (nonatomic, assign) int                              maxNumberOfLine;
@property (nonatomic, assign) CGFloat                          textHeight;
@property (nonatomic, assign) CGFloat                          containerBoardHeight;
@property (nonatomic, retain) UILabel                          *placeholderLabel;
@property (nonatomic, strong) UIButton                         *emotionBtn;
@property (nonatomic, strong) UIButton                         *photoBtn;
@property (nonatomic, strong) UIVisualEffectView               *visualEffectView;
@end

@implementation ChatTextView
- (instancetype)init {
    return [self initWithFrame:SCREEN_FRAME];
}

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        self.backgroundColor = ColorClear;
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGuesture:)];
        tapGestureRecognizer.delegate = self;
        [self addGestureRecognizer:tapGestureRecognizer];
        
        _container = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 0)];
        _container.backgroundColor = ColorThemeGrayDark;
        [self addSubview:_container];
        
        _editMessageType = EditNoneMessage;
        
        _textView = [[UITextView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 0)];
        _textView.backgroundColor = ColorClear;
        _textView.clipsToBounds = NO;
        _textView.textColor = ColorWhite;
        _textView.font = BigFont;
        _textView.returnKeyType = UIReturnKeySend;
        _textView.scrollEnabled = NO;
        _textView.textContainer.lineBreakMode = NSLineBreakByTruncatingTail;
        _textView.textContainerInset = UIEdgeInsetsMake(TOP_BOTTOM_INSET, LEFT_INSET, TOP_BOTTOM_INSET, RIGHT_INSET);
        _textView.textContainer.lineFragmentPadding = 0;
        _textHeight = ceilf(_textView.font.lineHeight);
        
        _placeholderLabel = [[UILabel alloc]init];
        _placeholderLabel.text = @"发送消息...";
        _placeholderLabel.textColor = ColorGray;
        _placeholderLabel.font = BigFont;
        _placeholderLabel.frame = CGRectMake(LEFT_INSET, 0, SCREEN_WIDTH - LEFT_INSET - RIGHT_INSET, 50);
        [_textView addSubview:_placeholderLabel];

        _textView.delegate = self;
        [_container addSubview:_textView];
        
        
        _emotionBtn = [[UIButton alloc] init];
        _emotionBtn.tag = EMOTION_TAG;
        [_emotionBtn setImage:[UIImage imageNamed:@"baseline_emotion_white"] forState:UIControlStateNormal];
        [_emotionBtn setImage:[UIImage imageNamed:@"outline_keyboard_grey"] forState:UIControlStateSelected];
        [_emotionBtn addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGuesture:)]];
        [_textView addSubview:_emotionBtn];
        
        
        _photoBtn = [[UIButton alloc] init];
        _photoBtn.tag = PHOTO_TAG;
        [_photoBtn setImage:[UIImage imageNamed:@"outline_photo_white"] forState:UIControlStateNormal];
        [_photoBtn setImage:[UIImage imageNamed:@"outline_photo_red"] forState:UIControlStateSelected];
        [_photoBtn addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGuesture:)]];
        [_textView addSubview:_photoBtn];
        
        [self addObserver:self forKeyPath:@"containerBoardHeight" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    }
    return self;
}

-(EmotionSelector *)emotionSelector {
    if(!emotionSelector) {
        emotionSelector = [EmotionSelector new];
        emotionSelector.delegate = self;
        [emotionSelector addTextViewObserver:_textView];
        [emotionSelector setHidden : YES];
        [_container addSubview:emotionSelector];
    }
    return emotionSelector;
}

-(PhotoSelector *)photoSelector {
    if(!photoSelector) {
        photoSelector = [PhotoSelector new];
        photoSelector.delegate = self;
        [photoSelector setHidden:YES];
        [_container addSubview:photoSelector];
    }
    return photoSelector;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if([keyPath isEqualToString:@"containerBoardHeight"]) {
        if(_containerBoardHeight == 0 ){
            _container.backgroundColor = ColorThemeGrayDark;
            _textView.textColor = ColorWhite;
            
            [_emotionBtn setImage:[UIImage imageNamed:@"baseline_emotion_white"] forState:UIControlStateNormal];
            [_photoBtn setImage:[UIImage imageNamed:@"outline_photo_white"] forState:UIControlStateNormal];
        }else {
            _container.backgroundColor = ColorWhite;
            _textView.textColor = ColorBlack;
            
            [_emotionBtn setImage:[UIImage imageNamed:@"baseline_emotion_grey"] forState:UIControlStateNormal];
            [_photoBtn setImage:[UIImage imageNamed:@"outline_photo_grey"] forState:UIControlStateNormal];
        }
    }else {
        return [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateContainerFrame];
    
    _photoBtn.frame = CGRectMake(SCREEN_WIDTH - 50, 0, 50, 50);
    _emotionBtn.frame = CGRectMake(SCREEN_WIDTH - 85, 0, 50, 50);
    
    UIBezierPath* rounded = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(10.0f, 10.0f)];
    CAShapeLayer* shape = [[CAShapeLayer alloc] init];
    [shape setPath:rounded.CGPath];
    _container.layer.mask = shape;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitView = [super hitTest:point withEvent:event];
    if(hitView == self){
        if(_editMessageType == EditNoneMessage) {
            return nil;
        }
    }
    return hitView;
}

- (void)updateContainerFrame {
    CGFloat textViewHeight = _containerBoardHeight > 0 ? _textHeight + 2*TOP_BOTTOM_INSET : BigFont.lineHeight + 2*TOP_BOTTOM_INSET;
    _textView.frame = CGRectMake(0, 0, SCREEN_WIDTH,  textViewHeight);
    [UIView animateWithDuration:0.25f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.container.frame = CGRectMake(0, SCREEN_HEIGHT - self.containerBoardHeight - textViewHeight, SCREEN_WIDTH,  self.containerBoardHeight + textViewHeight);
                         if(self.delegate) {
                             [self.delegate onEditBoardHeightChange:self.container.frame.size.height];
                         }
                     }
                     completion:^(BOOL finished) {
                     }];
    
}

- (void)updateSelectorFrame:(BOOL)animated {
    CGFloat textViewHeight = _containerBoardHeight > 0 ? _textHeight + 2*TOP_BOTTOM_INSET : BigFont.lineHeight + 2*TOP_BOTTOM_INSET;
    if(animated) {
        switch (self.editMessageType) {
            case EditEmotionMessage:
                [self.emotionSelector setHidden : NO];
                self.emotionSelector.frame = CGRectMake(0, textViewHeight + self.containerBoardHeight, SCREEN_WIDTH,  self.containerBoardHeight);
                break;
            case EditPhotoMessage:
                [self.photoSelector setHidden : NO];
                self.photoSelector.frame = CGRectMake(0, textViewHeight + self.containerBoardHeight, SCREEN_WIDTH,  self.containerBoardHeight);
                break;
            default:
                break;
        }
    }
    [UIView animateWithDuration:0.25f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         switch (self.editMessageType) {
                             case EditEmotionMessage:
                                 self.emotionSelector.frame = CGRectMake(0, textViewHeight, SCREEN_WIDTH,  self.containerBoardHeight);
                                 self.photoSelector.frame = CGRectMake(0, textViewHeight + self.containerBoardHeight, SCREEN_WIDTH,  self.containerBoardHeight);
                                 break;
                             case EditPhotoMessage:
                                 self.photoSelector.frame = CGRectMake(0, textViewHeight, SCREEN_WIDTH,  self.containerBoardHeight);
                                 self.emotionSelector.frame = CGRectMake(0, textViewHeight + self.containerBoardHeight, SCREEN_WIDTH,  self.containerBoardHeight);
                                 break;
                             default:
                                 self.photoSelector.frame = CGRectMake(0, textViewHeight + self.containerBoardHeight, SCREEN_WIDTH,  self.containerBoardHeight);
                                 self.emotionSelector.frame = CGRectMake(0, textViewHeight + self.containerBoardHeight, SCREEN_WIDTH,  self.containerBoardHeight);
                                 break;
                         }
                     }
                     completion:^(BOOL finished) {
                         switch (self.editMessageType) {
                             case EditEmotionMessage:
                                 [self.photoSelector setHidden : YES];
                                 break;
                             case EditPhotoMessage:
                                 [self.emotionSelector setHidden : YES];
                                 break;
                             default:
                                 [self.photoSelector setHidden : YES];
                                 [self.emotionSelector setHidden : YES];
                                 break;
                         }
                     }];
}

//keyboard notification
- (void)keyboardWillShow:(NSNotification *)notification {
    _editMessageType = EditTextMessage;
    [_emotionBtn setSelected:NO];
    [_photoBtn setSelected:NO];
    [self setContainerBoardHeight:[notification keyBoardHeight]];
    [self updateContainerFrame];
    [self updateSelectorFrame:YES];
    
}

-(void)textViewDidChange:(UITextView *)textView {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:textView.attributedText];
    
    if(!textView.hasText) {
        [_placeholderLabel setHidden:NO];
        _textHeight = ceilf(_textView.font.lineHeight);
    }else {
        [_placeholderLabel setHidden:YES];
        _textHeight = [attributedString multiLineSize:SCREEN_WIDTH - LEFT_INSET - RIGHT_INSET].height;
    }
    [self updateContainerFrame];
    [self updateSelectorFrame:NO];
}


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if([text isEqualToString:@"\n"]) {
        [self onSend];
        return NO;
    }
    return YES;
}

//handle guesture tap
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([NSStringFromClass([touch.view.superview class]) isEqualToString:@"EmotionCell"]
        ||[NSStringFromClass([touch.view.superview class]) isEqualToString:@"PhotoCell"]) {
        return NO;
    }else {
        return YES;
    }
}

- (void)handleGuesture:(UITapGestureRecognizer *)sender {
    CGPoint point = [sender locationInView:_container];
    if(![_container.layer containsPoint:point]) {
        [self hideContainerBoard];
    }else {
        switch (sender.view.tag) {
            case EMOTION_TAG:
                [_emotionBtn setSelected:!_emotionBtn.selected];
                [_photoBtn setSelected:NO];
                if(_emotionBtn.isSelected) {
                    _editMessageType = EditEmotionMessage;
                    [self setContainerBoardHeight:EmotionSelectorHeight];
                    [self updateContainerFrame];
                    [self updateSelectorFrame:YES];
                    [_textView resignFirstResponder];
                }else {
                    _editMessageType = EditTextMessage;
                    [_textView becomeFirstResponder];
                }
                
                break;
            case PHOTO_TAG: {
                __weak __typeof(self) wself = self;
                [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                    if(PHAuthorizationStatusAuthorized == status) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [wself.photoBtn setSelected:!wself.photoBtn.selected];
                            [wself.emotionBtn setSelected:NO];
                            if(wself.photoBtn.isSelected) {
                                wself.editMessageType = EditPhotoMessage;
                                [wself setContainerBoardHeight:PhotoSelectorHeight];
                                [wself updateContainerFrame];
                                [wself updateSelectorFrame:YES];
                                [wself.textView resignFirstResponder];
                            }else {
                                [wself hideContainerBoard];
                            }
                        });
                    }else {
                        [UIWindow showTips:@"请在设置中开启图库读取权限"];
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                        });
                    }
                }];
                break;
            }
            default:
                break;
        }
    }
}

//删除
- (void)onDelete {
    [_textView deleteBackward];
}

//添加表情
- (void)onSelect:(NSString *)emotionKey {
    NSInteger location = _textView.selectedRange.location;
    [_textView setAttributedText:[EmotionHelper insertEmotion:_textView.attributedText index:location emotionKey:emotionKey]];
    [_textView setSelectedRange:NSMakeRange(location + 1, 0)];
    _textHeight = [_textView.attributedText multiLineSize:SCREEN_WIDTH - LEFT_INSET - RIGHT_INSET].height;
    [self updateContainerFrame];
    [self updateSelectorFrame:NO];
}

//发送文字
- (void)onSend {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:_textView.attributedText];
    NSAttributedString *text = [EmotionHelper emotionToString:attributedString];
    if(_delegate) {
        if([_textView hasText]) {
            [self.delegate onSendText:text.string];
            [_textView setText:@""];
            _textHeight = ceilf(_textView.font.lineHeight);
            [self updateContainerFrame];
            [self updateSelectorFrame:NO];
        }else {
            [self hideContainerBoard];
            [UIWindow showTips:@"请输入文字"];
        }
    }
}

//发送图片
- (void)onSend:(NSMutableArray<UIImage *> *)selectedImages {
    if(_delegate) {
        [_delegate onSendImages:selectedImages];
    }
}

//隐藏编辑板
- (void)hideContainerBoard {
    _editMessageType = EditNoneMessage;
    [self setContainerBoardHeight:0];
    [self updateContainerFrame];
    [_textView resignFirstResponder];
    [_emotionBtn setSelected:NO];
    [_photoBtn setSelected:NO];
}

//update method
- (void)show {
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    [window addSubview:self];
}

- (void)dismiss {
    [self removeFromSuperview];
}

- (void)dealloc {
    [emotionSelector removeTextViewObserver:_textView];
    [self removeObserver:self forKeyPath:@"containerBoardHeight"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
