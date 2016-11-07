//
//  HTCacheManager.h
//  HTHttp
//
//  Created by NetEase on 15/8/12.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTCachedResponse.h"

typedef void(^HTCacheCompletionBlock)();
typedef void(^HTCacheSizeCompletionBlock)(NSUInteger cacheSize);

@interface HTCacheManager : NSObject

/**
 *  获取单例的HTCacheManager.
 *
 *  @return 返回HTCacheManager对象.
 */
+ (instancetype)sharedManager;

+ (void)setSharedManager:(HTCacheManager *)manager;

/**
 *  初始化一个自定义的HTCacheManager. 一般情况下使用默认提供的sharedManager即可.
 *  由于初始化HTCacheManager的时候需要创建数据库，尽管创建初使数据库文件并不怎么耗时，但仍然是IO操作，因此尽量避免在主线程创建.
 *
 *  @param diskCacheCapacity 磁盘缓存控件.
 *
 *  @return 创建的HTCacheManager实例.
 */
- (instancetype)initWithDiskCapacity:(NSUInteger)diskCacheCapacity;

/**
 *  该Request是否存在cache
 *
 *  @param request 网络请求对应的request对象
 *
 *  @return 如果request存在对应的Cache, 则返回YES, 否则返回NO.
 */
- (BOOL)hasCacheForRequest:(NSURLRequest *)request;

/**
 *  取出request对应的Cache.
 *
 *  @param HTCachedResponse 网络请求对应的request对象
 *
 *  @return 返回request对应的HTCachedResponse.
 */
- (HTCachedResponse *)cachedResponseForRequest:(NSURLRequest *)request;

/**
 *  缓存request的结果
 *
 *  @param cachedResponse request对应的response.
 *  @param request        网络请求对应的request对象
 */
- (void)storeCachedResponse:(HTCachedResponse *)cachedResponse forRequest:(NSURLRequest *)request;

// 开放给外部使用的接口

/**
 *  删除与request对应的缓存的response. 异步接口.
 *
 *  @param request 网络请求对应的request对象
 *  @param completion 删除完毕后的回调.
 */
- (void)removeCachedResponseForRequest:(NSURLRequest *)request completion:(HTCacheCompletionBlock)completion;

/**
 *  清除Cache.
 *
 *  @param completion 清除cache完毕后的回调.
 */
- (void)removeAllCachedResponsesOnCompletion:(HTCacheCompletionBlock)completion;

/**
 *  清除某个时间点之后保存的所有cache.
 *
 *  @param date       时间. 在参数date时间之后保存的cache都会被清理掉.
 *  @param completion 清理完毕后的回调.
 */
- (void)removeCachedResponsesSinceDate:(NSDate *)date completion:(HTCacheCompletionBlock)completion;

/**
 *  清理内存Cache.
 */
- (void)clearMemoryCache;

/**
 *  设置某个请求的Cache超时时间. 在接收到response后调用, 下次发送相同的request前生效.
 *
 *  @param interval 超时时间间隔
 *  @param request  网络请求对应的request对象
 */
- (void)setCacheExpireTime:(NSTimeInterval)interval forRequest:(NSURLRequest *)request;

/**
 *  当前disk Cache已占用的大小. 同步接口，避免在主线程中调用该方法.
 *
 *  @return 当前disk Cache已占用的大小.
 */
- (NSUInteger)getCurCacheSize;

/**
 *  计算disk Cache已占用的大小并将结果回调.
 *
 *  @param completion 计算结束后的回调.
 */
- (void)calculateSizeWithCompletionBlock:(HTCacheSizeCompletionBlock)completion;

/**
 * 设置默认的Cache超时时间. 如果默认的Cache超时时间大于maxCacheAge, 那么实际使用的超时时间为maxCacheAge.
 */
@property (nonatomic, assign) NSTimeInterval defaultExpireTime;

/**
 *  Cache最大存放时间. 默认为一周.
 */
@property (nonatomic, assign) NSTimeInterval maxCacheAge;


/**
 *  Disk Cache的最大大小. 默认值为10M. 可配置.
 *  如果要配置，需要在使用前指定；否则使用后修改原有的cache容量需要在下次存储cache时生效.
 */
@property (nonatomic, assign, readonly) NSUInteger diskCacheCapacity;

/**
 *  内存Cache的容量.
 */
@property (nonatomic, assign) NSUInteger memoryCacheCapacity;

/**
 *  内存Cache最多条目数.
 */
@property (nonatomic, assign) NSUInteger memoryCacheCountLimit;

@end
