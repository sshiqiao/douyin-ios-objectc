//
//  TimeCell.m
//  Douyin
//
//  Created by Qiao Shi on 2018/7/30.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

#import "TimeCell.h"
#import "EmotionHelper.h"

static const CGFloat kTimeMsgCornerRadius    = 10;
static const CGFloat kTimeMsgMaxWidth        = 150;
static const CGFloat kTimeMsgPadding         = 8;

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
        _textView.textContainerInset = UIEdgeInsetsMake(kTimeMsgCornerRadius*2, kTimeMsgCornerRadius, 0, kTimeMsgCornerRadius);
        _textView.textContainer.lineFragmentPadding = 0;
        [self.contentView addSubview:_textView];
        
        [_textView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.bottom.equalTo(self.contentView);
        }];
    }
    return self;
}

-(void)initData:(GroupChat *)chat {
    _chat = chat;
    _textView.attributedText = chat.cellAttributedString;
}

+(NSDictionary* )attributes {
    return @{NSFontAttributeName:SmallFont,NSForegroundColorAttributeName:ColorGray};
}

+(CGFloat)cellHeight:(GroupChat *)chat {
    return chat.contentSize.height + kTimeMsgPadding * 2;
}

+ (CGSize)contentSize:(GroupChat *)chat {
    return [chat.cellAttributedString multiLineSize:kTimeMsgMaxWidth];
}

@end
