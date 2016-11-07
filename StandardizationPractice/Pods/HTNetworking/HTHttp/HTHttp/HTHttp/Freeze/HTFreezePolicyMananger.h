//
//  HTFreezePolicyMananger.h
//  Pods
//
//  Created by Wangliping on 15/10/30.
//
//

#import <Foundation/Foundation.h>
#import "HTFreezePolicyProtocol.h"

@class HTFrozenRequest;

@interface HTFreezePolicyMananger : NSObject

+ (instancetype)sharedInstance;

/**
 *  根据request找到对应的策略类.
 *
 *  @param request 被冻结的网络请求对象.
 *
 *  @return 返回与request对应的策略类.
 */
- (Class<HTFreezePolicyProtocol>)freezePolicyClassForRequest:(HTFrozenRequest *)htFrozenRequest;

/**
 *  注册处理策略类
 *
 *  @param policyId 策略Id.
 *  @param policy   策略类.
 */
- (void)registeFreezePolicyWithPolicyId:(HTFreezePolicyId)policyId policy:(Class<HTFreezePolicyProtocol>)policy;

/**
 *  删除已注册的策略类.
 *
 *  @param policyClass 待移除的策略类.
 */
- (void)removeFreezePolicyClass:(Class<HTFreezePolicyProtocol>)policyClass;

/**
 *  移除已注册的策略类.
 *
 *  @param policy 待移除的策略Id.
 */
- (void)removeFreezePolicy:(HTFreezePolicyId)policy;


@end
