//
//  EmotionHelper.m
//  Douyin
//
//  Created by Qiao Shi on 2018/7/30.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

#import "EmotionHelper.h"
@implementation EmotionHelper
//获取emotion.json中的以表情图片文件名作为key值、表情对应的文本作为value值的字典dic
+ (NSDictionary *)shareEmotionDictionary {
    static dispatch_once_t once;
    static NSDictionary *dictionary;
    dispatch_once(&once, ^{
        dictionary = [[EmotionHelper readJson2DicWithFileName:@"emotion"] objectForKey:@"dict"];
    });
    return dictionary;
}
//获取emotion.json中包含了表情选择器中每一页的表情图片文件名的二维数组array
+ (NSArray *)shareEmotionArray {
    static dispatch_once_t once;
    static NSArray *array;
    dispatch_once(&once, ^{
        array = [[EmotionHelper readJson2DicWithFileName:@"emotion"] objectForKey:@"array"];
    });
    return array;
}

//通过正则表达式匹配文本，表情文本转换为NSTextAttachment图片文本，例：[飞吻]→😘
+ (NSMutableAttributedString *)stringToEmotion:(NSAttributedString *)str {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:str];
    NSString *pattern = @"\\[.*?\\]";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
    NSArray *matches = [regex matchesInString:str.string options:0 range:NSMakeRange(0, str.length)];
    
    NSInteger lengthOffset = 0;
    for (NSTextCheckingResult* match in matches) {
        NSRange range = match.range;
        NSString *emotionValue = [str.string substringWithRange:range];
        NSString *emotionKey = [EmotionHelper emotionKeyFromValue:emotionValue];
        if(!emotionKey) {
            continue;
        }
        NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
        NSString *emotionPath = [EmotionHelper emotionIconPath:emotionKey];
        
        UIGraphicsBeginImageContext(CGSizeMake(30, 30));
        [[UIImage imageWithContentsOfFile:emotionPath] drawInRect:CGRectMake(0.0, 0.0, 30, 30)];
        UIImage *emotionImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        attachment.image = emotionImage;
        attachment.bounds = CGRectMake(0, EmotionFont.descender, EmotionFont.lineHeight, EmotionFont.lineHeight/(attachment.image.size.width/attachment.image.size.height));
        NSAttributedString *matchStr = [NSAttributedString attributedStringWithAttachment:attachment];
        NSMutableAttributedString *emotionStr = [[NSMutableAttributedString alloc] initWithAttributedString:matchStr];
        [emotionStr addAttribute:NSFontAttributeName value:EmotionFont range:NSMakeRange(0, 1)];
        [attributedString replaceCharactersInRange:NSMakeRange(range.location-lengthOffset, range.length) withAttributedString:emotionStr];
        lengthOffset += range.length - 1;
    }
    return attributedString;
}

//NSTextAttachment图片文本转换为表情文本，例：😘→[飞吻]
+ (NSAttributedString *) emotionToString:(NSMutableAttributedString *)str {
    [str enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, str.length) options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
        NSTextAttachment *attachment = (NSTextAttachment *)value;
        if(attachment){
            NSString *emotionKey = [attachment emotionKey];
            if(emotionKey) {
                NSString *emtionValue = [self emotionValueFromKey:emotionKey];
                [str replaceCharactersInRange:range withString:emtionValue];
            }
        }
    }];
    return str;
}

//通过表情文本value值获取表情图片文件名key值
+ (NSString *)emotionKeyFromValue:(NSString *)value {
    NSDictionary *emotionDic = [EmotionHelper shareEmotionDictionary];
    NSString *emotionKey = nil;
    for(NSString *key in emotionDic.allKeys) {
        if([[emotionDic objectForKey:key] isEqualToString:value]) {
            emotionKey = key;
            break;
        }
    }
    return emotionKey;
}

//通过表情图片文件名key值获取表情文本value值
+ (NSString *)emotionValueFromKey:(NSString *)key {
    NSDictionary *emotionDic = [EmotionHelper shareEmotionDictionary];
    return [emotionDic objectForKey:key];
}

//将表情文本插入指定位置
+ (NSAttributedString *)insertEmotion:(NSAttributedString *)str index:(NSInteger)index emotionKey:(NSString *)key {
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    [attachment setEmotionKey:key];
    
    NSString *emotionPath = [EmotionHelper emotionIconPath:key];
    attachment.image = [UIImage imageWithContentsOfFile:emotionPath];
    attachment.bounds = CGRectMake(0, EmotionFont.descender,EmotionFont.lineHeight, EmotionFont.lineHeight/(attachment.image.size.width/attachment.image.size.height));
    NSAttributedString *matchStr = [NSAttributedString attributedStringWithAttachment:attachment];
    NSMutableAttributedString *emotionStr = [[NSMutableAttributedString alloc] initWithAttributedString:matchStr];
    [emotionStr addAttribute:NSFontAttributeName value:EmotionFont range:NSMakeRange(0, emotionStr.length)];
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithAttributedString:str];
    
    [attrStr replaceCharactersInRange:NSMakeRange(index, 0) withAttributedString:emotionStr];
    return attrStr;
}

//通过表情图片文件名key值获取表情icon路径
+(NSString *)emotionIconPath:(NSString *)emotionKey {
    NSString *emoticonsPath = [[NSBundle mainBundle]pathForResource:@"Emoticons"ofType:@"bundle"];
    NSString *emotionPath = [emoticonsPath stringByAppendingPathComponent:emotionKey];
    return emotionPath;
}

//读取项目中的json文件
+(NSDictionary *)readJson2DicWithFileName:(NSString *)fileName {
    NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:@"json"];
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    return dic;
}

@end

