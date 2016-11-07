//
//  HTBaseRequest+SendRequest.m
//  HTHttp
//
//  Created by Wangliping on 16/4/12.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import <HTHttp/Core/HTBaseRequest+Advanced.h>
#import "HTBaseRequest.h"
#import "NSURLRequest+HTCache.h"
#import "NSURLRequest+HTFreeze.h"
#import "NSURLRequest+RKRequest.h"
#import <HTHttp/Core/NSURLRequest+HTMock.h>
#import "RKObjectManager.h"
#import "HTCachePolicyManager.h"
#import "HTFreezePolicyMananger.h"
#import <HTHttp/Core/HTHTTPRequestOperation.h>
#import <HTHttp/Core/HTMockHTTPRequestOperation.h>
#import "HTHttpLog.h"

@interface HTBaseRequest ()

@property (nonatomic, strong, readwrite) RKObjectRequestOperation *requestOperation;

@end

@implementation HTBaseRequest (Advanced)

#pragma mark - Mock Test

+ (void)enableMockTest {
    [self enableMockTestInManager:[self objectManager]];
}

+ (void)disableMockTest {
    [self disableMockTestInManager:[self objectManager]];
}

+ (void)enableMockTestInManager:(RKObjectManager *)manager {
    [manager unregisterRequestOperationClass:[HTHTTPRequestOperation class]];
    [manager registerRequestOperationClass:[HTMockHTTPRequestOperation class]];
}

+ (void)disableMockTestInManager:(RKObjectManager *)manager {
    [manager unregisterRequestOperationClass:[HTHTTPRequestOperation class]];
    [manager registerRequestOperationClass:[HTMockHTTPRequestOperation class]];
}

#pragma mark - Support Multi Object Managers

+ (void)registerInMananger:(RKObjectManager *)manager {
    if (nil == manager) {
        return;
    }
    
    NSArray<RKResponseDescriptor *> *responseDescriptorList = [self responseDescriptors];
    for (RKResponseDescriptor *responseDescriptor in responseDescriptorList) {
        [manager addResponseDescriptor:responseDescriptor];
    }
    
    RKRequestDescriptor *requestDescriptor = [self requestDescriptor];
    if (nil != requestDescriptor) {
        [manager addRequestDescriptor:requestDescriptor];
    }
}

@end
