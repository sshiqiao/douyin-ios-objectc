//
//  HoverViewFlowLayout.h
//  Douyin
//
//  Created by Qiao Shi on 2018/7/30.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface HoverViewFlowLayout : UICollectionViewFlowLayout
@property (nonatomic, assign) CGFloat navHeight;
- (instancetype)initWithNavHeight:(CGFloat)height;
@end
