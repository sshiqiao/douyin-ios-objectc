//
//  Visitor.m
//  Douyin
//
//  Created by Qiao Shi on 2018/7/30.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

#import "Visitor.h"
@implementation Visitor
-(NSString *)formatUDID {
    if(_udid.length < 8) return @"************";
    NSMutableString *udid = [[NSMutableString alloc] initWithString:_udid];
    [udid replaceCharactersInRange:NSMakeRange(4, udid.length-8) withString:@"****"];
    return udid;
}
@end
