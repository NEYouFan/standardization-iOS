//
//  HTImageView.m
//  HTImageView
//
//  Created by cxq on 15/7/14.
//  Copyright (c) 2015年 cxq. All rights reserved.
//

#import "HTImageView.h"
#import "UIImage+GIF.h"
#import "SDWebImageManager.h"

@interface HTImageView ()

@property(nonatomic, strong) UIImage *placeHolderImage;
@property(nonatomic, strong) UIImage *errorImage;
@property (nonatomic, assign) UIViewContentMode normalMode;
@property (nonatomic, assign) UIViewContentMode placeHolderMode;
@property (nonatomic, assign) UIViewContentMode errorMode;
@property (nonatomic, strong) NSString *imageURL;

@property (nonatomic, assign) BOOL fadeInEnable;
@property (nonatomic, assign) NSTimeInterval duration;

@end

static NSString *animationName = @"kFadeIn";

@implementation HTImageView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self doInit];
    }
    return self;
}

- (void)doInit
{
    _isImages = NO;
    _normalMode = UIViewContentModeScaleToFill;
    _placeHolderMode = UIViewContentModeCenter;
    _errorMode = UIViewContentModeCenter;
}

#pragma mark -  image contentMode and mask

- (void)setNormalImageContentMode:(UIViewContentMode)normalMode
                 placeHodlerImage:(UIImage *)placeHolderImage
                      contentMode:(UIViewContentMode)placeHolderMode
                       errorImage:(UIImage *)errorImage
                      contentMode:(UIViewContentMode)errorMode
{
   /*
    * 如果当前normal图为placeHoder或者errorImage，可能会造成mode不一致
    */
    BOOL bShowPlaceHolder = _placeHolderImage && _placeHolderImage == self.image;
    BOOL bShowErrorImage = _errorImage && _errorImage == self.image;
   
    _normalMode = normalMode;
    
    _placeHolderImage = placeHolderImage;
    _placeHolderMode = placeHolderMode;
    _errorImage = errorImage;
    _errorMode = errorMode;
    /**
     *  如果应该显示为placeHolder
     */
    if (bShowPlaceHolder || self.image == nil){
        self.image = nil;
        self.image = _placeHolderImage;
        self.contentMode = _placeHolderMode;
        return;
    }
   
   /**
    *  如果应该显示为error
    */
    if (bShowErrorImage){
        self.image = nil;
        self.image = _errorImage;
        self.contentMode = _errorMode;
        return;
    }
   
   /**
    *  如果应该显示为正常图片
    */
    if (self.image){
        self.contentMode = normalMode;
    }
    
}

- (void)setMaskLayerColor:(UIColor *)color radius:(NSUInteger)radius
{
    if (!_maskLayer) {
        _maskLayer = [CALayer layer];
        _maskLayer.bounds = self.bounds;
        _maskLayer.backgroundColor = color.CGColor;
        _maskLayer.cornerRadius = radius;
        _maskLayer.opacity = 0.3;
        _maskLayer.anchorPoint = CGPointMake(0, 0);
        [self.layer addSublayer:_maskLayer];
    }
   
   _maskLayer.hidden = YES;
   self.userInteractionEnabled = YES;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _maskLayer.frame = self.bounds;
}

#pragma mark - set image with url

- (void)setImageWithUrl:(NSURL *)url
{
    [self setImageWithUrl:url options:0 progress:nil completed:nil];
}

- (void)setImageWithUrl:(NSURL *)url completed:(SDWebImageCompletionBlock)completedBlock
{
    [self setImageWithUrl:url options:0 progress:nil completed:completedBlock];
}

- (void)setImageWithUrl:(NSURL *)url options:(SDWebImageOptions)option
{
    [self setImageWithUrl:url options:option progress:nil completed:nil];
}

- (void)setImageWithUrl:(NSURL *)url
                options:(SDWebImageOptions)option
              completed:(SDWebImageCompletionBlock)completedBlock
{
    [self setImageWithUrl:url options:option progress:nil completed:completedBlock];
}

- (void)setImageWithUrl:(NSURL *)url
                options:(SDWebImageOptions)option
               progress:(SDWebImageDownloaderProgressBlock)progressBlock
              completed:(SDWebImageCompletionBlock)completedBlock
{
    [self clearImageViewContent];
    
    __weak __typeof(self) wself = self;
    [self sd_setImageWithURL:url
            placeholderImage:_placeHolderImage
                     options:option
                    progress:progressBlock
                   completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL){

                        if (error) {
                           [wself errorHandle];
                        }
                        else{
                           [wself successHandle:image cacheType:cacheType];
                        }

                        if (completedBlock) {
                            completedBlock(image, error, cacheType, imageURL);
                        }
                    }];
}

- (void)clearImageViewContent
{
    self.image = nil;
    self.contentMode = _placeHolderMode;
    [self stopAnimating];
    _isImages = NO;
    self.animationImages = nil;
}

- (void)errorHandle
{
    if (_errorImage) {
        self.image = nil;
        self.image = _errorImage;
        self.contentMode = _errorMode;
    }
}

- (void)successHandle:(UIImage *)image cacheType:(SDImageCacheType)cacheType
{
    UIImage *imageTemp;
    
    if(image.images.count > 1){
        _isImages = YES;
        self.animationImages = image.images;
        imageTemp = image.images[0];
    }
    else{
        _isImages = NO;
        imageTemp = image;
    }
    if (cacheType == SDImageCacheTypeNone || (_fadeInWithCacheTypeDisk && cacheType == SDImageCacheTypeDisk)){  //图片获取方式判断
        if (_fadeInEnable){
            [self startFadeInAnimation];
        }
    }
    
    [self setImage:imageTemp];
    
    if (_autoPlay && _isImages){
        [self startAnimating];
    }
    self.contentMode = _normalMode;
}

#pragma mark - animation

- (void)setFadeInAnimationEnable:(BOOL)fadeInEnable duration:(NSTimeInterval)duration
{
    _fadeInEnable = fadeInEnable;
    _duration = duration;
}

- (void)startFadeInAnimation
{
    CATransition *transition = [CATransition animation];
    transition.duration = _duration;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
    [self.layer addAnimation:transition forKey:animationName];
}


- (void)removeFadeInAnimation
{
    [self.layer removeAnimationForKey:animationName];
}

- (void)setAutoRepeatCount:(NSUInteger)autoRepeatCount
{
    [self setAnimationRepeatCount:autoRepeatCount];
}

#pragma mark - touch event

- (void)setMaskLayerHidden:(BOOL)hidden
{
    BOOL originDisableActions = [CATransaction disableActions];
    [CATransaction setDisableActions:YES];
    _maskLayer.hidden = hidden;
    [CATransaction setDisableActions:originDisableActions];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_maskLayer) {
        [self setMaskLayerHidden:NO];
    }
    [self.superview touchesBegan:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_maskLayer) {
        [self setMaskLayerHidden:YES];
    }
    [self.superview touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_maskLayer) {
        [self setMaskLayerHidden:YES];
    }
    [self.superview touchesCancelled:touches withEvent:event];
}

@end
