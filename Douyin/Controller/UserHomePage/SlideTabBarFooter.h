//
//  SlideTabBarFooter.h
//  Douyin
//
//  Created by Qiao Shi on 2018/7/30.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OnTabTapActionDelegate
- (void)onTabTapAction:(NSInteger)index;
@end

@interface SlideTabBarFooter : UICollectionReusableView
@property (nonatomic, weak) id <OnTabTapActionDelegate> delegate;
- (void)setLabels:(NSArray<NSString *> *)titles tabIndex:(NSInteger)tabIndex;

@end
