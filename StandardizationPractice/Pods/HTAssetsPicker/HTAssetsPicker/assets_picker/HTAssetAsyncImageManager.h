//
//  HTAssetAsyncImageManager.h
//  Pods
//
//  Created by jw on 5/10/16.
//
//

#import <UIKit/UIKit.h>
#import <Photos/PHImageManager.h>

/**
 *  支持设置最大并发请求数。（目前暂只考虑HTAssetsPicker内部使用）
 *  注意：
 *   (1)只支持异步请求，因为有请求可能需要放到缓存队列异步执行
 *   (2)重写了requestImageForAsset:targetSize:contentMode:options:resultHandler:,返回值是0。
 *   (3)非线程安全
 */
@interface HTAssetAsyncImageManager : PHImageManager

//最大并发请求数,默认10
@property (nonatomic,assign) NSInteger maxConcurrentRequestCount;

+ (instancetype)sharedInstance;
@end
