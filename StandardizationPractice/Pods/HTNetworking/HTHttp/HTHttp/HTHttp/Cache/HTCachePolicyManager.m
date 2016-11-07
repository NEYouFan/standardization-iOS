//
//  HTCachePolicyManager.m
//  HTHttp
//
//  Created by NetEase on 15/8/12.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "HTCachePolicyManager.h"
#import "RKHTTPRequestOperation.h"
#import "NSURLRequest+HTCache.h"
#import "HTCachePolicy.h"
#import "HTDefaultCachePolicy.h"
#import "HTCachePolicyRegistration.h"
#import "HTWriteOnlyCachePolicy.h"

@interface HTCachePolicyManager ()

@property (nonatomic, strong) NSMutableArray *registrations;

@end

@implementation HTCachePolicyManager

+ (instancetype)sharedInstance {
    static HTCachePolicyManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[HTCachePolicyManager alloc] init];
    });
    
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self addKnownCachePolicyClasses];
    }
    
    return self;
}

- (void)addKnownCachePolicyClasses {
    self.registrations = [NSMutableArray array];
    [self registeCachePolicyWithPolicyId:HTCachePolicyCacheFirst policy:[HTDefaultCachePolicy class]];
    [self registeCachePolicyWithPolicyId:HTCachePolicyWriteOnly policy:[HTWriteOnlyCachePolicy class]];
}

- (void)registeCachePolicyWithPolicyId:(HTCachePolicyId)policyId policy:(Class<HTCachePolicyProtocol>)policy {
    HTCachePolicyRegistration *registration = [[HTCachePolicyRegistration alloc] initWithCachePolicyId:policyId policyClass:policy];
    [self.registrations addObject:registration];
}

- (void)removeCachePolicy:(HTCachePolicyId)policy {
    NSArray *registrationsCopy = [_registrations copy];
    for (HTCachePolicyRegistration *registration in registrationsCopy) {
        if (registration.cachePolicyId == policy) {
            [_registrations removeObject:registration];
        }
    }
}

- (void)removeCahcePolicyClass:(Class<HTCachePolicyProtocol>)policyClass {
    NSArray *registrationsCopy = [_registrations copy];
    for (HTCachePolicyRegistration *registration in registrationsCopy) {
        if (registration.cachePolicyClass == policyClass) {
            [_registrations removeObject:registration];
        }
    }
}

- (Class<HTCachePolicyProtocol>)policyWithId:(HTCachePolicyId)policyId {
    for (HTCachePolicyRegistration *registration in [_registrations reverseObjectEnumerator]) {
        if (registration.cachePolicyId == policyId) {
            return registration.cachePolicyClass;
        }
    }
    
    return nil;
}

- (Class<HTCachePolicyProtocol>)cachePolicyClassForRequest:(RKHTTPRequestOperation *)requestOperation {
    HTCachePolicyId cachePolicyId = requestOperation.request.ht_cachePolicy;
    Class<HTCachePolicyProtocol> policyClass = [self policyWithId:cachePolicyId];
    return policyClass;
}

@end
