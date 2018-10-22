//
//  NSDate+Extension.m
//  Douyin
//
//  Created by Qiao Shi on 2018/7/30.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

#import "NSDate+Extension.h"

@implementation NSDate (Extension)

+ (NSString *)formatTime:(NSTimeInterval)timeInterval {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    if ([date isToday]) {
        if([date isJustNow]) {
            return @"刚刚";
        }else {
            formatter.dateFormat = @"HH:mm";
            return [formatter stringFromDate:date];
        }
    }else{
        if ([date isYesterday]) {
            formatter.dateFormat = @"昨天HH:mm";
            return [formatter stringFromDate:date];
        }else if ([date isCurrentWeek]){
            formatter.dateFormat = [NSString stringWithFormat:@"%@%@",[date dateToWeekday],@"HH:mm"];
            return [formatter stringFromDate:date];
        }else{
            if([date isCurrentYear]) {
                formatter.dateFormat = @"MM-dd  HH:mm";
            }else {
                formatter.dateFormat = @"yy-MM-dd  HH:mm";
            }
            return [formatter stringFromDate:date];
        }
    }
    return nil;
}

- (BOOL)isJustNow {
    NSTimeInterval now = [[NSDate new] timeIntervalSince1970];
    return fabs(now - self.timeIntervalSince1970) < 60 * 2 ? YES : NO;
}

- (BOOL)isCurrentWeek {
    NSDate *nowDate = [[NSDate date] dateFormatYMD];
    NSDate *selfDate = [self dateFormatYMD];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *cmps = [calendar components:NSCalendarUnitDay fromDate:selfDate toDate:nowDate options:0];
    return cmps.day <= 7;
}

- (BOOL)isCurrentYear {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    int unit = NSCalendarUnitWeekday | NSCalendarUnitMonth | NSCalendarUnitYear;
    NSDateComponents *nowComponents = [calendar components:unit fromDate:[NSDate date]];
    NSDateComponents *selfComponents = [calendar components:unit fromDate:self];
    return selfComponents.year == nowComponents.year;
}

- (NSString *)dateToWeekday {
    NSArray *weekdays = [NSArray arrayWithObjects: @"", @"星期天", @"星期一", @"星期二", @"星期三", @"星期四", @"星期五", @"星期六", nil];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSTimeZone *timeZone = [[NSTimeZone alloc] initWithName:@"Asia/Shanghai"];
    [calendar setTimeZone: timeZone];
    NSCalendarUnit calendarUnit = NSCalendarUnitWeekday;
    NSDateComponents *theComponents = [calendar components:calendarUnit fromDate:self];
    return [weekdays objectAtIndex:theComponents.weekday];
    
}

- (BOOL)isToday {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    int unit = NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear ;
    NSDateComponents *nowComponents = [calendar components:unit fromDate:[NSDate date]];
    NSDateComponents *selfComponents = [calendar components:unit fromDate:self];
    return (selfComponents.year == nowComponents.year) && (selfComponents.month == nowComponents.month) && (selfComponents.day == nowComponents.day);
}

- (BOOL)isYesterday {
    NSDate *nowDate = [[NSDate date] dateFormatYMD];
    NSDate *selfDate = [self dateFormatYMD];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *cmps = [calendar components:NSCalendarUnitDay fromDate:selfDate toDate:nowDate options:0];
    return cmps.day == 1;
}

- (NSDate *)dateFormatYMD {
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyyy-MM-dd";
    NSString *selfStr = [fmt stringFromDate:self];
    return [fmt dateFromString:selfStr];
}

@end
