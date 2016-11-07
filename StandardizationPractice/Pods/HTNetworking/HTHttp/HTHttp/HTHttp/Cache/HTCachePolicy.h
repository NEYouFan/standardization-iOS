//
//  HTCachePolicy.h
//  HTHttp
//
//  Created by NetEase on 15/8/13.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTCachePolicyProtocol.h"

@interface HTCachePolicy : NSObject <HTCachePolicyProtocol>

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
