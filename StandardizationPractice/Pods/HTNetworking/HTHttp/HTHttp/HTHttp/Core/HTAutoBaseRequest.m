//
//  HTAutoBaseRequest.m
//  HTHttp
//
//  Created by Wangliping on 16/1/11.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import "HTAutoBaseRequest.h"
#import <RestKit/Network/RKObjectManager.h>
#import "NSObject+HTModel.h"
#import <HTHttp/Core/HTModelProtocol.h>

@interface HTAutoBaseRequest () <HTModelProtocol>

@end

@implementation HTAutoBaseRequest

#pragma mark - Basic Configuration

- (NSTimeInterval)requestTimeoutInterval {
    if (0 == (NSInteger)_customRequestTimeoutInterval) {
        return [super requestTimeoutInterval];
    }
    
    return _customRequestTimeoutInterval;
}

#pragma mark - Cache Configuration

- (NSString *)cacheKey {
    if ([_customCacheKey length] == 0) {
        return [super cacheKey];
    }
    
    return _customCacheKey;
}

- (NSString *)cacheKeyWithManager:(RKObjectManager *)mananger {
    if (nil == _cacheKeyBlock) {
        return [super cacheKeyWithManager:mananger];
    }

    __weak HTAutoBaseRequest *weakSelf = self;
    return _cacheKeyBlock(weakSelf, mananger);
}

- (NSDictionary *)cacheKeyFilteredRequestParams:(NSDictionary *)params {
    if (nil == _cacheParamsFilterBlock) {
        return [super cacheKeyFilteredRequestParams:params];
    }
    
    __weak HTAutoBaseRequest *weakSelf = self;
    return _cacheParamsFilterBlock(weakSelf, params);
}

#pragma mark - RKObjectManager Configuration

- (BOOL)needCustomRequest {
    return _configNeedCustomRequest || [super needCustomRequest];
}

#pragma mark - Special Configuration

- (NSString *)requestType {
    return _customRequestType;
}

- (HTConstructingMultipartFormBlock)constructingBodyBlock {
    return _customConstructingBlock;
}

- (HTValidResultBlock)validResultBlock {
    // 如果每个请求希望定制自己的validResultBlock, 那么自己设置一个_customValidResultBlock.
    // 如果所有请求希望共用一个validResultBlock, 那么通过HTNetworkAgent中的配置设置一个对整个应用生效的validResultBlock.
    if (nil == _customValidResultBlock) {
        return [super validResultBlock];
    }
    
    return _customValidResultBlock;
}

- (void)customRequest:(NSMutableURLRequest *)request {
    if (nil == _customRequestBlock) {
        return [self customRequest:request];
    }
    
    __weak HTAutoBaseRequest *weakSelf = self;
    return _customRequestBlock(weakSelf, request);
}

#pragma mark - Frozen Requests

- (NSString *)freezeKey {
    if ([_customFreezeKey length] == 0) {
        return [super freezeKey];
    }
    
    return _customFreezeKey;
}

- (NSString *)freezeKeyWithManager:(RKObjectManager *)mananger {
    if (nil == _freezeKeyBlock) {
        return [super freezeKeyWithManager:mananger];
    }
    
    __weak HTAutoBaseRequest *weakSelf = self;
    return _freezeKeyBlock(weakSelf, mananger);
}

#pragma mark - Auto Generated Code

// 该方法的实现允许Request子类将子类的属性转换成为JSON对象或者JSON字符串.
+ (NSArray *)modelPropertyBlacklist {
    return [[[HTAutoBaseRequest class] ht_allPropertyInfoDic] allKeys];
}

@end
