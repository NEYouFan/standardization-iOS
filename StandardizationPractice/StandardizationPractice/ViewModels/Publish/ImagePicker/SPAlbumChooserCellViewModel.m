//
//  SPAlbumChooserCellViewModel.m
//  StandardizationPractice
//
//  Created by Baitianyu on 31/10/2016.
//  Copyright © 2016 Netease. All rights reserved.
//

#import "SPAlbumChooserCellViewModel.h"

@implementation SPAlbumChooserCellViewModel

- (instancetype)initWithAssetsGroup:(ALAssetsGroup *)group {
    if (self = [super init]) {
        _thumbnailImage = [UIImage imageWithCGImage:[group posterImage]];
        _groupName = [group valueForProperty:ALAssetsGroupPropertyName];
    }
    
    return self;
}

@end
