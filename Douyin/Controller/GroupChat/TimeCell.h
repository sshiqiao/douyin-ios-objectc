//
//  TimeCell.h
//  Douyin
//
//  Created by Qiao Shi on 2018/7/30.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

#import "BaseMessageCell.h"

@interface TimeCell : BaseMessageCell

@property (nonatomic, strong) UITextView      *textView;
@property (nonatomic, strong) GroupChat       *chat;

-(void)initData:(GroupChat *)chat;

@end
