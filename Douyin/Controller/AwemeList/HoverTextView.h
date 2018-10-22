//
//  HoverTextView.h
//  Douyin
//
//  Created by Qiao Shi on 2018/7/30.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SendTextDelegate

@required
-(void)onSendText:(NSString *)text;

@end



@protocol HoverTextViewDelegate

@required
-(void) hoverTextViewStateChange:(BOOL)isHover;

@end



@interface HoverTextView : UIView

@property (nonatomic, strong) UITextView                     *textView;
@property (nonatomic, weak) id<SendTextDelegate>             delegate;
@property (nonatomic, weak) id<HoverTextViewDelegate>        hoverDelegate;

@end

