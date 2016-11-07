//
//  RKHTTPRequestOperation.m
//  RestKit
//
//  Created by Blake Watters on 8/7/12.
//  Copyright (c) 2012 RestKit. All rights reserved.
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
//  Modified by (Netease)Wangliping on 12/15/15.
//  Main Modification: RKHTTPRequestOperation does not derived from AFHTTPRequestOperation any more.

#import <RestKit/Network/RKHTTPRequestOperation.h>
#import <RestKit/Network/RKConcreteHTTPRequestOperation.h>
#import <RestKit/Network/RKHTTPRequestOperationProtocol.h>
#import <RestKit/Network/NSURLRequest+RKRequest.h>
#import <RestKit/Network/RKRequestTypeOperation.h>
#import <RestKit/Support/RKLog.h>

// Notification Definition converted from AFNetworkingOperationDidStartNotification.
NSString *const RKHTTPRequestOperationDidStartNotification = @"RKHTTPRequestOperationDidStartNotification";
NSString *const RKHTTPRequestOperationDidFinishNotification = @"RKHTTPRequestOperationDidFinishNotification";

@interface RKHTTPRequestOperation ()

@property (nonatomic, strong) id<RKHTTPRequestOperationProtocol> httpRequestOperation;
@property (nonatomic, strong) NSString *requestClassName;

@end

@implementation RKHTTPRequestOperation

@synthesize response = _response;
@synthesize responseData = _responseData;

#pragma mark - Life Cycle

- (instancetype)initWithRequest:(NSURLRequest *)urlRequest {
    self = [super init];
    if (self) {
        NSString *requestTypeName = @"";
        if ([urlRequest respondsToSelector:@selector(rk_requestTypeName)]) {
            requestTypeName = urlRequest.rk_requestTypeName;
        }
        
        Class requestClass = [requestTypeName length] > 0 ? [RKRequestTypeOperation operationForRequestType:requestTypeName] : nil;
        if (nil == requestClass) {
            // 默认情况下都使用RKConcreteHTTPRequestOperation发送请求.
            RKLogWarning(@"Could not find handle class for request type : %@", requestTypeName);
            requestClass = [RKConcreteHTTPRequestOperation class];
        }
        
        if (nil != requestClass) {
            // 保存_requestClassName是为了便于从持久化存储中读出operation时可以得到正确的request.
            _requestClassName = NSStringFromClass(requestClass);
        }
        
        _httpRequestOperation = [[requestClass alloc] initWithRequest:urlRequest];
        
        NSString *requestStartNotification = [requestClass httpRequestStartNotification];
        NSString *requestEndNofication = [requestClass httpRequestEndNotification];
        if ([requestStartNotification length] > 0) {
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(HTTPOperationDidStart:)
                                                         name:requestStartNotification
                                                       object:_httpRequestOperation];
            
        }
        
        if ([requestEndNofication length] > 0) {
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(HTTPOperationDidFinish:)
                                                         name:requestEndNofication
                                                       object:_httpRequestOperation];
        }
    }
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Notification Handle

- (void)HTTPOperationDidStart:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:RKHTTPRequestOperationDidStartNotification object:self];
}

- (void)HTTPOperationDidFinish:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:RKHTTPRequestOperationDidFinishNotification object:self];
}

#pragma mark - Operation Forward

// RKHTTPRequestOperation不是NSOperation的子类，所有相关的操作与启动都是通过httpRequestOperation来起作用.

- (void)pause {
    return [self.httpRequestOperation pause];
}

- (BOOL)isPaused {
    return [self.httpRequestOperation isPaused];
}

- (void)resume {
    return [self.httpRequestOperation resume];
}

- (void)start {
    return [self.httpRequestOperation start];
}

- (void)waitUntilFinished {
    return [self.httpRequestOperation waitUntilFinished];
}

- (void)cancel {
    return [self.httpRequestOperation cancel];
}

- (BOOL)isCancelled {
    return [self.httpRequestOperation isCancelled];
}

- (BOOL)isFinished {
    return [self.httpRequestOperation isFinished];
}

- (BOOL)isExecuting {
    return [self.httpRequestOperation isExecuting];
}

- (BOOL)isReady {
    return [self.httpRequestOperation isReady];
}

#pragma mark - AFHTTPRequestOperation Information

- (NSURLRequest *)request {
    return self.httpRequestOperation.request;
}

- (NSError *)error {
    return [self.httpRequestOperation error];
}

- (NSData *)responseData {
    // 如果外部设置了，那么不需要从httpRequestOperation获取.
    // 通常意味着从缓存中取response.
    if (nil != _responseData) {
        return _responseData;
    }
    
    return [self.httpRequestOperation responseData];
}

- (void)setResponseData:(NSData *)responseData {
    _responseData = responseData;
}

- (NSString *)responseString {
    return [self.httpRequestOperation responseString];
}

- (NSHTTPURLResponse *)response {
    // 如果外部设置了，那么不需要从httpRequestOperation获取.
    // 通常意味着从缓存中取response.
    if (nil != _response) {
        return _response;
    }
    
    return self.httpRequestOperation.response;
}

- (void)setResponse:(NSHTTPURLResponse *)response {
    _response = response;
}

#pragma mark - Callback

- (void)finishOperation {
    [self.httpRequestOperation finishWithoutStarting];
}

- (void)setCompletionQueue:(dispatch_queue_t)completionQueue {
    self.httpRequestOperation.completionQueue = completionQueue;
}

- (dispatch_queue_t)completionQueue {
    return self.httpRequestOperation.completionQueue;
}

- (void)setCompletionGroup:(dispatch_group_t)completionGroup {
    self.httpRequestOperation.completionGroup = completionGroup;
}

- (dispatch_group_t)completionGroup {
    return self.httpRequestOperation.completionGroup;
}

- (void)setCompletionBlockWithSuccess:(void (^)(RKHTTPRequestOperation *operation, id responseObject))success
                              failure:(void (^)(RKHTTPRequestOperation *operation, NSError *error))failure {
    if ([self.httpRequestOperation isKindOfClass:[RKConcreteHTTPRequestOperation class]]) {
        __weak __typeof(self)weakSelf = self;
        // 特殊处理. 此处由于AFHTTPReqeustOperation提供的接口是一定的，所以无法处理成为通用类型.
        return [(RKConcreteHTTPRequestOperation *)self.httpRequestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            success(weakSelf, responseObject);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            failure(weakSelf, error);
        }];
    } else if ([self.httpRequestOperation respondsToSelector:@selector(setHTTPCompletionBlockWithSuccess:failure:)]) {
        __weak __typeof(self)weakSelf = self;
        return [self.httpRequestOperation setHTTPCompletionBlockWithSuccess:^(id responseObject) {
            success(weakSelf, responseObject);
        } failure:^(NSError *error) {
            failure(weakSelf, error);
        }];
    }
}

+ (BOOL)canProcessRequest:(NSURLRequest *)request
{
    return YES;
}

#pragma mark - Properties

- (NSURLCredential *)credential {
    return self.httpRequestOperation.credential;
}

- (void)setCredential:(NSURLCredential *)credential {
    self.httpRequestOperation.credential = credential;
}

- (AFSecurityPolicy *)securityPolicy {
    // 特殊处理securityPolicy. 因为这是AFNetworking独有的并且不方便另外封装.
    if ([self.httpRequestOperation isKindOfClass:[AFHTTPRequestOperation class]]) {
         return ((AFHTTPRequestOperation *)self.httpRequestOperation).securityPolicy;
    }
    
    return nil;
}

- (void)setSecurityPolicy:(AFSecurityPolicy *)securityPolicy {
    // 特殊处理securityPolicy. 因为这是AFNetworking独有的并且不方便另外封装.
    if ([self.httpRequestOperation isKindOfClass:[AFHTTPRequestOperation class]]) {
        ((AFHTTPRequestOperation *)self.httpRequestOperation).securityPolicy = securityPolicy;
    }
}

- (NSIndexSet *)acceptableStatusCodes {
    return self.httpRequestOperation.acceptableStatusCodes;
}

- (void)setAcceptableStatusCodes:(NSIndexSet *)acceptableStatusCodes {
    self.httpRequestOperation.acceptableStatusCodes = acceptableStatusCodes;
}

- (NSSet *)acceptableContentTypes {
    return self.httpRequestOperation.acceptableContentTypes;
}

- (void)setAcceptableContentTypes:(NSSet *)acceptableContentTypes {
    self.httpRequestOperation.acceptableContentTypes = acceptableContentTypes;
}

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (id)initWithCoder:(NSCoder *)decoder {
    id<RKHTTPRequestOperationProtocol> operation = nil;
    NSString *requestClassName = [decoder decodeObjectOfClass:[NSString class] forKey:NSStringFromSelector(@selector(requestClassName))];
    if ([requestClassName length] > 0) {
        Class requestClass = NSClassFromString(requestClassName);
        if (nil != requestClass && [requestClass conformsToProtocol:@protocol(RKHTTPRequestOperationProtocol)]) {
            operation = [decoder decodeObjectOfClass:requestClass forKey:NSStringFromSelector(@selector(httpRequestOperation))];
        }
    }
    
    NSURLRequest *request = operation.request;
    self = [self initWithRequest:request];
    if (!self) {
        return nil;
    }
    
    self.httpRequestOperation = operation;
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.requestClassName forKey:NSStringFromSelector(@selector(requestClassName))];
    
    if ([self.httpRequestOperation respondsToSelector:@selector(encodeWithCoder:)]) {
        [self.httpRequestOperation encodeWithCoder:coder];
    }
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    RKHTTPRequestOperation *operation = [(RKHTTPRequestOperation *)[[self class] allocWithZone:zone] initWithRequest:self.request];
    if ([self.httpRequestOperation respondsToSelector:@selector(copyWithZone:)]) {
        operation.httpRequestOperation = [self.httpRequestOperation copyWithZone:zone];
    }
    
    return operation;
}

@end
