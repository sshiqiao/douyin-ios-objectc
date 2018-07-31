//
//  ImageMessageCell.h
//  Douyin
//
//  Created by Qiao Shi on 2018/7/30.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "Masonry.h"
#import "GroupChat.h"
#import "CircleProgressView.h"

typedef void (^OnMenuAction)(MenuActionType actionType);

@interface ImageMessageCell : UITableViewCell
@property (nonatomic, strong) UIImageView              *avatar;
@property (nonatomic, strong) UIImageView              *imageMsg;
@property (nonatomic, strong) CircleProgressView       *progressView;
@property (nonatomic, strong) GroupChat                *chat;
@property (nonatomic, strong) OnMenuAction             onMenuAction;
-(void)initData:(GroupChat *)chat;
- (CGRect)menuFrame;
+(CGFloat)cellHeight:(GroupChat *)chat;
@end
