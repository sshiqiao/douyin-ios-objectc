//
//  HoverViewFlowLayout.m
//  Douyin
//
//  Created by Qiao Shi on 2018/7/30.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

#import "HoverViewFlowLayout.h"

@implementation HoverViewFlowLayout
- (instancetype)initWithNavHeight:(CGFloat)height{
    self = [super init];
    if (self){
        self.navHeight = height;
    }
    return self;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect{
    NSMutableArray<UICollectionViewLayoutAttributes *> *superArray = [[super layoutAttributesForElementsInRect:rect] mutableCopy];
    for (UICollectionViewLayoutAttributes *attributes in [superArray mutableCopy]) {
        if ([attributes.representedElementKind isEqualToString:UICollectionElementKindSectionHeader]
            || [attributes.representedElementKind isEqualToString:UICollectionElementKindSectionFooter]) {
            [superArray removeObject:attributes];
        }
    }
    
    [superArray addObject:[super layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]]];
    [superArray addObject:[super layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter atIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]]];
    
    for (UICollectionViewLayoutAttributes *attributes in superArray) {
        
        if(attributes.indexPath.section == 0) {
            
            if ([attributes.representedElementKind isEqualToString:UICollectionElementKindSectionHeader]){
                CGRect rect = attributes.frame;
                if(self.collectionView.contentOffset.y + self.navHeight - rect.size.height > rect.origin.y) {
                    rect.origin.y =  self.collectionView.contentOffset.y + self.navHeight - rect.size.height;
                    attributes.frame = rect;
                }
                attributes.zIndex = 5;
            }
            
            if ([attributes.representedElementKind isEqualToString:UICollectionElementKindSectionFooter]){
                CGRect rect = attributes.frame;
                if(self.collectionView.contentOffset.y + self.navHeight > rect.origin.y) {
                    rect.origin.y =  self.collectionView.contentOffset.y + self.navHeight;
                    attributes.frame = rect;
                }
                attributes.zIndex = 10;
            }
        }
        
    }
    return [superArray copy];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBound {
    return YES;
}

@end
