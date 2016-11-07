//
//  HTAsset.h
//  Pods
//
//  Created by jw on 5/5/16.
//
//

#import <Foundation/Foundation.h>
#import <Photos/PHImageManager.h>
#import "HTAssetsHelper.h"

#define HTASSETSPICKER_USE_PHOTOKIT ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

/**
 *  对ALAsset和PHAsset的包装，为了兼容ios8以前的版本
 *  使用者可以使用HTAsset提供的相关接口来获取相关资源，也可以利用absoluteAsset接口获取ALAsset/PHAsset来进行操作。
 */

@interface HTAsset : NSObject

/**
 *  资源类型
 */
@property (nonatomic, assign) HTAssetsType assetType;

/**
 *  资源构造函数，需要传入真正的asset，ALAsset(ios7 and before)或者PHAsset(ios 8 and later)
 *
 *  @param asset absoluteAsset
 *
 *  @return HTAsset实例
 */
- (instancetype)initWihtAsset:(id)asset;

/**
 *  获取被包装ALAsset(ios7 and before)或者PHAsset(ios 8 and later)
 */
- (id)absoluteAsset;

/**
 *  获取HTAsset的唯一表示
 */
- (NSString*)localIdentifier;


/**
 *
 *  @param size 请求缩略图尺寸 对于iOS7及以前，通过ALAsset thumbnail获得，不保证thumbnail满足请求size
 *  In iOS 8, ALAsset.thumbnail size are 150 * 150, but in iOS 9 its 75 * 75
 *
 *  @return 缩略图
 */
- (UIImage *)thumbnailWithSize:(CGSize)size;

/**
 *  调用thumbnailWithSize: 150 x 150
 */
- (UIImage*)thumbnail;

/**
 *  异步获取缩略图,completion可能会被多次调用，而且回调传入的image可能是nil，回调中最好加以判断是否为nil
 *
 *  @param size       请求缩略图尺寸
 *  @param completion 请求成功回调。image：请求得到的图片，info：图片相关信息（ios7及以前返回nil），具体参考PHImageManager的requestImageForAsset:targetSize:contentMode:options:resultHandler接口
 *  @return 请求id，可以从info中取得PHImageResultRequestIDKey做对比,ios7及以前，返回0
 */
- (NSInteger)requestThumbnailImageWithSize:(CGSize)size completion:(void (^)(UIImage *image, NSDictionary *info))completion;

/**
 *  获取预览图，图片大小等于屏幕大小
 *
 */
- (UIImage *)previewImage;

/**
 *  异步获取预览图，图片大小等于屏幕大小。completion可能会被多次调用，而且回调传入的image可能是nil，回调中最好加以判断是否为nil
 *
 *  @param completion 请求成功回调。image：请求得到的图片，info：图片相关信息（ios7及以前返回nil），具体参考PHImageManager的requestImageForAsset:targetSize:contentMode:options:resultHandler接口
 *  @return 请求id，可以从info中取得PHImageResultRequestIDKey做对比,ios7及以前，返回0
 *
 */
- (NSInteger)requestPreviewImageWithCompletion:(void (^)(UIImage *image, NSDictionary *info))completion;

/**
 *  获取原图
 *
 */
- (UIImage *)originImage;


/**
 *  异步获取原图，但如果image立刻可用。completion可能会被多次调用，而且回调传入的image可能是nil，回调中最好加以判断是否为nil
 *
 *  @param completion 请求成功回调。image：请求得到的图片，info：图片相关信息（ios7及以前返回nil），具体参考PHImageManager的requestImageForAsset:targetSize:contentMode:options:resultHandler接口
 *  @return 请求id，可以从info中取得PHImageResultRequestIDKey做对比,ios7及以前，返回0
 *
 */
- (NSInteger)requestOriginImageWithCompletion:(void (^)(UIImage *image, NSDictionary *info))completion;


@end
