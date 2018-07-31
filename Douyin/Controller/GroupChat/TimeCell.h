//
//  TimeCell.h
//  Douyin
//
//  Created by Qiao Shi on 2018/7/30.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "Masonry.h"
#import "GroupChat.h"
@interface TimeCell : UITableViewCell
@property (nonatomic, strong) UITextView      *textView;
-(void)initData:(GroupChat *)chat;
+(CGFloat)cellHeight:(GroupChat *)chat;
@end
