//
//  HTAssetItem.h
//  JWAssetsPicker
//
//  Created by jw-mbp on 9/16/15.
//  Copyright (c) 2015 jw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <UIKit/UIKit.h>
#import "HTAsset.h"

@interface HTAssetItem : NSObject

/*资源，canbe nil for camera*/
@property (nonatomic,strong) HTAsset *asset;

/*被选中的次序索引值,从1开始*/
@property (nonatomic,assign) NSInteger index;

/*选中状态*/
@property (nonatomic,getter=isSelected,assign) BOOL selected;

/*缩略图尺寸*/
@property (nonatomic,assign) CGSize thumbnailSize;


/**
 *  需要展示的资源，一般为asset资源图片，子类可重写来返回不同的UIImage
 *  用例：相机
 *  @size 请求图片尺寸
 *  @return 显示的UIImage
 */
- (UIImage*)itemImage;

/**
 *  异步请求图片资源
 *
 *  @param completion 回调
 *  @return 请求id，可以从info中取得PHImageResultRequestIDKey做对比,ios7及以前，返回0
 */
- (NSInteger)itemImageWithCompletion:(void (^)(UIImage *image, NSDictionary *info))completion;
@end
