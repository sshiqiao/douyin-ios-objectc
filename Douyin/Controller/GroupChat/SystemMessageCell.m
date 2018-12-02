//
//  SystemMessageCell.m
//  Douyin
//
//  Created by Qiao Shi on 2018/7/30.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

#import "SystemMessageCell.h"
#import "EmotionHelper.h"

static const CGFloat kSystemMsgCornerRadius    = 10;
static const CGFloat kSystemMsgMaxWidth        = 180;
static const CGFloat kSystemMsgPadding         = 8;

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
        _textView.textContainerInset = UIEdgeInsetsMake(kSystemMsgCornerRadius, kSystemMsgCornerRadius, kSystemMsgCornerRadius, kSystemMsgCornerRadius);
        _textView.textContainer.lineFragmentPadding = 0;
        _textView.layer.cornerRadius = kSystemMsgCornerRadius;
        [self addSubview:_textView];
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString: _textView.attributedText];
    CGSize size = [attributedString multiLineSize:kSystemMsgMaxWidth];
    _textView.frame = CGRectMake(ScreenWidth/2 - size.width/2 - kSystemMsgCornerRadius, kSystemMsgPadding*2, size.width + kSystemMsgCornerRadius * 2, size.height + kSystemMsgCornerRadius * 2);
}

-(BOOL)canBecomeFirstResponder{
    return YES;
}

-(void)initData:(GroupChat *)chat {
    _chat = chat;
    _textView.attributedText = chat.cellAttributedString;
}

+(NSDictionary* ) attributes {
    return @{NSFontAttributeName:MediumFont,NSForegroundColorAttributeName:ColorGray};
}

+(CGFloat)cellHeight:(GroupChat *)chat {
    return chat.contentSize.height + kSystemMsgPadding * 2 + kSystemMsgCornerRadius * 2;
}

+ (CGSize)contentSize:(GroupChat *)chat {
    return [chat.cellAttributedString multiLineSize:kSystemMsgMaxWidth];
}

@end
