//
//  UIWindow+Extension.h
//  Douyin
//
//  Created by Qiao Shi on 2018/7/30.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

#import <UIKit/UIKit.h>

static char tipsKey;
static char tapKey;

@interface UIWindow (Extension)

+(void)showTips:(NSString *)text;

@end
