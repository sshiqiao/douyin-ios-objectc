//
//  ScaleDismissAnimation.h
//  Douyin
//
//  Created by Qiao Shi on 2018/7/30.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UserHomePageController.h"
#import "AwemeListController.h"
#import "AwemeCollectionCell.h"

@interface ScaleDismissAnimation : NSObject<UIViewControllerAnimatedTransitioning>
@property (nonatomic, assign) CGRect centerFrame;
@end
