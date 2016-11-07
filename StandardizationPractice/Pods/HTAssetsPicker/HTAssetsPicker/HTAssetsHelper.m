//
//  HTAssetsHelper.m
//  JWAssetsPicker
//
//  Created by jw-mbp on 9/22/15.
//  Copyright (c) 2015 jw. All rights reserved.
//

#import "HTAssetsHelper.h"

@implementation HTAssetsHelper
+ (ALAssetsFilter*)assetsFilterFromType:(HTAssetsType)type
{
    if ((type & HTAssetsTypePhoto) &&  (type & HTAssetsTypeVideo)) {
        return [ALAssetsFilter allAssets];
    }else if(type & HTAssetsTypePhoto){
        return [ALAssetsFilter allPhotos];
    }else if(type & HTAssetsTypeVideo){
        return [ALAssetsFilter allVideos];
    }else{
        return [ALAssetsFilter allAssets];
    }
}
@end
