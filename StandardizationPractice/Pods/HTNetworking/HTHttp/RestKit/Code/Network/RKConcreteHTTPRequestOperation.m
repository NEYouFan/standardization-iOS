//
//  RKConcreteHTTPRequestOperation.m
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
//  Main Modification: RKConcreteHTTPRequestOperation is similar with old RKHTTPRequestOperation which is responsible to send request via AFNetworking.

#import "RKConcreteHTTPRequestOperation.h"
#import "RKLog.h"
#import "lcl_RK.h"
#import "RKHTTPUtilities.h"
#import "RKMIMETypes.h"

extern NSString * const RKErrorDomain;

// Set Logging Component
#undef RKLogComponent
#define RKLogComponent RKlcl_cRestKitNetwork

NSString *RKStringFromIndexSet(NSIndexSet *indexSet); // Defined in RKResponseDescriptor.m

static BOOL RKResponseRequiresContentTypeMatch(NSHTTPURLResponse *response, NSURLRequest *request)
{
    if (RKRequestMethodFromString(request.HTTPMethod) == RKRequestMethodHEAD) return NO;
    if ([RKStatusCodesOfResponsesWithOptionalBodies() containsIndex:response.statusCode]) return NO;
    return YES;
}

@interface AFURLConnectionOperation () <NSURLConnectionDataDelegate>
@property (readwrite, nonatomic, strong) NSRecursiveLock *lock;

/**
 *  RestKit Unit Test
 */
- (void)operationDidStart;
@end

@interface RKConcreteHTTPRequestOperation ()
@property (readwrite, nonatomic, strong) NSError *rkHTTPError;
@end

@implementation RKConcreteHTTPRequestOperation

+ (BOOL)canProcessRequest:(NSURLRequest *)request
{
    return YES;
}

- (void)setResponseSerializer:(AFHTTPResponseSerializer <AFURLResponseSerialization> *)responseSerializer {
    // Modify RestKit by LWANG: Nothing need to be done as RestKit doesn't need any response serializer at all.
}

- (BOOL)hasAcceptableStatusCode
{
    if (!self.response) {
        return NO;
    }
    
    NSUInteger statusCode = ([self.response isKindOfClass:[NSHTTPURLResponse class]]) ? (NSUInteger)[self.response statusCode] : 200;
    if (self.acceptableStatusCodes) {
        return [self.acceptableStatusCodes containsIndex:statusCode];
    }
    
    return YES;
}

- (BOOL)hasAcceptableContentType
{
    if (!self.response) {
        return NO;
    }
    
    if (!RKResponseRequiresContentTypeMatch(self.response, self.request)) {
        return YES;
    }
    
    NSString *contentType = [self.response MIMEType] ?: @"application/octet-stream";
    if (self.acceptableContentTypes) {
        return RKMIMETypeInSet(contentType, self.acceptableContentTypes);
    }
    
    if (self.acceptableContentTypes) {
        return RKMIMETypeInSet(contentType, self.acceptableContentTypes);
    }
    
    return YES;
}

// NOTE: We reimplement this because the AFNetworking implementation keeps Acceptable Status Code/MIME Type at class level
- (NSError *)error
{
    [self.lock lock];
    
    if (!self.rkHTTPError && self.response) {
        if (![self hasAcceptableStatusCode] || ![self hasAcceptableContentType]) {
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
            [userInfo setValue:self.responseString forKey:NSLocalizedRecoverySuggestionErrorKey];
            [userInfo setValue:[self.request URL] forKey:NSURLErrorFailingURLErrorKey];
            [userInfo setValue:self.request forKey:AFNetworkingOperationFailingURLRequestErrorKey];
            [userInfo setValue:self.response forKey:AFNetworkingOperationFailingURLResponseErrorKey];
            
            if (![self hasAcceptableStatusCode]) {
                NSUInteger statusCode = ([self.response isKindOfClass:[NSHTTPURLResponse class]]) ? (NSUInteger)[self.response statusCode] : 200;
                [userInfo setValue:[NSString stringWithFormat:NSLocalizedString(@"Expected status code in (%@), got %d", nil), RKStringFromIndexSet(self.acceptableStatusCodes ?: [NSMutableIndexSet indexSet]), statusCode] forKey:NSLocalizedDescriptionKey];
                self.rkHTTPError = [[NSError alloc] initWithDomain:RKErrorDomain code:NSURLErrorBadServerResponse userInfo:userInfo];
            } else if (![self hasAcceptableContentType] && self.response.statusCode != 204) {
                // NOTE: 204 responses come back as text/plain, which we don't want
                [userInfo setValue:[NSString stringWithFormat:NSLocalizedString(@"Expected content type %@, got %@", nil), self.acceptableContentTypes, [self.response MIMEType]] forKey:NSLocalizedDescriptionKey];
                self.rkHTTPError = [[NSError alloc] initWithDomain:RKErrorDomain code:NSURLErrorCannotDecodeContentData userInfo:userInfo];
            }
        }
    }
    
    // Note: 已经通过覆盖setResponseSerializer的方法正确处理了Error, 即当AFNetworking解析过程中认为Response无效时，仍然会进入RestKit的流程进行处理，解析出Error Message.
    NSError *error = self.rkHTTPError ?: [super error];
    [self.lock unlock];
    return error;
}

#pragma mark - Finish Operation

- (void)finishWithoutStarting {
    self.completionBlock();
}

#pragma mark - NSURLConnectionDelegate methods

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    [super connection:connection didReceiveAuthenticationChallenge:challenge];
    
    RKLogDebug(@"Received authentication challenge");
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse
{
    if ([AFHTTPRequestOperation instancesRespondToSelector:@selector(connection:willSendRequest:redirectResponse:)]) {
        NSURLRequest *returnValue = [super connection:connection willSendRequest:request redirectResponse:redirectResponse];
        if (returnValue) {
            if (redirectResponse) RKLogDebug(@"Following redirect request: %@", returnValue);
            return returnValue;
        } else {
            RKLogDebug(@"Not following redirect to %@", request);
            return nil;
        }
    } else {
        if (redirectResponse) RKLogDebug(@"Following redirect request: %@", request);
        return request;
    }
}

#pragma mark - Notification Name

+ (NSString *)httpRequestStartNotification {
    return AFNetworkingOperationDidStartNotification;
}

+ (NSString *)httpRequestEndNotification {
    return AFNetworkingOperationDidFinishNotification;
}

@end
