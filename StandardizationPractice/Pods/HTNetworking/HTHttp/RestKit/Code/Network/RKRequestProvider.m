//
//  RKRequestProvider.m
//  RestKit
//
//  Created by NetEase on 15/7/13.
//  Copyright (c) 2015年 RestKit. All rights reserved.
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
//  This file is added to RestKit by WangLiping to support creating different NSURLRequests.

#import <Foundation/Foundation.h>
#import <RestKit/Network/RKRequestProvider.h>
#import <Availability.h>

#ifdef _SYSTEMCONFIGURATION_H
#import <netinet/in.h>
#import <netinet6/in6.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>
#endif

#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
#import <UIKit/UIKit.h>
#endif

#pragma mark -

@interface RKRequestProvider ()

@property (readwrite, nonatomic, strong) AFHTTPRequestSerializer *requestSerializer;

@end

@implementation RKRequestProvider

+ (instancetype)requestProviderWithBaseURL:(NSURL *)url {
    return [[self alloc] initWithBaseURL:url];
}

- (instancetype)init {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"%@ Failed to call designated initializer. Invoke `initWithBaseURL:` instead.", NSStringFromClass([self class])] userInfo:nil];
}

- (instancetype)initWithBaseURL:(NSURL *)url {
    NSParameterAssert(url);
    
    self = [super init];
    if (!self) {
        return nil;
    }
    
    // Ensure terminal slash for baseURL path, so that NSURL +URLWithString:relativeToURL: works as expected
    if ([[url path] length] > 0 && ![[url absoluteString] hasSuffix:@"/"]) {
        url = [url URLByAppendingPathComponent:@""];
    }
    
    self.baseURL = url;
    
    // stringEncoding should take affect on requestSerializer otherwise RestKit is not able to create correct request if self.stringEncoding is modified.
    self.stringEncoding = NSUTF8StringEncoding;
    
    // It is unnecessary to create different requestSerializer for different parameterEncoding.
    // RestKit can handle parameters correctly but RKRequestProvider is not able to create same request as AFN 2.0.
    self.parameterEncoding = RKFormURLParameterEncoding;
    
    self.defaultHeaders = [NSDictionary dictionary];
    self.securityPolicy = [AFSecurityPolicy defaultPolicy];
    self.requestSerializer = [AFHTTPRequestSerializer serializer];
    NSAssert(self.requestSerializer.stringEncoding == NSUTF8StringEncoding, @"request serializer should have default stringEncoding NSUTF8StringEncoding as previous RKRequestProvider");
    
    // Accept-Language HTTP Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.4
    NSMutableArray *acceptLanguagesComponents = [NSMutableArray array];
    [[NSLocale preferredLanguages] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        float q = 1.0f - (idx * 0.1f);
        [acceptLanguagesComponents addObject:[NSString stringWithFormat:@"%@;q=%0.1g", obj, q]];
        *stop = q <= 0.5f;
    }];
    [self setDefaultHeader:@"Accept-Language" value:[acceptLanguagesComponents componentsJoinedByString:@", "]];
    
    NSString *userAgent = nil;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
    // User-Agent Header; see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.43
    userAgent = [NSString stringWithFormat:@"%@/%@ (%@; iOS %@; Scale/%0.2f)", [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleExecutableKey] ?: [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleIdentifierKey], (__bridge id)CFBundleGetValueForInfoDictionaryKey(CFBundleGetMainBundle(), kCFBundleVersionKey) ?: [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleVersionKey], [[UIDevice currentDevice] model], [[UIDevice currentDevice] systemVersion], ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] ? [[UIScreen mainScreen] scale] : 1.0f)];
#elif defined(__MAC_OS_X_VERSION_MIN_REQUIRED)
    userAgent = [NSString stringWithFormat:@"%@/%@ (Mac OS X %@)", [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleExecutableKey] ?: [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleIdentifierKey], [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] ?: [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleVersionKey], [[NSProcessInfo processInfo] operatingSystemVersionString]];
#endif
#pragma clang diagnostic pop
    if (userAgent) {
        if (![userAgent canBeConvertedToEncoding:NSASCIIStringEncoding]) {
            NSMutableString *mutableUserAgent = [userAgent mutableCopy];
            if (CFStringTransform((__bridge CFMutableStringRef)(mutableUserAgent), NULL, kCFStringTransformToLatin, false)) {
                userAgent = mutableUserAgent;
            }
        }
        [self setDefaultHeader:@"User-Agent" value:userAgent];
    }
    
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p, baseURL: %@, defaultHeaders: %@>", NSStringFromClass([self class]), self, [self.baseURL absoluteString], self.defaultHeaders];
}

#pragma mark - Properties which are used to config HTTP Requests

- (NSStringEncoding)stringEncoding {
    return self.requestSerializer.stringEncoding;
}

- (void)setStringEncoding:(NSStringEncoding)aStringEncoding {
    self.requestSerializer.stringEncoding = aStringEncoding;
}

- (NSTimeInterval)defaultTimeout {
    return self.requestSerializer.timeoutInterval;
}

- (void)setDefaultTimeout:(NSTimeInterval)defaultTimeout {
    self.requestSerializer.timeoutInterval = defaultTimeout;
}

- (NSDictionary *)defaultHeaders {
    return [self.requestSerializer HTTPRequestHeaders];
}

- (void)setDefaultHeaders:(NSDictionary *)defaultHeaders {
    if (0 == [defaultHeaders count] || [defaultHeaders isEqualToDictionary:self.defaultHeaders]) {
        // Don't clear previous default headers if new defaultHeaders is empty or equals with previous default headers.
        return;
    }
    
    // Clear previous default headers.
    for (NSString *key in [self defaultHeaders]) {
        [self setDefaultHeader:key value:nil];
    }
    
    // Add parameters as new default headers.
    [self addDefaultHeaders:defaultHeaders];
}

#pragma mark - Helper Methods to config HTTP Header

- (NSString *)defaultValueForHeader:(NSString *)header {
    return [self.requestSerializer valueForHTTPHeaderField:header];
}

- (void)setDefaultHeader:(NSString *)header value:(NSString *)value {
    [self.requestSerializer setValue:value forHTTPHeaderField:header];
}

- (void)addDefaultHeaders:(NSDictionary *)userDefaultHeaders {
    [userDefaultHeaders enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [self setDefaultHeader:key value:obj];
    }];
}

- (void)setAuthorizationHeaderWithUsername:(NSString *)username password:(NSString *)password {
    [self.requestSerializer setAuthorizationHeaderFieldWithUsername:username password:password];
}

- (void)setAuthorizationHeaderWithToken:(NSString *)token {
    [self.requestSerializer setValue:[NSString stringWithFormat:@"Token token=\"%@\"", token] forHTTPHeaderField:@"Authorization"];
}

- (void)clearAuthorizationHeader {
    [self.requestSerializer clearAuthorizationHeader];
}

#pragma mark - Create Requests

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method
                                      path:(NSString *)path
                                parameters:(NSDictionary *)parameters
{
    NSString *url = [[NSURL URLWithString:path relativeToURL:self.baseURL] absoluteString];
    return [self.requestSerializer requestWithMethod:method URLString:url parameters:parameters error:nil];
}

- (NSMutableURLRequest *)multipartFormRequestWithMethod:(NSString *)method
                                                   path:(NSString *)path
                                             parameters:(NSDictionary *)parameters
                              constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
{
    NSParameterAssert(method);
    NSParameterAssert(![method isEqualToString:@"GET"] && ![method isEqualToString:@"HEAD"]);
 
    NSString *url = [[NSURL URLWithString:path relativeToURL:self.baseURL] absoluteString];
    return [self.requestSerializer multipartFormRequestWithMethod:method URLString:url parameters:parameters constructingBodyWithBlock:block error:nil];
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder {
    NSURL *baseURL = [aDecoder decodeObjectForKey:@"baseURL"];
    
    self = [self initWithBaseURL:baseURL];
    if (!self) {
        return nil;
    }
    
    self.stringEncoding = [aDecoder decodeIntegerForKey:@"stringEncoding"];
    self.parameterEncoding = (RKRequestProviderParameterEncoding) [aDecoder decodeIntegerForKey:@"parameterEncoding"];
    self.defaultHeaders = [aDecoder decodeObjectForKey:@"defaultHeaders"];
    self.defaultParams = [aDecoder decodeObjectForKey:@"defaultParams"];
    self.defaultTimeout = [aDecoder decodeDoubleForKey:@"defaultTimeout"];
    self.defaultCredential = [aDecoder decodeObjectForKey:@"defaultCredential"];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.baseURL forKey:@"baseURL"];
    [aCoder encodeInteger:(NSInteger)self.stringEncoding forKey:@"stringEncoding"];
    [aCoder encodeInteger:self.parameterEncoding forKey:@"parameterEncoding"];
    [aCoder encodeObject:self.defaultHeaders forKey:@"defaultHeaders"];
    [aCoder encodeObject:self.defaultParams forKey:@"defaultParams"];
    [aCoder encodeDouble:self.defaultTimeout forKey:@"defaultTimeout"];
    [aCoder encodeObject:self.defaultCredential forKey:@"defaultCredential"];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    RKRequestProvider *requestProvider = [[[self class] allocWithZone:zone] initWithBaseURL:self.baseURL];
    
    requestProvider.stringEncoding = self.stringEncoding;
    requestProvider.parameterEncoding = self.parameterEncoding;
    requestProvider.defaultTimeout = self.defaultTimeout;
    requestProvider.defaultHeaders = [self.defaultHeaders mutableCopyWithZone:zone];
    requestProvider.defaultParams = [self.defaultParams mutableCopyWithZone:zone];
    requestProvider.defaultCredential = [self.defaultCredential copyWithZone:zone];
    return requestProvider;
}

@end
