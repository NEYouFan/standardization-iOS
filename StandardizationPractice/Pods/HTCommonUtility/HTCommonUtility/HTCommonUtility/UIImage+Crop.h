//
//  UIImage+Crop.h
//  JWImageCropUtilTest
//
//  Created by jw on 3/11/16.
//  Copyright © 2016 jw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface UIImage (Crop)


/**
 * 根据传入最大边长等比缩放图片，返回缩略图。支持大图的读取。
 * 如果maxSidePixels > max(image.size.width, image.size.height),则返回原图；
 * 如果maxSidePixels < max(image.size.width, image.size.height),则返回等比缩放之后的图片；
 * @param maxSidePixels 最大边长
 * @param URL 本地文件路径
 */

+ (UIImage *)thumbnailForImageOfAsset:(ALAsset *)asset maxSidePixels:(NSUInteger)maxSidePixels;

+ (UIImage *)thumbnailForImageOfPath:(NSString *)imagePath maxSidePixels:(NSUInteger)maxSidePixels;

+ (UIImage *)thumbnailForImageOfURL:(NSURL *)imageURL maxSidePixels:(NSUInteger)maxSidePixels;

+ (UIImage *)thumbnailForImageOfData:(NSData *)imageData maxSidePixels:(NSUInteger)maxSidePixels;


/**
 * 获取图片尺寸。
 */
+ (CGSize)sizeOfImageOfAsset:(ALAsset *)asset;

+ (CGSize)sizeOfImageOfPath:(NSString *)imagePath;

+ (CGSize)sizeOfImageOfURL:(NSURL *)imageURL;

+ (CGSize)sizeOfImageOfData:(NSData *)imageData;


/**
 * 等比缩放之后，获取重绘图片，总大小小于kbSize。
 */
- (UIImage*)imageOfMemorySizeLessThan:(CGFloat)kbSize;

+ (UIImage*)imageOfPath:(NSString*)path withMemorySizeLessThan:(CGFloat)kbSize;

+ (UIImage*)imageOfURL:(NSURL*)url withMemorySizeLessThan:(CGFloat)kbSize;

+ (UIImage*)imageOfData:(NSData*)data withMemorySizeLessThan:(CGFloat)kbSize;

+ (UIImage*)imageOfAsset:(ALAsset*)asset withMemorySizeLessThan:(CGFloat)kbSize;


/**
 * 直接裁剪。根据传入矩形，裁剪图片。如果裁剪矩形rect的区域大于或者有大于图片矩形的尺寸，将会按照两个矩形的交集进行裁剪。
 * 返回裁剪后的图片。
 */
- (UIImage*)imageByCroppedInRect:(CGRect)rect;


/**
 * 非等比缩略绘制。根据传入矩形，进行非等比缩略绘制。
 * 返回缩放重绘之后的图片。
 */
- (UIImage*)imageByScaledForSize:(CGSize)size;


/**
 * 等比缩略裁剪。根据传入矩形，进行等比缩略裁剪，即先等比缩放，再裁剪。
 * 返回等比缩放裁剪后的图片。
 */
- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize;
@end
