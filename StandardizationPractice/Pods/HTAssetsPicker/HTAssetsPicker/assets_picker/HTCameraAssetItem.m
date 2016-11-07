//
//  HTCameraAssetItem.m
//  JWAssetsPicker
//
//  Created by jw-mbp on 9/16/15.
//  Copyright (c) 2015 jw. All rights reserved.
//

#import "HTCameraAssetItem.h"

@implementation HTCameraAssetItem


- (UIImage*)itemImage
{
    return [UIImage imageNamed:_imageName];
}


- (NSInteger)itemImageWithCompletion:(void (^)(UIImage *image, NSDictionary *info))completion
{
    if (completion) {
        completion([self itemImage],nil);
    }
    return 0;
}

@end
