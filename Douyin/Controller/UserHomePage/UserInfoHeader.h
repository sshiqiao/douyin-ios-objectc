//
//  UserInfoHeader.h
//  Douyin
//
//  Created by Qiao Shi on 2018/7/30.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "Masonry.h"
#import "User.h"

#define AVATAE_TAG          1000
#define SEND_MESSAGE_TAG    2000
#define FOCUS_TAG           3000
#define FOCUS_CANCEL_TAG    4000
#define SETTING_TAG         5000
#define GITHUB_TAG          6000

@protocol UserInfoDelegate
- (void)onUserActionTap:(NSInteger)tag;
@end

@interface UserInfoHeader : UICollectionReusableView

@property (nonatomic, weak)   id <UserInfoDelegate>        delegate;
@property (nonatomic, assign) BOOL                         isFollowed;

@property (nonatomic, strong) UIImageView                  *avatar;
@property (nonatomic, strong) UIImageView                  *avatarBackground;

@property (nonatomic, strong) UILabel                      *sendMessage;
@property (nonatomic, strong) UIImageView                  *focusIcon;
@property (nonatomic, strong) UIImageView                  *settingIcon;
@property (nonatomic, strong) UIButton                     *focusButton;

@property (nonatomic, strong) UILabel                      *nickName;
@property (nonatomic, strong) UILabel                      *douyinNum;
@property (nonatomic, strong) UIButton                     *github;
@property (nonatomic, strong) UILabel                      *brief;
@property (nonatomic, strong) UIImageView                  *genderIcon;
@property (nonatomic, strong) UITextView                   *constellation;
@property (nonatomic, strong) UILabel                      *likeNum;
@property (nonatomic, strong) UILabel                      *followNum;
@property (nonatomic, strong) UILabel                      *followedNum;

- (void)initData:(User *)user;
- (void)overScrollAction:(CGFloat) offsetY;
- (void)scrollToTopAction:(CGFloat) offsetY;
- (void)startFocusAnimation;
@end
