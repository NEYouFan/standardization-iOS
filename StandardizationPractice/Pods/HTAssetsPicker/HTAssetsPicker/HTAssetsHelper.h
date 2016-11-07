//
//  HTAssetsHelper.h
//  JWAssetsPicker
//
//  Created by jw-mbp on 9/22/15.
//  Copyright (c) 2015 jw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

typedef NS_OPTIONS(NSInteger, HTAssetsType){
    HTAssetsTypeNone    = 0,
    HTAssetsTypePhoto   = 1,
    HTAssetsTypeVideo   = 1 << 1
};

@interface HTAssetsHelper : NSObject

+ (ALAssetsFilter*)assetsFilterFromType:(HTAssetsType)type;

@end
