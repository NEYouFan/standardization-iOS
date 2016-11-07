//
//  HTCachePolicyRegistration.h
//  HTHttp
//
//  Created by NetEase on 15/8/13.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTCachePolicy.h"

@interface HTCachePolicyRegistration : NSObject

@property (nonatomic, assign) HTCachePolicyId cachePolicyId;
@property (nonatomic, weak) Class<HTCachePolicyProtocol> cachePolicyClass;

/**
 *  初始化方法
 *
 *  @param policyId    策略Id
 *  @param policyClass 策略类
 *
 *  @return HTCachePolicyRegistration实例
 */
- (instancetype)initWithCachePolicyId:(HTCachePolicyId)policyId policyClass:(Class<HTCachePolicyProtocol>)policyClass NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

@end
