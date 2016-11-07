//
//  UIImage+Crop.m
//  JWImageCropUtilTest
//
//  Created by jw on 3/11/16.
//  Copyright © 2016 jw. All rights reserved.
//

#import "UIImage+Crop.h"

#import <ImageIO/ImageIO.h>

// Helper methods for thumbnailForAsset:maxPixelSize:
static size_t getAssetBytesCallback(void *info, void *buffer, off_t position, size_t count) {
    ALAssetRepresentation *rep = (__bridge id)info;
    
    NSError *error = nil;
    size_t countRead = [rep getBytes:(uint8_t *)buffer fromOffset:position length:count error:&error];
    
    if (countRead == 0 && error) {
        // We have no way of passing this info back to the caller, so we log it, at least.
        NSLog(@"thumbnailForAsset:maxPixelSize: got an error reading an asset: %@", error);
    }
    
    return countRead;
}

static void releaseAssetCallback(void *info) {
    // The info here is an ALAssetRepresentation which we CFRetain in thumbnailForAsset:maxPixelSize:.
    // This release balances that retain.
    CFRelease(info);
}

static CGImageSourceRef imageSourceRefFromAsset(ALAsset* asset) {
    ALAssetRepresentation *rep = [asset defaultRepresentation];
    CGDataProviderDirectCallbacks callbacks = {
        .version = 0,
        .getBytePointer = NULL,
        .releaseBytePointer = NULL,
        .getBytesAtPosition = getAssetBytesCallback,
        .releaseInfo = releaseAssetCallback,
    };
    CGDataProviderRef provider = CGDataProviderCreateDirect((void *)CFBridgingRetain(rep), [rep size], &callbacks);
    CGImageSourceRef src = CGImageSourceCreateWithDataProvider(provider, NULL);
    CFRelease(provider);
    return  src;
}




static CGSize sizeOfImageSourceRef(CGImageSourceRef src){
    CGSize imageSize = CGSizeZero;
    if (src) {
        NSDictionary *options = @{(NSString *)kCGImageSourceShouldCache: @(NO)};
        NSDictionary *properties = (__bridge_transfer NSDictionary *)CGImageSourceCopyPropertiesAtIndex(src, 0, (CFDictionaryRef)options);
        if (properties) {
            CGFloat width = [[properties objectForKey:(NSString *)kCGImagePropertyPixelWidth] floatValue];
            CGFloat height = [[properties objectForKey:(NSString *)kCGImagePropertyPixelHeight] floatValue];
            int ori = [[properties objectForKey:(NSString *)kCGImagePropertyOrientation] intValue];
            CGFloat w;
            CGFloat h;
            if (ori > 4) { // see EXIF
                w = height;
                h = width;
            } else {
                w = width;
                h = height;
            }
            imageSize = CGSizeMake(w, h);
        }
    }
    return imageSize;
}


static UIImage* drawImageOfSize(UIImage* oldImage, CGSize size){
    UIGraphicsBeginImageContext(size); // this will crop
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = CGPointMake(0, 0);
    thumbnailRect.size.width= size.width;
    thumbnailRect.size.height = size.height;
    [oldImage drawInRect:thumbnailRect];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}

@implementation UIImage (Crop)



#pragma mark -- thumbnail
// Returns a UIImage for the given asset, with size length at most the passed size.
// The resulting UIImage will be already rotated to UIImageOrientationUp, so its CGImageRef
// can be used directly without additional rotation handling.
// This is done synchronously, so you should call this method on a background queue/thread.
+ (UIImage *)thumbnailForImageOfAsset:(ALAsset *)asset maxSidePixels:(NSUInteger)maxSidePixels {
    if (!asset || maxSidePixels <=0) {
        return nil;
    }
    
    CGImageSourceRef src = imageSourceRefFromAsset(asset);
    UIImage* result = [UIImage imageFromImageSourceRef:src withMaxSidePixels:maxSidePixels];
    CFRelease(src);
    return result;
}


+ (UIImage *)thumbnailForImageOfPath:(NSString *)imagePath maxSidePixels:(NSUInteger)maxSidePixels{
    return [self thumbnailForImageOfURL:[NSURL fileURLWithPath:imagePath] maxSidePixels:maxSidePixels];
}

+ (UIImage *)thumbnailForImageOfURL:(NSURL *)imageURL maxSidePixels:(NSUInteger)maxSidePixels {
    //NSParameterAssert(URL != nil && mps > 0);
    if (imageURL == nil || maxSidePixels <= 0) {
        return nil;
    }
    NSError *err;
    if ([imageURL checkResourceIsReachableAndReturnError:&err] == NO){
        return nil;
    }
    // Create the image source (from path)
    CGImageSourceRef src = CGImageSourceCreateWithURL((__bridge CFURLRef)imageURL, NULL);
    
    UIImage* result = [UIImage imageFromImageSourceRef:src withMaxSidePixels:maxSidePixels];
    CFRelease(src);
    return result;
}

+ (UIImage *)thumbnailForImageOfData:(NSData *)imageData maxSidePixels:(NSUInteger)maxSidePixels{
    if (!imageData || maxSidePixels <=0) {
        return nil;
    }
    CGImageSourceRef src = CGImageSourceCreateWithData((__bridge CFDataRef) imageData, NULL);
    UIImage* result = [UIImage imageFromImageSourceRef:src withMaxSidePixels:maxSidePixels];
    CFRelease(src);
    return result;
}

+ (UIImage*)imageFromImageSourceRef:(CGImageSourceRef)src withMaxSidePixels:(CGFloat)maxSidePixels{
    if (!src || maxSidePixels <= 0) {
        return nil;
    }
    // Create thumbnail options
    CFDictionaryRef options = (__bridge CFDictionaryRef) @{
                                                           (id) kCGImageSourceCreateThumbnailWithTransform : @YES,
                                                           (id) kCGImageSourceCreateThumbnailFromImageAlways : @YES,
                                                           (id) kCGImageSourceThumbnailMaxPixelSize : @(maxSidePixels)
                                                           };
    // Generate the thumbnail
    CGImageRef thumbnail = CGImageSourceCreateThumbnailAtIndex(src, 0, options);
    
    UIImage *result = nil;
    if (thumbnail) {
        result = [UIImage imageWithCGImage:thumbnail];
    }
    CGImageRelease(thumbnail);
    return  result;
}



#pragma mark -- image resize

- (UIImage*)imageByScaledForSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [self drawInRect:CGRectMake(0,0,size.width,size.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage*)imageByCroppedInRect:(CGRect)rect
{
    
    
    CGFloat scale = self.scale;
    CGRect cropRect = CGRectApplyAffineTransform(rect, CGAffineTransformMakeScale(scale, scale));
    
    CGImageRef croppedImage = CGImageCreateWithImageInRect(self.CGImage, cropRect);
    UIImage *image = [UIImage imageWithCGImage:croppedImage scale:self.scale orientation:self.imageOrientation];
    CGImageRelease(croppedImage);
    
    return image;
}

- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize
{
    UIImage *newImage = nil;
    CGSize imageSize = self.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        
        scaledWidth= width * scaleFactor;
        scaledHeight = height * scaleFactor;
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else if (widthFactor < heightFactor)
        {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    UIGraphicsBeginImageContext(targetSize); // this will crop
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width= scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    [self drawInRect:thumbnailRect];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    
    return newImage;
    
}

#pragma mark -- image size

+ (CGSize)sizeOfImageOfAsset:(ALAsset *)asset{
    if (!asset) {
        return CGSizeZero;
    }
    CGImageSourceRef src = imageSourceRefFromAsset(asset);
    CGSize size = sizeOfImageSourceRef(src);
    CFRelease(src);
    return size;
}

+ (CGSize)sizeOfImageOfData:(NSData *)imageData{
    CGImageSourceRef src = CGImageSourceCreateWithData((__bridge CFDataRef)imageData, NULL);
    CGSize size = sizeOfImageSourceRef(src);
    CFRelease(src);
    return size;
}

+ (CGSize)sizeOfImageOfPath:(NSString *)imagePath{
    return [UIImage sizeOfImageOfURL:[NSURL fileURLWithPath:imagePath]];
}

+ (CGSize)sizeOfImageOfURL:(NSURL *)imageURL{
    NSError *err;
    if ([imageURL checkResourceIsReachableAndReturnError:&err] == NO){
        return CGSizeZero;
    }
    CGImageSourceRef src = CGImageSourceCreateWithURL((CFURLRef)imageURL, NULL);
    CGSize size = sizeOfImageSourceRef(src);
    CFRelease(src);
    return size;
    
}

#pragma mark -- less than
- (UIImage*)imageOfMemorySizeLessThan:(CGFloat)kbSize{
    //rgba
    kbSize /=4;
    
    CGSize originalSize = CGSizeMake(self.size.width * self.scale, self.size.height * self.scale);
    CGFloat kbyteSize = originalSize.width * originalSize.height / 1024;
    if (kbyteSize <= kbSize) {
        return drawImageOfSize(self, originalSize);
    }
    
    CGFloat ratio = sqrt(kbyteSize / kbSize);
    return  drawImageOfSize(self, CGSizeMake(originalSize.width/ratio, originalSize.height/ratio));;
}

+ (UIImage*)imageOfPath:(NSString*)path withMemorySizeLessThan:(CGFloat)kbSize{
    return [UIImage imageOfURL:[NSURL fileURLWithPath:path] withMemorySizeLessThan:kbSize];
}

+ (UIImage*)imageOfURL:(NSURL*)url withMemorySizeLessThan:(CGFloat)kbSize{
    //rgba
    kbSize /=4;
    
    CGSize originalSize = [UIImage sizeOfImageOfURL:url];
    CGFloat kbyteSize = originalSize.width * originalSize.height / 1024;
    if (kbyteSize <= kbSize) {
        return [UIImage imageWithContentsOfFile:[url absoluteString]];
    }else{
        CGFloat ratio = sqrt(kbyteSize / kbSize);
        NSUInteger maxSidePixels = 0;
        if (originalSize.width > originalSize.height) {
            maxSidePixels = originalSize.width/ratio;
        }else{
            maxSidePixels = originalSize.height/ratio;
        }
        return [UIImage thumbnailForImageOfURL:url maxSidePixels:maxSidePixels];
    }
}

+ (UIImage*)imageOfData:(NSData*)data withMemorySizeLessThan:(CGFloat)kbSize{
    //rgba
    kbSize /=4;
    
    CGSize originalSize = [UIImage sizeOfImageOfData:data];
    CGFloat kbyteSize = originalSize.width * originalSize.height / 1024;
    if (kbyteSize <= kbSize) {
        return [UIImage imageWithData:data];
    }else{
        CGFloat ratio = sqrt(kbyteSize / kbSize);
        NSUInteger maxSidePixels = 0;
        if (originalSize.width > originalSize.height) {
            maxSidePixels = originalSize.width/ratio;
        }else{
            maxSidePixels = originalSize.height/ratio;
        }
        return [UIImage thumbnailForImageOfData:data maxSidePixels:maxSidePixels];
    }
}

+ (UIImage*)imageOfAsset:(ALAsset*)asset withMemorySizeLessThan:(CGFloat)kbSize{
    //rgba
    kbSize /=4;
    
    CGSize originalSize = [UIImage sizeOfImageOfAsset:asset];
    CGFloat kbyteSize = originalSize.width * originalSize.height / 1024;
    if (kbyteSize <= kbSize) {
        ALAssetRepresentation *representation = [asset defaultRepresentation];
        return [UIImage imageWithCGImage:representation.fullResolutionImage
                                   scale:[representation scale]
                             orientation:(UIImageOrientation)[representation orientation]];
    }else{
        CGFloat ratio = sqrt(kbyteSize / kbSize);
        NSUInteger maxSidePixels = 0;
        if (originalSize.width > originalSize.height) {
            maxSidePixels = originalSize.width/ratio;
        }else{
            maxSidePixels = originalSize.height/ratio;
        }
        return [UIImage thumbnailForImageOfAsset:asset maxSidePixels:maxSidePixels];
    }
}

@end
