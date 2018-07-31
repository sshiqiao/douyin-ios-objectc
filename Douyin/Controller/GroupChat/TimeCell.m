//
//  TimeCell.m
//  Douyin
//
//  Created by Qiao Shi on 2018/7/30.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

#import "TimeCell.h"
#import "EmotionHelper.h"

#define SYS_MSG_CORNER_RADIUS      10
#define MAX_SYS_MSG_WIDTH          SCREEN_WIDTH - 110
#define COMMON_MSG_PADDING         8

@implementation TimeCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = ColorClear;
        _textView = [[UITextView alloc] init];
        _textView.textColor = [[TimeCell attributes] valueForKey:NSForegroundColorAttributeName];
        _textView.font = [[TimeCell attributes] valueForKey:NSFontAttributeName];
        _textView.scrollEnabled = NO;
        _textView.editable = NO;
        _textView.backgroundColor = ColorClear;
        _textView.textContainerInset = UIEdgeInsetsMake(SYS_MSG_CORNER_RADIUS*2, SYS_MSG_CORNER_RADIUS, 0, SYS_MSG_CORNER_RADIUS);
        _textView.textContainer.lineFragmentPadding = 0;
        [self addSubview:_textView];
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    [_textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.bottom.equalTo(self);
    }];
}

-(void)initData:(GroupChat *)chat {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:chat.msg_content];
    [attributedString addAttributes:[TimeCell attributes] range:NSMakeRange(0, attributedString.length)];
    attributedString = [EmotionHelper stringToEmotion:attributedString];
    _textView.attributedText = attributedString;
}

+(NSDictionary* ) attributes {
    return @{NSFontAttributeName:SmallFont,NSForegroundColorAttributeName:ColorGray};
}

+(CGFloat)cellHeight:(GroupChat *)chat {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:chat.msg_content];
    [attributedString addAttributes:[TimeCell attributes] range:NSMakeRange(0, attributedString.length)];
    attributedString = [EmotionHelper stringToEmotion:attributedString];
    CGSize size = [attributedString multiLineSize:MAX_SYS_MSG_WIDTH];
    return size.height + COMMON_MSG_PADDING * 2;
}
@end
