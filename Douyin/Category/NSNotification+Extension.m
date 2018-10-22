//
//  NSNotification+Extension.m
//  Douyin
//
//  Created by Qiao Shi on 2018/7/30.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

#import "NSNotification+Extension.h"

@implementation NSNotification (Extension)

- (CGFloat)keyBoardHeight {
    NSDictionary *userInfo = [self userInfo];
    CGSize size = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    return UIInterfaceOrientationIsLandscape(orientation) ? size.width : size.height;
}

@end
