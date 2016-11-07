//
//  HTFreezePolicyMananger.m
//  Pods
//
//  Created by Wangliping on 15/10/30.
//
//

#import "HTFreezePolicyMananger.h"
#import "NSURLRequest+HTFreeze.h"
#import "HTFreezePolicy.h"
#import "HTFreezePolicyRegistration.h"
#import "HTFrozenRequest.h"

@interface HTFreezePolicyMananger ()

@property (nonatomic, strong) NSMutableArray *registrations;

@end

@implementation HTFreezePolicyMananger

+ (instancetype)sharedInstance {
    static HTFreezePolicyMananger *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[HTFreezePolicyMananger alloc] init];
    });
    
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self addKnownPolicyClasses];
    }
    
    return self;
}

- (void)addKnownPolicyClasses {
    self.registrations = [NSMutableArray array];
    [self registeFreezePolicyWithPolicyId:HTFreezePolicySendFreezeAutomatically policy:[HTFreezePolicy class]];
}

- (void)registeFreezePolicyWithPolicyId:(HTFreezePolicyId)policyId policy:(Class<HTFreezePolicyProtocol>)policy {
    HTFreezePolicyRegistration *registration = [[HTFreezePolicyRegistration alloc] initWithPolicyId:policyId policyClass:policy];
    [self.registrations addObject:registration];
}

- (void)removeFreezePolicy:(HTFreezePolicyId)policyId {
    NSArray *registrationsCopy = [_registrations copy];
    for (HTFreezePolicyRegistration *registration in registrationsCopy) {
        if (registration.freezePolicyId == policyId) {
            [_registrations removeObject:registration];
        }
    }
}

- (void)removeFreezePolicyClass:(Class<HTFreezePolicyProtocol>)policyClass {
    NSArray *registrationsCopy = [_registrations copy];
    for (HTFreezePolicyRegistration *registration in registrationsCopy) {
        if (registration.freezePolicyClass == policyClass) {
            [_registrations removeObject:registration];
        }
    }
}

- (Class<HTFreezePolicyProtocol>)policyWithId:(HTFreezePolicyId)policyId {
    for (HTFreezePolicyRegistration *registration in [_registrations reverseObjectEnumerator]) {
        if (registration.freezePolicyId == policyId) {
            return registration.freezePolicyClass;
        }
    }
    
    return nil;
}

- (Class<HTFreezePolicyProtocol>)freezePolicyClassForRequest:(HTFrozenRequest *)htFrozenRequest {
    HTFreezePolicyId policyId = htFrozenRequest.request.ht_freezePolicyId;
    Class<HTFreezePolicyProtocol> policyClass = [self policyWithId:policyId];
    return policyClass;
}

@end
