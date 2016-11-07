//
//  HTAsset.m
//  Pods
//
//  Created by jw on 5/5/16.
//
//

#import "HTAsset.h"
#import <AssetsLibrary/ALAsset.h>
#import <AssetsLibrary/ALAssetRepresentation.h>
#import <Photos/Photos.h>
#import "HTAssetAsyncImageManager.h"

@interface HTAsset ()
//分别用于保存两种类型的asset，在一个平台下，只有一个有值
@property (nonatomic,strong) ALAsset* alasset;
@property (nonatomic,strong) PHAsset* phasset;
@end

@implementation HTAsset

- (instancetype)initWihtAsset:(id)asset
{
    self = [super init];
    if (self) {
        if ([asset isKindOfClass:PHAsset.class]) {
            _phasset = asset;
        }else if([asset isKindOfClass:ALAsset.class]){
            _alasset = asset;
        }
    }
    return self;
}

- (UIImage*)thumbnail
{
    return [self thumbnailWithSize:CGSizeMake(150, 150)];
}

- (UIImage *)thumbnailWithSize:(CGSize)size
{
    __block UIImage *resultImage;
    if (_phasset) {
        PHImageRequestOptions *phImageRequestOptions = [[PHImageRequestOptions alloc] init];
        phImageRequestOptions.resizeMode = PHImageRequestOptionsResizeModeExact;//PHImageRequestOptionsResizeModeFast
        phImageRequestOptions.synchronous = YES;
        
        //同步请求，使用PHImageManager
        PHImageManager* manager = [PHImageManager defaultManager];
        [manager requestImageForAsset:_phasset
                           targetSize:size
                          contentMode:PHImageContentModeDefault
                              options:phImageRequestOptions
                        resultHandler:^void(UIImage *image, NSDictionary *info) {
                            //retrive all  images
                            resultImage = image;
                        }];
    } else {
        CGImageRef thumbnailImageRef = [_alasset thumbnail];
        if (thumbnailImageRef) {
            resultImage = [UIImage imageWithCGImage:thumbnailImageRef];
        }
    }
    return resultImage;
}

- (NSInteger)requestThumbnailImageWithSize:(CGSize)size completion:(void (^)(UIImage *image, NSDictionary *info))completion
{
    if (_phasset) {
        PHImageRequestOptions *phImageRequestOptions = [[PHImageRequestOptions alloc] init];
        phImageRequestOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
        phImageRequestOptions.synchronous = NO;
        PHImageManager* manager = [HTAssetAsyncImageManager sharedInstance];
        return [manager requestImageForAsset:_phasset targetSize:size
                          contentMode:PHImageContentModeDefault
                              options:phImageRequestOptions
                        resultHandler:^void(UIImage *image, NSDictionary *info) {
                            if (completion) {
                                completion(image,info);
                            }
                        }];

    } else {
        if (completion) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                UIImage* image = [self thumbnailWithSize:size];
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(image, nil);
                });
            });
        }
        return 0;
    }
}


- (UIImage *)previewImage
{
    __block UIImage *resultImage;
    if (_phasset) {
        PHImageRequestOptions *phImageRequestOptions = [[PHImageRequestOptions alloc] init];
        phImageRequestOptions.synchronous = YES;
        phImageRequestOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
        PHImageManager* manager = [PHImageManager defaultManager];
        [manager requestImageForAsset:_phasset targetSize:[UIScreen mainScreen].bounds.size
                                 contentMode:PHImageContentModeDefault
                                     options:phImageRequestOptions
                               resultHandler:^void(UIImage *image, NSDictionary *info) {
                                   resultImage = image;
                               }];
        
        
    } else {
        CGImageRef fullScreenImageRef = [[_alasset defaultRepresentation] fullScreenImage];
        resultImage = [UIImage imageWithCGImage:fullScreenImageRef];
    }
    return resultImage;
}

- (NSInteger)requestPreviewImageWithCompletion:(void (^)(UIImage *image, NSDictionary *info))completion
{
    if (_phasset) {
        PHImageRequestOptions *phImageRequestOptions = [[PHImageRequestOptions alloc] init];
        phImageRequestOptions.synchronous = NO;
        phImageRequestOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
        phImageRequestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        PHImageManager* manager = [HTAssetAsyncImageManager sharedInstance];
        return [manager requestImageForAsset:_phasset targetSize:[UIScreen mainScreen].bounds.size
                          contentMode:PHImageContentModeDefault
                              options:phImageRequestOptions
                        resultHandler:^void(UIImage *image, NSDictionary *info) {
                            if (completion) {
                                completion(image,info);
                            }
                            
                        }];
    } else {
        if (completion) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                CGImageRef imageRef = [[_alasset defaultRepresentation] fullScreenImage];
                UIImage* image = [UIImage imageWithCGImage:imageRef];
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(image, nil);
                });
            });
        }
        return 0;
    }

}

- (UIImage *)originImage
{
    __block UIImage *resultImage;
    if (_phasset) {
        PHImageRequestOptions *phImageRequestOptions = [[PHImageRequestOptions alloc] init];
        phImageRequestOptions.synchronous = YES;
        phImageRequestOptions.resizeMode   = PHImageRequestOptionsResizeModeExact;
    
        PHImageManager *manager = [PHImageManager defaultManager];
        
        // assets contains PHAsset objects.
        __block UIImage *resultImage;
        
        [manager requestImageForAsset:_phasset
                           targetSize:PHImageManagerMaximumSize
                          contentMode:PHImageContentModeDefault
                              options:phImageRequestOptions
                        resultHandler:^void(UIImage *image, NSDictionary *info) {
                            //retrive all  images
                            resultImage = image;
        }];
        return resultImage;
    } else {
        ALAssetRepresentation* rep = [_alasset defaultRepresentation];
        CGImageRef fullResolutionImageRef = [rep fullResolutionImage];
                // 生成最终返回的 UIImage，同时把图片的 orientation 也补充上去
        resultImage = [UIImage imageWithCGImage:fullResolutionImageRef scale:[rep scale] orientation:(UIImageOrientation)[rep orientation]];
        return resultImage;
    }
}

- (NSInteger)requestOriginImageWithCompletion:(void (^)(UIImage *image, NSDictionary *info))completion
{
    if (_phasset) {
        PHImageRequestOptions *phImageRequestOptions = [[PHImageRequestOptions alloc] init];
        phImageRequestOptions.synchronous = NO;
        phImageRequestOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
        PHImageManager* manager = [HTAssetAsyncImageManager sharedInstance];
        return [manager requestImageForAsset:_phasset targetSize:PHImageManagerMaximumSize
                                 contentMode:PHImageContentModeDefault
                                     options:phImageRequestOptions
                               resultHandler:^void(UIImage *image, NSDictionary *info) {
                                   if (completion) {
                                       completion(image,info);
                                   }
                               }];
        
        
    } else {
        if (completion) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                CGImageRef imageRef = [[_alasset defaultRepresentation] fullResolutionImage];
                UIImage* image = [UIImage imageWithCGImage:imageRef];
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(image, nil);
                });
            });
        }
        return 0;
    }
}

- (BOOL)isEqual:(HTAsset*)object
{
    if (self == object) {
        return YES;
    }
    
    if (object == nil) {
        return NO;
    }
    
    if (_phasset) {
        id abAsset = object.absoluteAsset;
        if ([abAsset isKindOfClass:PHAsset.class]) {
            PHAsset* tmpAsset = (PHAsset*)abAsset;
            return [_phasset.localIdentifier isEqual:tmpAsset.localIdentifier];
        }else{
            return NO;
        }
    }else if(_alasset){
        id abAsset = object.absoluteAsset;
        if ([abAsset isKindOfClass:ALAsset.class]) {
            ALAsset* tmpAsset = (ALAsset*)abAsset;
            NSURL* url = [[_alasset defaultRepresentation] url];
            NSURL* other = [[tmpAsset defaultRepresentation]url];
            return [url isEqual:other];
        }else{
            return NO;
        }
    }
    return NO;
}

- (NSString*)localIdentifier
{
    if (_phasset) {
        return _phasset.localIdentifier;
    }else if(_alasset){
        NSURL* url = [[_alasset defaultRepresentation] url];
        return [url absoluteString];
    }else{
        return @"";
    }
}

- (NSUInteger)hash
{
    if (_phasset) {
        return [_phasset.localIdentifier hash];
    }else if(_alasset){
        NSURL* url = [[_alasset defaultRepresentation] url];
        return [[url absoluteString]hash];
    }else{
        return 0;
    }
    
}

- (id)absoluteAsset
{
    return _phasset ? : (_alasset ? : nil);
}


@end
