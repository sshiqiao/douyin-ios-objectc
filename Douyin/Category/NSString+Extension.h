//
//  NSString+Extension.h
//  Douyin
//
//  Created by Qiao Shi on 2018/7/30.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CommonCrypto/CommonDigest.h>
#import <CoreText/CTFramesetter.h>
#import <CoreText/CTFont.h>
#import <CoreText/CTStringAttributes.h>
@interface NSString (Extension)

- (CGSize)singleLineSizeWithAttributeText:(UIFont *)font;

- (CGSize)multiLineSizeWithAttributeText:(CGFloat)width font:(UIFont *)font;

- (CGSize)singleLineSizeWithText:(UIFont *)font;

- (NSString *)md5;

- (NSURL *)urlScheme:(NSString *)scheme;

+ (NSString *)formatCount:(NSInteger)count;

+(NSDictionary *)readJson2DicWithFileName:(NSString *)fileName;

+ (NSString *)currentTime;

@end
