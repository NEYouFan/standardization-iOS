//
//  SPAlbumChooserCellViewModel.h
//  StandardizationPractice
//
//  Created by Baitianyu on 31/10/2016.
//  Copyright © 2016 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface SPAlbumChooserCellViewModel : NSObject

@property (nonatomic, strong) UIImage *thumbnailImage;
@property (nonatomic, copy) NSString *groupName;

- (instancetype)initWithAssetsGroup:(ALAssetsGroup *)group;

@end
