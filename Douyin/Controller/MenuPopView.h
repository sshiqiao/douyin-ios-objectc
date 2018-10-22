//
//  MenuPopView.h
//  Douyin
//
//  Created by Qiao Shi on 2018/7/30.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^OnAction)(NSInteger index);

@interface MenuPopView:UIView
@property (nonatomic, strong) UIView        *container;
@property (nonatomic, strong) UIButton      *cancel;
@property (nonatomic, strong) OnAction      onAction;

- (instancetype)initWithTitles:(NSArray *)titles;
- (void)show;
- (void)dismiss;

@end
