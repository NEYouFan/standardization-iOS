//
//  NSURLRequest+HTCache.h
//  HTHttp
//
//  Created by NetEase on 15/8/12.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTCachePolicyProtocol.h"

@interface NSURLRequest (HTCache)

/**
 *  ht_cachePolicy为0时, 不读cache, 结果也不存cache. 缓存策略不作为全局设置；如果希望某个request使用缓存，必须手动设置request.
 */
@property (nonatomic, assign) HTCachePolicyId ht_cachePolicy;

/**
 *  request对应的response是否已经被缓存.
 */
@property (nonatomic, assign) BOOL ht_isCached;

/**
 *  request的response过期时间. 在发送请求前设置生效.
 */
@property (nonatomic, assign) NSTimeInterval ht_cacheExpireTimeInterval;

/**
 *  request用于cache的Key.
 */
@property (nonatomic, copy) NSString *ht_cacheKey;

/**
 *  response的版本号. 默认为0. 需要根据版本号来做cache时设置.
 */
@property (nonatomic, assign) NSInteger ht_responseVersion;

/**
 *  默认情况下一个request的Key.
 *
 *  @return 返回根据request属性计算出来的key值.
 */
- (NSString *)ht_defaultCacheKey;

/**
 *  根据参数生成request在cache中的key.
 *  调用者可以传入自己处理后的parameters以忽略不必要的参数.
 *  默认情况下计算的cacheKey忽略了应用版本号，即应用升级后cache信息仍然有效.
 *  如果应用升级后使得Cache失效，参数sensitiveData中包含AppVersion即可, 否则默认传空字符串或者nil.
 *
 *  @param httpMethod    http请求方法
 *  @param baseUrl       http请求的baseUrl
 *  @param requestUrl    http请求的具体url
 *  @param parameters    http请求的参数
 *  @param sensitiveData 需要额外生成key的信息, 例如版本号信息等等.
 *
 *  @return 根据参数生成的唯一key值.
 */
+ (NSString *)ht_cacheKeyWithMethod:(NSString *)httpMethod
                            baseUrl:(NSString *)baseUrl
                         requestUrl:(NSString *)requestUrl
                         parameters:(id)parameters
                      sensitiveData:(id)sensitiveData;

@end
