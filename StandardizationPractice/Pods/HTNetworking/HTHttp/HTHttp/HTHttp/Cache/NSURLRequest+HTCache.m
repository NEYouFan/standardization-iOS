//
//  NSURLRequest+HTCache.m
//  HTHttp
//
//  Created by NetEase on 15/8/12.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "NSURLRequest+HTCache.h"
#import <objc/runtime.h>
#import "HTCommonUtility.h"

static const void *keyHTCachePolicy = &keyHTCachePolicy;
static const void *keyHTIsCached = &keyHTIsCached;
static const void *keyHTCacheExpireTimeInterval = &keyHTCacheExpireTimeInterval;
static const void *keyHTCacheKey = &keyHTCacheKey;
static const void *keyHTResponseVersion = &keyHTResponseVersion;

@implementation NSURLRequest (HTCache)

#pragma mark - Properties

- (HTCachePolicyId)ht_cachePolicy {
    NSNumber *cachePolicy = objc_getAssociatedObject(self, keyHTCachePolicy);
    return [cachePolicy integerValue];
}

- (void)setHt_cachePolicy:(HTCachePolicyId)cachePolicy{
    objc_setAssociatedObject(self, keyHTCachePolicy, @(cachePolicy), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)ht_isCached {
    NSNumber *cachePolicy = objc_getAssociatedObject(self, keyHTIsCached);
    return [cachePolicy boolValue];
}

- (void)setHt_isCached:(BOOL)isCached {
    objc_setAssociatedObject(self, keyHTIsCached, @(isCached), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSTimeInterval)ht_cacheExpireTimeInterval {
    NSNumber *cacheExpireTimeInterval = objc_getAssociatedObject(self, keyHTCacheExpireTimeInterval);
    return [cacheExpireTimeInterval doubleValue];
}

- (void)setHt_cacheExpireTimeInterval:(NSTimeInterval)cacheExpireTimeInterval {
    objc_setAssociatedObject(self, keyHTCacheExpireTimeInterval, @(cacheExpireTimeInterval), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)ht_cacheKey {
    NSString *cacheKey = objc_getAssociatedObject(self, keyHTCacheKey);
    if (0 == [cacheKey length]) {
        cacheKey = [self ht_defaultCacheKey];
        if (0 != [cacheKey length]) {
            // 存起来避免重复计算.
            // 忽略Request属性被修改后，cache需要重新计算的情形.
            // 原因: 内部使用过程中，一定是request组装完毕后才会计算ht_cacheKey; 外部使用的话也需要拿到组装完成的request后才可以利用该key获取数据.
            // 后续会提供上层封装来根据request的Methhod, URL, Parameters计算cacheKey并设置到属性上去.
            objc_setAssociatedObject(self, keyHTCacheKey, cacheKey, OBJC_ASSOCIATION_COPY_NONATOMIC);
        }
    }
    
    return cacheKey;
}

- (void)setHt_cacheKey:(NSString *)cacheKey {
    objc_setAssociatedObject(self, keyHTCacheKey, cacheKey, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSInteger)ht_responseVersion {
    NSNumber *responseVersion = objc_getAssociatedObject(self, keyHTResponseVersion);
    return responseVersion.integerValue;
}

- (void)setHt_responseVersion:(NSInteger)responseVersion {
    objc_setAssociatedObject(self, keyHTResponseVersion, @(responseVersion), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - cache key

- (NSString *)ht_defaultCacheKey {
    NSString *argument = (nil == self.HTTPBody) ? @"" : [[NSString alloc] initWithData:self.HTTPBody encoding:NSUTF8StringEncoding];
    // 默认情况下应用升级, cache仍然有效.
    return [[self class] ht_cacheKeyWithMethod:self.HTTPMethod baseUrl:@"" requestUrl:self.URL.absoluteString parameters:argument sensitiveData:@""];
    
    //    return [[self class] ht_cacheKeyWithMethod:self.HTTPMethod baseUrl:@"" requestUrl:self.URL.absoluteString parameters:argument sensitiveData:[HTCommonUtility appVersionString]];
}

// 根据HTTP Method, baseUrl, requestUrl, parameters和sensitiveData来生成request对应的唯一Key.
+ (NSString *)ht_cacheKeyWithMethod:(NSString *)httpMethod
                            baseUrl:(NSString *)baseUrl
                         requestUrl:(NSString *)requestUrl
                         parameters:(id)parameters
                      sensitiveData:(id)sensitiveData {
    NSString *requestInfo = [NSString stringWithFormat:@"Method:%@ baseUrl:%@ requestUrl:%@ Parameters:%@ Sensitive:%@", httpMethod, baseUrl, requestUrl,
                             parameters, nil != sensitiveData ? sensitiveData : @""];
    return [HTCommonUtility md5StringFromString:requestInfo];
}

@end
