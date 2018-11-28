//
//  WebPImage.m
//  Douyin
//
//  Created by Qiao Shi on 2018/7/30.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

#import "WebPImage.h"

@implementation WebPFrame

@end


@implementation WebPImage

- (instancetype)initWithData:(NSData *)data {
    self = [super init];
    _imageData = data;
    
    _curDisplayIndex = 0;
    
    _curDecodeIndex = 0;
    
    _frameCount = -1;
    
    _frames = [NSMutableArray array];
    
    [self decodeWebPFramesInfo:_imageData];
    
    return self;
}

- (WebPFrame *)curDisplayFrame {
    if(_frames.count > 0) {
        _curDisplayIndex = _curDisplayIndex % _frames.count;
        return _frames[_curDisplayIndex];
    }
    return nil;
}

-(UIImage *)curDisplayImage {
    if(_frames.count > 0) {
        _curDisplayIndex = _curDisplayIndex % _frames.count;
        return _frames[_curDisplayIndex].image;
    }
    return nil;
}

- (WebPFrame *)decodeCurFrame {
    if(_frames.count > 0) {
        @synchronized (self) {
            _curDecodeIndex = _curDecodeIndex % _frames.count;
            _curDisplayFrame = _frames[_curDecodeIndex];
            _curDisplayFrame.image = [self decodeWebPImageAtIndex:_curDecodeIndex++];
        }
        return _curDisplayFrame;
    }
    return nil;
}

- (void)incrementCurDisplayIndex {
    _curDisplayIndex ++;
}


-(BOOL)isAllFrameDecoded {
    for(NSInteger i=_frames.count-1; i>=0; i--) {
        if(!_frames[i].image) {
            return NO;
        }
    }
    return YES;
}

-(NSArray<UIImage *> *)images {
    NSMutableArray *images = [NSMutableArray array];
    for(WebPFrame *frame in _frames) {
        [images addObject:frame.image];
    }
    return images;
}

-(CGFloat)curDisplayFrameDuration {
    if(_frames.count > 0) {
        NSInteger index = _curDisplayIndex % _frames.count;
        return _frames[index].duration;
    }
    return 0;
}

static void freeWebpFrameImageData(void *info, const void *data, size_t size) {
    free((void*)data);
}

- (void)decodeWebPFramesInfo:(NSData *)imageData {
    WebPData data;
    WebPDataInit(&data);
    
    data.bytes = (const uint8_t *)[imageData bytes];
    data.size = [imageData length];
    
    WebPDemuxer *demux = WebPDemux(&data);
    
    uint32_t flags = WebPDemuxGetI(demux, WEBP_FF_FORMAT_FLAGS);
    
    if (flags & ANIMATION_FLAG) {
        WebPIterator iter;
        if (WebPDemuxGetFrame(demux, 1, &iter)) {
            CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
            
            do {
                WebPFrame *webPFrame = [WebPFrame new];
                webPFrame.duration = iter.duration / 1000.0f;
                webPFrame.webPData = iter.fragment;
                webPFrame.width = iter.width;
                webPFrame.height = iter.height;
                webPFrame.has_alpha = iter.has_alpha;
                [_frames addObject:webPFrame];
                
            }while (WebPDemuxNextFrame(&iter));
            _frameCount = _frames.count;
            
            CGColorSpaceRelease(colorSpaceRef);
            WebPDemuxReleaseIterator(&iter);
        }
    }
    WebPDemuxDelete(demux);
}

- (UIImage *)decodeWebPImageAtIndex:(NSInteger)index {
    WebPFrame *webPFrame = _frames[index];
    WebPData frame = webPFrame.webPData;
    
    WebPDecoderConfig config;
    WebPInitDecoderConfig(&config);
    
    config.input.height = webPFrame.height;
    config.input.width = webPFrame.width;
    config.input.has_alpha = webPFrame.has_alpha;
    config.input.has_animation = 1;
    config.options.no_fancy_upsampling = 1;
    config.options.bypass_filtering = 1;
    config.options.use_threads = 1;
    config.output.colorspace = MODE_RGBA;
    config.output.width = webPFrame.width;
    config.output.height = webPFrame.height;
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    
    VP8StatusCode status = WebPDecode(frame.bytes, frame.size, &config);
    if (status != VP8_STATUS_OK) {
        CGColorSpaceRelease(colorSpaceRef);
        return nil;
    }
    int imageWidth, imageHeight;
    uint8_t *data = WebPDecodeRGBA(frame.bytes, frame.size, &imageWidth, &imageHeight);
    if (data == NULL) {
        CGColorSpaceRelease(colorSpaceRef);
        return nil;
    }
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, data, imageWidth * imageHeight * 4, freeWebpFrameImageData);
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault | kCGImageAlphaLast;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    
    CGImageRef imageRef = CGImageCreate(imageWidth, imageHeight, 8, 32, 4 * imageWidth, colorSpaceRef, bitmapInfo, provider, NULL, YES, renderingIntent);
    
    UIImage *image = [UIImage imageWithCGImage:imageRef];
    
//    CGFloat scaleRatio = image.size.width / image.size.height;
//    CGFloat scaleWidth = ScreenWidth / 3;
//    CGFloat scaleHeight = scaleWidth / scaleRatio;
//    UIGraphicsBeginImageContext(CGSizeMake(scaleWidth, scaleHeight));
//    [image drawInRect:CGRectMake(0.0, 0.0, scaleWidth, scaleHeight)];
//    image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
    
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    
    CGColorSpaceRelease(colorSpaceRef);
    WebPFreeDecBuffer(&config.output);
    return image;
}

@end

