//
//  PhotoSelector.m
//  Douyin
//
//  Created by Qiao Shi on 2018/7/30.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

#import "PhotoSelector.h"

NSString * const kPhotoCell = @"PhotoCell";

static const NSInteger kPhotoSelectorAlbumTag      = 0x01;
static const NSInteger kPhotoSelectorOrigPhotoTag  = 0x02;
static const NSInteger kPhotoSelectorSendTag       = 0x03;

static const CGFloat kPhotoSelectorItemHeight      = 170;

@interface PhotoSelector () <UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) NSMutableArray<PHAsset *>       *data;
@property (nonatomic, strong) NSMutableArray<PHAsset *>       *selectedData;
@property (nonatomic, strong) UIView                          *bottomView;
@property (nonatomic, strong) UIButton                        *album;
@property (nonatomic, strong) UIButton                        *originalPhoto;
@property (nonatomic, strong) UIButton                        *send;
@end

@implementation PhotoSelector
-(instancetype)init {
    return [self initWithFrame:CGRectMake(0, 0, ScreenWidth, PhotoSelectorHeight)];
}

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        self.backgroundColor = ColorSmoke;
        self.clipsToBounds = NO;
        _data = [NSMutableArray array];
        _selectedData = [NSMutableArray array];
        
        PHFetchOptions *options = [[PHFetchOptions alloc] init];
        [options setSortDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"creationDate" ascending:NO]]];
        PHFetchResult<PHAsset *> *result = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:options];
        [result enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.data addObject:obj];
            [self.collectionView reloadData];
        }];
        UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 2.5;
        _collectionView = [[UICollectionView  alloc]initWithFrame:CGRectMake(0, 2.5, ScreenWidth, kPhotoSelectorItemHeight) collectionViewLayout:layout];
        _collectionView.clipsToBounds = NO;
        _collectionView.backgroundColor = ColorClear;
        _collectionView.alwaysBounceHorizontal = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[PhotoCell class] forCellWithReuseIdentifier:kPhotoCell];
        [self addSubview:_collectionView];
        
        
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_collectionView.frame) + 2.5, ScreenWidth, 45 + SafeAreaBottomHeight)];
        _bottomView.backgroundColor = ColorWhite;
        [self addSubview:_bottomView];
        
        
        _album = [[UIButton alloc] initWithFrame:CGRectMake(15, 10, 40, 25)];
        _album.tag = kPhotoSelectorAlbumTag;
        _album.titleLabel.font = BigFont;
        [_album setTitle:@"相册" forState:UIControlStateNormal];
        [_album setTitleColor:ColorThemeRed forState:UIControlStateNormal];
        [_album addTarget:self action:@selector(onButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:_album];
        
        
        _originalPhoto = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_album.frame) + 10, 10, 60, 25)];
        _originalPhoto.tag = kPhotoSelectorOrigPhotoTag;
        [_originalPhoto setTitleEdgeInsets:UIEdgeInsetsMake(0, 2, 0, 0)];
        _originalPhoto.titleLabel.font = BigFont;
        [_originalPhoto setTitle:@"原图" forState:UIControlStateNormal];
        [_originalPhoto setTitleColor:ColorThemeRed forState:UIControlStateNormal];
        [_originalPhoto setImage:[UIImage imageNamed:@"radio_button_unchecked_white"] forState:UIControlStateNormal];
        [_originalPhoto setImage:[UIImage imageNamed:@"radio_button_checked_red"] forState:UIControlStateSelected];
        [_originalPhoto setImageEdgeInsets:UIEdgeInsetsMake(0, -2, 0, 0)];
        [_originalPhoto addTarget:self action:@selector(onButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:_originalPhoto];
        
        _send = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth - 60 - 15, 10, 60, 25)];
        _send.tag = kPhotoSelectorSendTag;
        _send.enabled = NO;
        _send.backgroundColor = ColorSmoke;
        _send.layer.cornerRadius = 2;
        _send.titleLabel.font = MediumFont;
        [_send setTitle:@"发送" forState:UIControlStateNormal];
        [_send setTitleColor:ColorWhite forState:UIControlStateNormal];
        [_send addTarget:self action:@selector(onButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:_send];
    }
    return self;
}

-(void)onButtonClick:(UIButton *)sender {
    switch (sender.tag) {
        case kPhotoSelectorAlbumTag:
            break;
        case kPhotoSelectorOrigPhotoTag:
            [_originalPhoto setSelected:!_originalPhoto.isSelected];
            break;
        case kPhotoSelectorSendTag:
            [self processAssets];
            break;
        default:
            break;
    }
}

-(void)processAssets {
    if(_selectedData.count > 9) {
        [UIWindow showTips:@"最多选择9张图片"];
        return;
    }
    if(_delegate) {
        PHImageManager *manager = [PHImageManager defaultManager];
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        [options setNetworkAccessAllowed:YES];
        [options setSynchronous:YES];
        NSMutableArray<UIImage *> *images = [NSMutableArray array];
        for(PHAsset *asset in _selectedData) {
            CGFloat imageHeight = _originalPhoto.isSelected ? asset.pixelHeight : (asset.pixelHeight > 1000 ? 1000 : asset.pixelHeight);
            [manager requestImageForAsset:asset targetSize:CGSizeMake(imageHeight*((CGFloat)asset.pixelWidth/(CGFloat)asset.pixelHeight), imageHeight) contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                if (result != nil) {
                    [images addObject:result];
                }
                if(images.count == self.selectedData.count) {
                    [self.delegate onSend:images];
                    [self.selectedData removeAllObjects];
                    [self.collectionView reloadData];
                }
            }];
        }
    }
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _data.count > 50 ? 50 : _data.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kPhotoCell forIndexPath:indexPath];
    PHAsset *asset = [_data objectAtIndex:indexPath.row];
    [cell initData:asset isSelected:[_selectedData containsObject:asset]];
    [cell setOnSelect:^(BOOL isSelected) {
        if(isSelected) {
            [self.selectedData addObject:asset];
        }else {
            [self.selectedData removeObject:asset];
        }
        if(self.selectedData.count > 0) {
            self.send.enabled = YES;
            [self.send setBackgroundColor:ColorThemeRed];
        }else {
            self.send.enabled = NO;
            [self.send setBackgroundColor:ColorSmoke];
        }
    }];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    PHAsset *asset = _data[indexPath.row];
    return CGSizeMake(kPhotoSelectorItemHeight*((CGFloat)asset.pixelWidth/(CGFloat)asset.pixelHeight), kPhotoSelectorItemHeight);
}

@end

#pragma Photo Cell
@implementation PhotoCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self){
        self.clipsToBounds = YES;
        _photo = [[UIImageView alloc] init];
        _photo.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:_photo];
        
        _coverLayer = [CALayer new];
        _coverLayer.backgroundColor = ColorBlackAlpha60.CGColor;
        [_coverLayer setHidden:YES];
        [_photo.layer addSublayer:_coverLayer];
        
        _checkbox = [[UIButton alloc] init];
        [_checkbox setImage:[UIImage imageNamed:@"radio_button_unchecked_white"] forState:UIControlStateNormal];
        [_checkbox setImage:[UIImage imageNamed:@"check_circle_white"] forState:UIControlStateSelected];
        [_checkbox addTarget:self action:@selector(selectCheckbox) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_checkbox];
    }
    return self;
}
- (void)prepareForReuse {
    [super prepareForReuse];
    _photo.image = nil;
    [_coverLayer setHidden:YES];
    [_checkbox setSelected:NO];
    _photo.transform = CGAffineTransformIdentity;
}
-(void)layoutSubviews {
    [super layoutSubviews];
    _photo.frame = self.bounds;
    _photo.transform = _checkbox.isSelected ? CGAffineTransformMakeScale(1.1f, 1.1f) : CGAffineTransformIdentity;
    _checkbox.frame = CGRectMake(self.bounds.size.width - 30, 0, 30, 30);
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    _coverLayer.frame = _photo.bounds;
    [CATransaction commit];
    
}

- (void)initData:(PHAsset *)asset isSelected:(BOOL)selected {
    PHImageManager *manager = [PHImageManager defaultManager];
    if (self.tag != 0) {
        [manager cancelImageRequest:(PHImageRequestID)self.tag];
    }
    self.tag = [manager requestImageForAsset:asset targetSize:CGSizeMake(kPhotoSelectorItemHeight*((CGFloat)asset.pixelWidth/(CGFloat)asset.pixelHeight), kPhotoSelectorItemHeight) contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        self.photo.image = result;
    }];
    [_checkbox setSelected:selected];
    [_coverLayer setHidden:!_checkbox.isSelected];
}


- (void)selectCheckbox {
    [_checkbox setSelected:!_checkbox.isSelected];
    [_coverLayer setHidden:!_checkbox.isSelected];
    
    [UIView animateWithDuration:0.25f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.photo.transform = self.checkbox.isSelected ? CGAffineTransformMakeScale(1.1f, 1.1f) : CGAffineTransformIdentity;
                     } completion:^(BOOL finished) {
                     }];
    
    if(_onSelect) {
        _onSelect(_checkbox.isSelected);
    }
}

- (void)setOnSelect:(OnSelect)onSelect {
    _onSelect = onSelect;
}

@end
