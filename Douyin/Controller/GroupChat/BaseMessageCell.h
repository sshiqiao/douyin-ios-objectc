//
//  BaseMessageCell.h
//  Douyin
//
//  Created by Qiao Shi on 2018/10/21.
//  Copyright © 2018 Qiao Shi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GroupChat.h"

typedef NS_ENUM(NSUInteger,MenuActionType) {
    DeleteAction,
    CopyAction,
    PasteAction
};

typedef void (^OnMenuAction)(MenuActionType actionType);

@interface BaseMessageCell : UITableViewCell

+ (NSDictionary* )attributes;
+ (NSMutableAttributedString *)cellAttributedString:(GroupChat *)chat;
+ (CGSize)contentSize:(GroupChat *)chat;
+ (CGFloat)cellHeight:(GroupChat *)chat;

@end
