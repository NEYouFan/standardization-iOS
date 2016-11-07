//
//  HTHTTPReqeustOperation.m
//  HTHttp
//
//  Created by NetEase on 15/7/24.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import <HTHttp/Core/HTHTTPRequestOperation.h>
#import "HTCachePolicyManager.h"
#import "NSURLRequest+HTCache.h"
#import "NSURLResponse+HTCache.h"
#import "NSURLRequest+HTFreeze.h"
#import "HTCacheManager.h"
#import "HTFreezeManager.h"
#import "RKObjectRequestOperation.h"
#import "HTCachePolicyProtocol.h"
#import "HTHTTPDate.h"
#import "HTHttpLog.h"
#import "RKErrors.h"
#import "AFNetworkReachabilityManager.h"

NSString * const HTResponseFromCacheUserInfoKey = @"HTResponseFromCache";
NSString * const HTResponseCacheVersionUserInfoKey = @"HTResponseCacheVersion";
NSString * const HTResponseCacheExpireTimeUserInfoKey = @"HTResponseCacheExpireTime";

@interface RKHTTPRequestOperation ()

@property (readwrite, nonatomic, strong) NSHTTPURLResponse *response;
@property (readwrite, nonatomic, strong) NSData *responseData;

@end

@interface HTHTTPRequestOperation ()

// Record the error happens before really starting the request.
@property (readwrite, nonatomic, strong) NSError *internalError;

@end

@implementation HTHTTPRequestOperation

- (void)start {
    Class<HTCachePolicyProtocol> cachePolicyClass = [[HTCachePolicyManager sharedInstance] cachePolicyClassForRequest:self];
    NSCachedURLResponse *cachedURLResponse = [cachePolicyClass cachedResponseForRequest:self];
    if (nil != cachedURLResponse) {
        HTLogHTTPInfo(@"Get response from cache successfully for request : %@", self.request);
        
        [self updateResponseWithCache:cachedURLResponse];

        [self finishOperation];
    } else if ([self shouldFreezeRequest]) {
        HTLogHTTPInfo(@"Freeze request : %@", self.request);
        self.request.ht_isFrozen = YES;
        [[HTFreezeManager sharedInstance] freeze:self.request];
        NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: @"Request is frozen as there is no valid Internet connections." };
        self.internalError = [NSError errorWithDomain:RKErrorDomain code:RKOperationFrozenError userInfo:userInfo];
        [self finishOperation];
    } else {
        [super start];
    }
}

- (BOOL)shouldFreezeRequest {
    return self.request.ht_canFreeze && [HTFreezeManager sharedInstance].isMonitoring && (![AFNetworkReachabilityManager sharedManager].isReachable);
}

- (BOOL)isFinished {
    if (self.isResponseFromCache) {
        return YES;
    }
    
    return [super isFinished];
}

#pragma mark - Override Methods

- (NSError *)error {
    if (nil != _internalError) {
        return _internalError;
    }
    
    return [super error];
}

- (void)ht_checkAndFreezeRequest {
    if (![AFNetworkReachabilityManager sharedManager].reachable) {
        NSURLRequest *request = self.request;
        if (request.ht_canFreeze) {
            request.ht_isFrozen = YES;
            [[HTFreezeManager sharedInstance] freeze:request];
        }
    }
}

#pragma mark - Cache

- (void)updateResponseWithCache:(NSCachedURLResponse *)cacheResponse {
    // 实际类型一定是NSHTTPURLResponse.
    if ([cacheResponse.response isKindOfClass:[NSHTTPURLResponse class]]) {
        self.response = (NSHTTPURLResponse *)cacheResponse.response;
    }
    self.responseData = cacheResponse.data;
    self.request.ht_isCached = YES;
    self.response.ht_isFromCache = YES;
}

- (void)ht_cacheResponse {
    if (HTCachePolicyNoCache == self.request.ht_cachePolicy || self.request.ht_isCached) {
        return;
    }
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    userInfo[RKResponseHasBeenMappedCacheUserInfoKey] = @YES;
    NSCachedURLResponse *cachedResponse = [[NSCachedURLResponse alloc] initWithResponse:self.response data:self.responseData userInfo:userInfo storagePolicy:NSURLCacheStorageAllowed];
    HTCachedResponse *htResponse = [[HTCachedResponse alloc] init];
    htResponse.response = cachedResponse;
    htResponse.createDate = [[HTHTTPDate sharedInstance] now];
    htResponse.version = self.request.ht_responseVersion;

    [[HTCacheManager sharedManager] storeCachedResponse:htResponse forRequest:self.request];
}

- (BOOL)isResponseFromCache {
    return self.response.ht_isFromCache;
}

#pragma mark - Completion Block

- (void)setCompletionBlockWithSuccess:(void (^)(RKHTTPRequestOperation *operation, id responseObject))success
                              failure:(void (^)(RKHTTPRequestOperation *operation, NSError *error))failure {
    [super setCompletionBlockWithSuccess:^(RKHTTPRequestOperation *operation, id responseObject) {
        if ([operation isKindOfClass:[HTHTTPRequestOperation class]]) {
            HTHTTPRequestOperation *htOperation = (HTHTTPRequestOperation *)operation;
            // 判定结果是否从缓存中来.
            BOOL isResultFromCache = htOperation.isResponseFromCache;
            // 如果结果不是从缓存中获取到，那么将Response存入缓存中.
            if (!isResultFromCache) {
                [htOperation ht_cacheResponse];
            }
        }

        success(operation, responseObject);
    } failure:^(RKHTTPRequestOperation *operation, NSError *error) {
        if ([operation isKindOfClass:[HTHTTPRequestOperation class]] && ![operation isCancelled]) {
            HTHTTPRequestOperation *htOperation = (HTHTTPRequestOperation *)operation;
            [htOperation ht_checkAndFreezeRequest];
        }
        
        failure(operation, error);
    }];
}

@end
