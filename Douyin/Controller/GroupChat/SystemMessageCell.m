//
//  SystemMessageCell.m
//  Douyin
//
//  Created by Qiao Shi on 2018/7/30.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

#import "SystemMessageCell.h"
#import "EmotionHelper.h"

#define SYS_MSG_CORNER_RADIUS      10
#define MAX_SYS_MSG_WIDTH          SCREEN_WIDTH - 110
#define COMMON_MSG_PADDING         8


@implementation SystemMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = ColorClear;
        
        _textView = [[UITextView alloc] init];
        _textView.textColor = [[SystemMessageCell attributes] valueForKey:NSForegroundColorAttributeName];
        _textView.font = [[SystemMessageCell attributes] valueForKey:NSFontAttributeName];
        _textView.scrollEnabled = NO;
        _textView.editable = NO;
        _textView.selectable = NO;
        _textView.backgroundColor = ColorGrayDark;
        _textView.textContainerInset = UIEdgeInsetsMake(SYS_MSG_CORNER_RADIUS, SYS_MSG_CORNER_RADIUS, SYS_MSG_CORNER_RADIUS, SYS_MSG_CORNER_RADIUS);
        _textView.textContainer.lineFragmentPadding = 0;
        _textView.layer.cornerRadius = SYS_MSG_CORNER_RADIUS;
        [self addSubview:_textView];
        
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString: _textView.attributedText];
    CGSize size = [attributedString multiLineSize:MAX_SYS_MSG_WIDTH];
    _textView.frame = CGRectMake(SCREEN_WIDTH/2 - size.width/2 - SYS_MSG_CORNER_RADIUS, COMMON_MSG_PADDING*2, size.width + SYS_MSG_CORNER_RADIUS * 2, size.height + SYS_MSG_CORNER_RADIUS * 2);
}

-(BOOL)canBecomeFirstResponder{
    return YES;
}

-(void)initData:(GroupChat *)chat {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:chat.msg_content];
    [attributedString addAttributes:[SystemMessageCell attributes] range:NSMakeRange(0, attributedString.length)];
    attributedString = [EmotionHelper stringToEmotion:attributedString];
    _textView.attributedText = attributedString;
}

+(NSDictionary* ) attributes {
    return @{NSFontAttributeName:MediumFont,NSForegroundColorAttributeName:ColorGray};
}

+(CGFloat)cellHeight:(GroupChat *)chat {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:chat.msg_content];
    [attributedString addAttributes:[SystemMessageCell attributes] range:NSMakeRange(0, attributedString.length)];
    attributedString = [EmotionHelper stringToEmotion:attributedString];
    CGSize size = [attributedString multiLineSize:MAX_SYS_MSG_WIDTH];
    CGFloat height = size.height + COMMON_MSG_PADDING * 2 + SYS_MSG_CORNER_RADIUS * 2;
    return height;
}

@end
