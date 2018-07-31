//
//  EmotionHelper.h
//  Douyin
//
//  Created by Qiao Shi on 2018/7/30.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSTextAttachment+Emotion.h"

#define EmotionFont [UIFont systemFontOfSize:16.0]

@interface EmotionHelper : NSObject
//获取emotion.json中的以表情图片文件名作为key值、表情对应的文本作为value值的字典dic
+ (NSDictionary *)shareEmotionDictionary;

//获取emotion.json中包含了表情选择器中每一页的表情图片文件名的二维数组array
+ (NSArray *)shareEmotionArray;

//通过正则表达式匹配文本，表情文本转换为NSTextAttachment图片文本，例：[飞吻]→😘
+ (NSMutableAttributedString *)stringToEmotion:(NSAttributedString *)str;

//NSTextAttachment图片文本转换为表情文本，例：😘→[飞吻]
+ (NSAttributedString *) emotionToString:(NSMutableAttributedString *)str;

//通过表情文本value值获取表情图片文件名key值
+ (NSString *)emotionKeyFromValue:(NSString *)value;

//通过表情图片文件名key值获取表情文本value值
+ (NSString *)emotionValueFromKey:(NSString *)key;

//将表情文本插入指定位置
+ (NSAttributedString *)insertEmotion:(NSAttributedString *)str index:(NSInteger)index emotionKey:(NSString *)key;

//通过表情图片文件名key值获取表情icon路径
+(NSString *)emotionIconPath:(NSString *)emotionKey;

//读取项目中的json文件
+(NSDictionary *)readJson2DicWithFileName:(NSString *)fileName;
@end
