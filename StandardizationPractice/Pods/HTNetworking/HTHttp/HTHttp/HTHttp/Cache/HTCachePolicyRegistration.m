//
//  HTCachePolicyRegistration.m
//  HTHttp
//
//  Created by NetEase on 15/8/13.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "HTCachePolicyRegistration.h"

@implementation HTCachePolicyRegistration

- (instancetype)initWithCachePolicyId:(HTCachePolicyId)policyId policyClass:(Class<HTCachePolicyProtocol>)policyClass {
    self = [super init];
    if (self) {
        self.cachePolicyId = policyId;
        self.cachePolicyClass = policyClass;
    }
    
    return self;
}

@end
