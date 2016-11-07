//
//  HTFreezePolicyRegistration.m
//  Pods
//
//  Created by Wangliping on 15/10/30.
//
//

#import "HTFreezePolicyRegistration.h"

@implementation HTFreezePolicyRegistration

- (instancetype)initWithPolicyId:(HTFreezePolicyId)policyId policyClass:(Class<HTFreezePolicyProtocol>)policyClass {
    self = [super init];
    if (self) {
        self.freezePolicyId = policyId;
        self.freezePolicyClass = policyClass;
    }
    
    return self;
}

@end
