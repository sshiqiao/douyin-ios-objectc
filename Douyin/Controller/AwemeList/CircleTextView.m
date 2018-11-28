//
//  CircleTextView.m
//  Douyin
//
//  Created by Qiao Shi on 2018/7/30.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

#import "CircleTextView.h"
#import "NSString+Extension.h"

NSString * const kCircleTextViewAnim           = @"CircleAnim";
NSString * const kCircleTextViewSeparateText   = @"   ";

@interface CircleTextView()

@property(nonatomic, strong) CATextLayer   *textLayer;
@property(nonatomic, strong) CAShapeLayer  *maskLayer;
@property(nonatomic, assign) CGFloat       textSeparateWidth;
@property(nonatomic, assign) CGFloat       textWidth;
@property(nonatomic, assign) CGFloat       textHeight;
@property(nonatomic, assign) CGRect        textLayerFrame;
@property(nonatomic, assign) CGFloat       translationX;

@end


@implementation CircleTextView

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        _text = @"";
        _textColor = ColorWhite;
        _font = MediumFont;
        _textSeparateWidth = [kCircleTextViewSeparateText singleLineSizeWithText:_font].width;
        [self initLayer];
    }
    return self;
}

- (void)initLayer {
    _textLayer = [[CATextLayer alloc] init];
    _textLayer.alignmentMode = kCAAlignmentNatural;
    _textLayer.truncationMode = kCATruncationNone;
    _textLayer.wrapped = NO;
    _textLayer.contentsScale = [UIScreen mainScreen].scale;
    [self.layer addSublayer:_textLayer];
    
    _maskLayer = [[CAShapeLayer alloc] init];
    self.layer.mask = _maskLayer;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    _textLayer.frame = CGRectMake(0, self.bounds.size.height/2 - _textLayerFrame.size.height/2, _textLayerFrame.size.width, _textLayerFrame.size.height);
    _maskLayer.frame = self.bounds;
    _maskLayer.path = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
    [CATransaction commit];
}

- (void)drawTextLayer {
    _textLayer.foregroundColor = _textColor.CGColor;
    CFStringRef fontName = (__bridge CFStringRef)_font.fontName;
    CGFontRef fontRef = CGFontCreateWithFontName(fontName);
    _textLayer.font = fontRef;
    _textLayer.fontSize = _font.pointSize;
    CGFontRelease(fontRef);
    _textLayer.string = [NSString stringWithFormat:@"%@%@%@%@%@",_text,kCircleTextViewSeparateText,_text,kCircleTextViewSeparateText,_text];
}

- (void)startAnimation {
    if([_textLayer animationForKey:kCircleTextViewAnim]) {
        [_textLayer removeAnimationForKey:kCircleTextViewAnim];
    }
    CABasicAnimation *animation = [CABasicAnimation animation];
    animation.keyPath = @"transform.translation.x";
    animation.fromValue = @(self.bounds.origin.x);
    animation.toValue = @(self.bounds.origin.x - _translationX);
    animation.duration = _textWidth * 0.035f;
    animation.repeatCount = MAXFLOAT;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [_textLayer addAnimation:animation forKey:kCircleTextViewAnim];
}

#pragma update method
- (void)setText:(NSString *)text {
    _text = text;
    CGSize size = [text singleLineSizeWithAttributeText:_font];
    _textWidth = size.width;
    _textHeight = size.height;
    _textLayerFrame = CGRectMake(0, 0, _textWidth*3 + _textSeparateWidth*2, _textHeight);
    _translationX = _textWidth + _textSeparateWidth;
    [self drawTextLayer];
    [self startAnimation];
}

- (void)setFont:(UIFont *)font {
    _font = font;
    CGSize size = [_text singleLineSizeWithAttributeText:_font];
    _textWidth = size.width;
    _textHeight = size.height;
    _textLayerFrame = CGRectMake(0, 0, _textWidth*3 + _textSeparateWidth*2, _textHeight);
    _translationX = _textWidth + _textSeparateWidth;
    [self drawTextLayer];
    [self startAnimation];
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    _textLayer.foregroundColor = _textColor.CGColor;
}

@end
