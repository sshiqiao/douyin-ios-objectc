//
//  NSAttributedString+Extension.m
//  Douyin
//
//  Created by Qiao Shi on 2018/7/30.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

#import "NSAttributedString+Extension.h"

@implementation NSAttributedString (Extension)
//固定宽度计算多行文本高度，支持开头空格、自定义插入的文本图片不纳入计算范围，包含emoji表情符仍然会有较大偏差，但在UITextView和UILabel等控件中不影响显示。
- (CGSize)multiLineSize:(CGFloat)width {
    CGRect rect = [self boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
    return CGSizeMake(ceilf(rect.size.width), ceilf(rect.size.height));
}

@end
