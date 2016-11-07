//
//  HTAssetItem.m
//  JWAssetsPicker
//
//  Created by jw-mbp on 9/16/15.
//  Copyright (c) 2015 jw. All rights reserved.
//

#import "HTAssetItem.h"

@implementation HTAssetItem

- (instancetype)init{
    self = [super init];
    if (self) {
        _index = 0;
        _selected = NO;
    }
    return self;
}


- (UIImage*)itemImage
{
    UIImage* itemImage = nil;
    if (_asset) {
        itemImage =  [_asset thumbnailWithSize:_thumbnailSize];
    }
    return itemImage;
}


- (NSInteger)itemImageWithCompletion:(void (^)(UIImage *image, NSDictionary *info))completion
{
    if (_asset) {
        return [_asset requestThumbnailImageWithSize:_thumbnailSize completion:completion];
    }
    return 0;
}


- (BOOL)isEqual:(id)object
{
    if (object == self) {
        return YES;
    }
    if (![object isKindOfClass:[HTAssetItem class]]) {
        return NO;
    }
    HTAssetItem* otherItem = object;
    if (!self.asset || !otherItem.asset) {
        return NO;
    }
    return [self.asset isEqual:otherItem.asset];    
}

- (NSUInteger)hash
{
    if (!self.asset) {
        return 0;
    }
    return [_asset hash];
}

@end
