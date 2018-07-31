//
//  TextMessageCell.h
//  Douyin
//
//  Created by Qiao Shi on 2018/7/30.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "Masonry.h"
#import "GroupChat.h"

typedef void (^OnMenuAction)(MenuActionType actionType);

@interface TextMessageCell : UITableViewCell
@property (nonatomic, strong) UIImageView             *avatar;
@property (nonatomic, strong) UITextView              *textView;
@property (nonatomic, strong) CAShapeLayer            *backgroundlayer;
@property (nonatomic, strong) UIImageView             *indicatorView;
@property (nonatomic, strong) UIImageView             *tipIcon;
@property (nonatomic, strong) GroupChat               *chat;
@property (nonatomic, strong) OnMenuAction             onMenuAction;
-(void)initData:(GroupChat *)chat;
- (CGRect)menuFrame;
+(CGFloat)cellHeight:(GroupChat *)chat;
@end
