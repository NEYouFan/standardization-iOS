//
//  RKRequestTypeOperation.m
//  Pods
//
//  Created by Wangliping on 15/11/9.
//  Copyright (c) 2009-2012 RestKit. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
//  This file is added to RestKit by WangLiping to support different transfer protocol rather than HTTP/HTTPS.

#import "RKRequestTypeOperation.h"
#import "RKConcreteHTTPRequestOperation.h"
#import "RKRequestTypes.h"

@interface RKRequestTypeOperationRegistration : NSObject

@property (nonatomic, copy) NSString *requestType;
@property (nonatomic, assign) Class<RKHTTPRequestOperationProtocol> requestOperationClass;

@end

@implementation RKRequestTypeOperationRegistration

- (instancetype)initWithRequestType:(NSString *)requestType requestOperationClass:(Class<RKHTTPRequestOperationProtocol>)requestOperationClass
{
    NSParameterAssert(requestType);
    NSParameterAssert(requestOperationClass);
    
    self = [super init];
    if (self) {
        self.requestType = requestType;
        self.requestOperationClass = requestOperationClass;
    }
    
    return self;
}

- (BOOL)matchesRequestType:(NSString *)requestType {
    return NSOrderedSame == [_requestType caseInsensitiveCompare:requestType];
}

@end

@interface RKRequestTypeOperation ()

@property (nonatomic, strong) NSMutableArray *registrations;

@end

@implementation RKRequestTypeOperation

+ (RKRequestTypeOperation *)sharedInstance
{
    static RKRequestTypeOperation *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[RKRequestTypeOperation alloc] init];
        [sharedInstance addRegistrationsForKnownRequestTypes];
    });
    return sharedInstance;
    
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.registrations = [NSMutableArray new];
    }
    
    return self;
}

- (void)addRegistrationsForKnownRequestTypes {
    // HTTP Requests
    [self.registrations addObject:[[RKRequestTypeOperationRegistration alloc] initWithRequestType:RKRequestTypeHTTP
                                                                             requestOperationClass:[RKConcreteHTTPRequestOperation class]]];
}

#pragma mark - Public

+ (void)registerClass:(Class<RKHTTPRequestOperationProtocol>)requestOperationClass forRequestType:(NSString *)requestType {
    RKRequestTypeOperationRegistration *registration = [[RKRequestTypeOperationRegistration alloc] initWithRequestType:requestType requestOperationClass:requestOperationClass];
    [[self sharedInstance].registrations addObject:registration];
}

+ (void)unregisterClass:(Class<RKHTTPRequestOperationProtocol>)requestOperationClass {
    NSArray *registrationsCopy = [[self sharedInstance].registrations copy];
    for (RKRequestTypeOperationRegistration *registration in registrationsCopy) {
        if (registration.requestOperationClass == requestOperationClass) {
            [[self sharedInstance].registrations removeObject:registration];
        }
    }
}

+ (Class<RKHTTPRequestOperationProtocol>)operationForRequestType:(NSString *)requestType {
    for (RKRequestTypeOperationRegistration *registration in [[self sharedInstance].registrations reverseObjectEnumerator]) {
        if ([registration matchesRequestType:requestType]) {
            return registration.requestOperationClass;
        }
    }
    return nil;
}

+ (NSSet *)registeredRequestTypes {
    return [NSSet setWithArray:[[self sharedInstance].registrations valueForKey:@"requestType"]];
}

@end
