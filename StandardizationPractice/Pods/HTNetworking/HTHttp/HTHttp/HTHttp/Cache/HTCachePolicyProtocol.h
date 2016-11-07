//
//  HTCachePolicy.h
//  HTHttp
//
//  Created by NetEase on 15/8/12.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, HTCachePolicyId) {
    HTCachePolicyNoCache = 0,
    HTCachePolicyCacheFirst = 1,    // Read cache data first and always cache data.
    HTCachePolicyWriteOnly = 2,     // Write cache data if successful but never read cache data. For example, app first request data, if the data exists in cache,
                                    // then app get the data and display them. After that, app still asks data from server and store them into the cache.
//    HTCachePolicyReadOnly = 3,    // Read cache data if exists but never store cache data.
                                    // As it doesn't make sense to not store cache data, we don't provide such policy by default.
    HTCachePolicyUserDefined = 100,
};

@class RKHTTPRequestOperation;

@protocol HTCachePolicyProtocol <NSObject>

@required

/**
 *  是否存在requestOperation对应的缓存结果.
 *
 *  @param requestOperation 网络请求Operation对象.
 *
 *  @return 有对应缓存结果，返回YES, 否则, 返回NO.
 */
+ (BOOL)hasCacheForRequest:(RKHTTPRequestOperation *)requestOperation;

/**
 *  获取requestOperation对应的缓存结果.
 *
 *  @param requestOperation 网络请求Operation对象.
 *
 *  @return 返回缓存的结果，如果没有，返回nil.
 */
+ (NSCachedURLResponse *)cachedResponseForRequest:(RKHTTPRequestOperation *)requestOperation;

@end
