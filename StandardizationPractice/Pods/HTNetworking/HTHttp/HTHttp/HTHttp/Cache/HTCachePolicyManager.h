//
//  HTCachePolicyManager.h
//  HTHttp
//
//  Created by NetEase on 15/8/12.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTCachePolicy.h"

@class RKHTTPRequestOperation;

@interface HTCachePolicyManager : NSObject

+ (instancetype)sharedInstance;

/**
 *  根据requestOperation找到对应的处理Cache的策略类.
 *
 *  @param requestOperation 网络请求对应的Operation对象.
 *
 *  @return 返回与requestOperation对应的Cache策略类.
 */
- (Class<HTCachePolicyProtocol>)cachePolicyClassForRequest:(RKHTTPRequestOperation *)requestOperation;

/**
 *  注册处理Cache的策略类
 *
 *  @param policyId 策略Id.
 *  @param policy   策略类.
 */
- (void)registeCachePolicyWithPolicyId:(HTCachePolicyId)policyId policy:(Class<HTCachePolicyProtocol>)policy;

/**
 *  删除已注册的策略类.
 *
 *  @param policyClass 待移除的策略类.
 */
- (void)removeCahcePolicyClass:(Class<HTCachePolicyProtocol>)policyClass;

/**
 *  移除已注册的策略类.
 *
 *  @param policy 待移除的策略Id.
 */
- (void)removeCachePolicy:(HTCachePolicyId)policy;

@end
