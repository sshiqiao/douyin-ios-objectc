//
//  AwemeListController.h
//  Douyin
//
//  Created by Qiao Shi on 2018/7/30.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

#import "BaseViewController.h"

typedef NS_ENUM(NSUInteger, AwemeType) {
    AwemeWork        = 0,
    AwemeFavorite    = 1
};

@class Aweme;
@interface AwemeListController : BaseViewController

@property (nonatomic, strong) UITableView                       *tableView;
@property (nonatomic, assign) NSInteger                         currentIndex;

-(instancetype)initWithVideoData:(NSMutableArray<Aweme *> *)data currentIndex:(NSInteger)currentIndex pageIndex:(NSInteger)pageIndex pageSize:(NSInteger)pageSize awemeType:(AwemeType)type uid:(NSString *)uid;

@end
