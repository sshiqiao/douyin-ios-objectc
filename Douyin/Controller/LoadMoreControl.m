//
//  LoadMoreControl.m
//  Douyin
//
//  Created by Qiao Shi on 2018/7/30.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

#import "LoadMoreControl.h"
#import <objc/message.h>

@interface LoadMoreControl ()

@property (nonatomic, assign) NSInteger  surplusCount;
@property (nonatomic, assign) CGRect     originalFrame;

@end


@implementation LoadMoreControl

- (instancetype)init {
    return [self initWithFrame:CGRectMake(0, 0, ScreenWidth, 50)];
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame surplusCount:0];
}

-(instancetype)initWithFrame:(CGRect)frame surplusCount:(NSInteger)surplusCount {
    self = [super initWithFrame:frame];
    if(self){
        self.layer.zPosition = -1;
        _originalFrame = frame;
        
        _surplusCount = surplusCount;
        
        [self setLoadingType:LoadStateIdle];
        _indicatorView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon30WhiteSmall"]];
        [self addSubview:_indicatorView];
        
        _label = [[UILabel alloc]init];
        _label.text = @"正在加载...";
        _label.textColor = ColorGray;
        _label.font = SmallFont;
        _label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_label];
    }
    return self;
}

-(NSInteger)cellNumInTableView:(UITableView *)tableView {
    NSInteger cellNum = 0;
    for (int section = 0; section < tableView.numberOfSections; section++) {
        NSInteger rowNum =  [tableView numberOfRowsInSection:section];
        cellNum += rowNum;
    }
    return cellNum;
}

-(NSInteger)cellNumInCollectionView:(UICollectionView *)collectionView {
    NSInteger sectionNum = collectionView.numberOfSections;
    NSInteger cellNum = 0;
    for (int section = 0; section < sectionNum; section++) {
        NSInteger itemNum =  [collectionView numberOfItemsInSection:section];
        cellNum += itemNum;
    }
    return cellNum;
}

//kvo
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    __weak __typeof(self) wself = self;
    if([keyPath isEqualToString:@"contentOffset"]){
        dispatch_async(dispatch_get_main_queue(), ^{
            if([wself.superView isKindOfClass:[UITableView class]]) {
                UITableView *tableView = (UITableView *)wself.superView;
                NSInteger lastSection = tableView.numberOfSections - 1;
                if(lastSection >= 0) {
                    NSInteger lastRow = [tableView numberOfRowsInSection:tableView.numberOfSections - 1] - 1;
                    if(lastRow >= 0) {
                        if(tableView.visibleCells.count > 0) {
                            NSIndexPath *indexPath = [tableView indexPathForCell:tableView.visibleCells.lastObject];
                            if(indexPath.section == lastSection && indexPath.row >= (lastRow - wself.surplusCount)) {
                                if(wself.loadingType == LoadStateIdle || wself.loadingType == LoadStateFailed)  {
                                    if(wself.onLoad) {
                                        [wself startLoading];
                                        wself.onLoad();
                                    }
                                }
                            }
                            if(indexPath.section == lastSection && indexPath.row == lastRow) {
                                self.frame = CGRectMake(0, CGRectGetMaxY(tableView.visibleCells.lastObject.frame), ScreenWidth, 50);
                            }
                        }
                    }
                }
            }
            if([wself.superView isKindOfClass:[UICollectionView class]]) {
                UICollectionView *collectionView = (UICollectionView *)wself.superView;
                NSInteger lastSection = collectionView.numberOfSections - 1;
                if(lastSection >= 0) {
                    NSInteger lastRow = [collectionView numberOfItemsInSection:collectionView.numberOfSections - 1] - 1;
                    if(lastRow >= 0) {
                        if(collectionView.indexPathsForVisibleItems.count > 0) {
                            NSArray *indexPaths = [collectionView indexPathsForVisibleItems];
                            NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"row" ascending:YES];
                            NSArray *orderedIndexPaths = [indexPaths sortedArrayUsingDescriptors:@[sort]];
                            NSIndexPath *indexPath = orderedIndexPaths.lastObject;
                            if(indexPath.section == lastSection && indexPath.row >= (lastRow - wself.surplusCount)) {
                                if(wself.loadingType == LoadStateIdle || wself.loadingType == LoadStateFailed)  {
                                    if(wself.onLoad) {
                                        [wself startLoading];
                                        wself.onLoad();
                                    }
                                }
                            }
                            if(indexPath.section == lastSection && indexPath.row == lastRow) {
                                UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
                                self.frame = CGRectMake(0, CGRectGetMaxY(cell.frame), ScreenWidth, 50);
                            }
                        }
                    }
                }
            }
        });
    } else {
        return [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (!_superView) {
        _superView = (UIScrollView *)[self superview];
        [_superView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
        UIEdgeInsets edgeInsets = _superView.contentInset;
        edgeInsets.bottom += (50 + SafeAreaBottomHeight);
        _superView.contentInset = edgeInsets;
    }
}

- (void)setOnLoad:(OnLoad)onLoad {
    _onLoad = onLoad;
}

- (void)reset {
    [self setLoadingType:LoadStateIdle];
    self.frame = _originalFrame;
}

- (void)startLoading {
    if(_loadingType != LoadStateLoading) {
        [self setLoadingType:LoadStateLoading];
    }
}

- (void)endLoading {
    if(_loadingType != LoadStateIdle) {
        [self setLoadingType:LoadStateIdle];
    }
}

- (void)loadingFailed {
    if(_loadingType != LoadStateFailed) {
        [self setLoadingType:LoadStateFailed];
    }
}
- (void)loadingAll {
    if(_loadingType != LoadStateAll) {
        [self setLoadingType:LoadStateAll];
    }
}

- (void)setLoadingType:(LoadingType)loadingType {
    _loadingType = loadingType;
    switch (loadingType) {
        case LoadStateIdle:
            [self setHidden:YES];
            break;
        case LoadStateLoading:{
            [self setHidden:NO];
            [_indicatorView setHidden:NO];
            [_label setText:@"内容加载中..."];
            [_label mas_updateConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self);
                make.centerX.equalTo(self).offset(20);
            }];
            [_indicatorView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self);
                make.right.equalTo(self.label.mas_left).inset(5);
                make.width.height.mas_equalTo(15);
            }];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self startAnim];
            });
            break;
        }
        case LoadStateAll: {
            [self setHidden:NO];
            [_indicatorView setHidden:YES];
            [_label setText:@"没有更多了哦～"];
            [_label mas_updateConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(self);
            }];
            [self stopAnim];
            [self updateFrame];
            break;
        }
        case LoadStateFailed:{
            [self setHidden:NO];
            [_indicatorView setHidden:YES];
            [_label setText:@"加载更多"];
            [_label mas_updateConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(self);
            }];
            [self stopAnim];
            break;
        }
    }
}

- (void)updateFrame {
    if([self.superView isKindOfClass:[UITableView class]]) {
        UITableView *tableView = (UITableView *)self.superView;
        CGFloat y = tableView.contentSize.height > _originalFrame.origin.y ? tableView.contentSize.height : _originalFrame.origin.y;
        self.frame = CGRectMake(0, y, ScreenWidth, 50);
    }
    if([self.superView isKindOfClass:[UICollectionView class]]) {
        UICollectionView *collectionView = (UICollectionView *)self.superView;
        CGFloat y = collectionView.contentSize.height > _originalFrame.origin.y ? collectionView.contentSize.height : _originalFrame.origin.y;
        self.frame = CGRectMake(0, y, ScreenWidth, 50);
    }
}

- (void)startAnim {
    CABasicAnimation* rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0];
    rotationAnimation.duration = 1.5;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = MAXFLOAT;
    [self.indicatorView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

- (void)stopAnim {
    [self.indicatorView.layer removeAllAnimations];
}

- (void)dealloc {
    [_superView removeObserver:self forKeyPath:@"contentOffset"];
}

@end
