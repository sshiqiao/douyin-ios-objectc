//
//  PhotoSelector.h
//  Douyin
//
//  Created by Qiao Shi on 2018/7/30.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

#define PhotoSelectorHeight   220 + SafeAreaBottomHeight

@protocol PhotoSelectorDelegate
@required
-(void)onSend:(NSMutableArray<UIImage *> *)images;
@end

@interface PhotoSelector : UIView
@property (nonatomic, strong) UIView                   *container;
@property (nonatomic, strong) UICollectionView         *collectionView;
@property (nonatomic, weak) id<PhotoSelectorDelegate>  delegate;
@end

typedef void (^OnSelect)(BOOL isSelected);

@interface PhotoCell:UICollectionViewCell
@property (nonatomic, strong) UIImageView             *photo;
@property (nonatomic, strong) UIButton                *checkbox;
@property (nonatomic, strong) CALayer                 *coverLayer;
@property (nonatomic, strong) OnSelect                onSelect;
- (void)initData:(PHAsset *)asset isSelected:(BOOL)selected;
- (void)setOnSelect:(OnSelect)onSelect;
@end
