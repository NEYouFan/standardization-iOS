//
//  HTFreezePolicyRegistration.h
//  Pods
//
//  Created by Wangliping on 15/10/30.
//
//

#import <Foundation/Foundation.h>
#import "HTFreezePolicyProtocol.h"

@interface HTFreezePolicyRegistration : NSObject

@property (nonatomic, assign) HTFreezePolicyId freezePolicyId;
@property (nonatomic, weak) Class<HTFreezePolicyProtocol> freezePolicyClass;

/**
 *  初始化方法
 *
 *  @param policyId    策略Id
 *  @param policyClass 策略类
 *
 *  @return HTFreezePolicyRegistration实例
 */
- (instancetype)initWithPolicyId:(HTFreezePolicyId)policyId policyClass:(Class<HTFreezePolicyProtocol>)policyClass;


@end
