//
//  UIImage+ImageWithColor.m
//  UIImage-ImageWithColor
//
//  Created by Bruno Tortato Furtado on 14/12/13.
//  Copyright (c) 2013 No Zebra Network. All rights reserved.
//

#import "UIImage+ImageWithColor.h"

@implementation UIImage (ImageWithColor)

+ (UIImage *)imageWithColor:(UIColor *)color
{
    UIImage *image = [UIImage imageWithColor:color size:CGSizeMake(1, 1)];
    
    return image;
}

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size
{
    CGFloat scale = [UIScreen mainScreen].scale;
    CGFloat width = size.width;
    CGFloat height = size.height;
    CGRect fillRect = CGRectMake(0, 0, width, height);
    
    UIGraphicsBeginImageContextWithOptions(fillRect.size, NO, scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, fillRect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)imageWithColor:(UIColor *)color pixSize:(CGSize)size
{
    CGFloat scale = [UIScreen mainScreen].scale;
    CGFloat pixSizeW = size.width / scale;
    CGFloat pixSizeH = size.height / scale;
    CGRect fillRect = CGRectMake(0, 0, pixSizeW, pixSizeH);
    
    UIGraphicsBeginImageContextWithOptions(fillRect.size, NO, scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, fillRect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end