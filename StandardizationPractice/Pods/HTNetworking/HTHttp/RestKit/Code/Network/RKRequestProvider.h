//
//  RKRequestProvider.h
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
#import <Foundation/Foundation.h>
#import "AFURLConnectionOperation.h"

#import <Availability.h>

/**

 `RKRequestProvider`提供Request的创建，RestKit中所有request的创建都是通过RKRequestProvider来获取到; 此外还提供与RKRequestProvider创建请求有关的配置.
 
 
 `RKRequestProvider` captures the common patterns of communicating with an web application over HTTP. It encapsulates information like base URL, authorization credentials, and HTTP headers, and uses them to construct and manage the execution of HTTP request operations.
 
 ## Automatic Content Parsing
 
 Instances of `RKRequestProvider` may specify which types of requests it expects and should handle by registering HTTP operation classes for automatic parsing. Registered classes will determine whether they can handle a particular request, and then construct a request operation accordingly in `enqueueHTTPRequestOperationWithRequest:success:failure`.
 
 ## Default Headers
 
 By default, `RKRequestProvider` sets the following HTTP headers:
 
 - `Accept-Language: (comma-delimited preferred languages), en-us;q=0.8`
 - `User-Agent: (generated user agent)`
 
 You can override these HTTP headers or define new ones using `setDefaultHeader:value:`.
 
 ## URL Construction Using Relative Paths
 
 Both `-requestWithMethod:path:parameters:` and `-multipartFormRequestWithMethod:path:parameters:constructingBodyWithBlock:` construct URLs from the path relative to the `-baseURL`, using `NSURL +URLWithString:relativeToURL:`. Below are a few examples of how `baseURL` and relative paths interact:
 
 NSURL *baseURL = [NSURL URLWithString:@"http://example.com/v1/"];
 [NSURL URLWithString:@"foo" relativeToURL:baseURL];                  // http://example.com/v1/foo
 [NSURL URLWithString:@"foo?bar=baz" relativeToURL:baseURL];          // http://example.com/v1/foo?bar=baz
 [NSURL URLWithString:@"/foo" relativeToURL:baseURL];                 // http://example.com/foo
 [NSURL URLWithString:@"foo/" relativeToURL:baseURL];                 // http://example.com/v1/foo
 [NSURL URLWithString:@"/foo/" relativeToURL:baseURL];                // http://example.com/foo/
 [NSURL URLWithString:@"http://example2.com/" relativeToURL:baseURL]; // http://example2.com/
 
 Also important to note is that a trailing slash will be added to any `baseURL` without one, which would otherwise cause unexpected behavior when constructing URLs using paths without a leading slash.
 
 ## NSCoding / NSCopying Conformance
 
 `RKRequestProvider`  conforms to the `NSCoding` and `NSCopying` protocols, allowing operations to be archived to disk, and copied in memory, respectively. There are a few minor caveats to keep in mind, however:
 */

#ifndef __UTTYPE__
#if __IPHONE_OS_VERSION_MIN_REQUIRED
#pragma message("MobileCoreServices framework not found in project, or not included in precompiled header. Automatic MIME type detection when uploading files in multipart requests will not be available.")
#else
#pragma message("CoreServices framework not found in project, or not included in precompiled header. Automatic MIME type detection when uploading files in multipart requests will not be available.")
#endif
#endif

typedef enum {
    RKFormURLParameterEncoding,
    RKJSONParameterEncoding,
    RKPropertyListParameterEncoding,
} RKRequestProviderParameterEncoding;

@protocol AFMultipartFormData;

@protocol RKRequestProviderConfigDelegate <NSObject>

@optional

- (NSURLRequest *)customRequest:(NSURLRequest *)request;

@end

@interface RKRequestProvider : NSObject <NSCoding, NSCopying>

///---------------------------------------
/// @name Accessing Request Provider Properties
///---------------------------------------

/**
 The url used as the base for paths specified in methods such as `getPath:parameters:success:failure`
 */
@property (readwrite, nonatomic, strong) NSURL *baseURL;

/**
 The string encoding used in constructing url requests. This is `NSUTF8StringEncoding` by default.
 */
@property (nonatomic, assign) NSStringEncoding stringEncoding;

/**
 The `RKRequestProviderParameterEncoding` value corresponding to how parameters are encoded into a request body for request methods other than `GET`, `HEAD` or `DELETE`. This is `AFFormURLParameterEncoding` by default.
 
 @warning Some nested parameter structures, such as a keyed array of hashes containing inconsistent keys (i.e. `@{@"": @[@{@"a" : @(1)}, @{@"b" : @(2)}]}`), cannot be unambiguously represented in query strings. It is strongly recommended that an unambiguous encoding, such as `AFJSONParameterEncoding`, is used when posting complicated or nondeterministic parameter structures.
 */
@property (nonatomic, assign) RKRequestProviderParameterEncoding parameterEncoding;

/**
 default timeout for creating a HTTP Request.
 */
@property (nonatomic, assign) NSTimeInterval defaultTimeout;

/**
 The security policy used by created request operations to evaluate server trust for secure connections. `AFURLSessionManager` uses the `defaultPolicy` unless otherwise specified.
 */
@property (nonatomic, strong) AFSecurityPolicy *securityPolicy;

/**
 The default URL credential to be set for request operations.
 
 @param credential The URL credential
 */
@property (nonatomic, strong) NSURLCredential *defaultCredential;

/**
default headers for creating a HTTP Request.
 */
@property (nonatomic, strong) NSDictionary *defaultHeaders;

/**
 default parameters for creating a HTTP Request.
 */
@property (nonatomic, strong) NSDictionary *defaultParams;

///---------------------------------------------
/// @name Creating and Initializing Request Provider
///---------------------------------------------

/**
 Creates and initializes an `RKRequestProvider` object with the specified base URL.
 
 @param url The base URL for the RequestProvider. This argument must not be `nil`.
 
 @return The newly-initialized RequestProvider
 */
+ (instancetype)requestProviderWithBaseURL:(NSURL *)url;

/**
 Initializes an `RKRequestProvider` object with the specified base URL.
 
 This is the designated initializer.
 
 @param url The base URL for the RequestProvider. This argument must not be `nil`.
 
 @return The newly-initialized RequestProvider
 */
- (instancetype)initWithBaseURL:(NSURL *)url;

///----------------------------------
/// @name Managing HTTP Header Values
///----------------------------------

/**
 Returns the value for the HTTP headers set in request objects created by the RequestProvider.
 
 @param header The HTTP header to return the default value for
 
 @return The default value for the HTTP header, or `nil` if unspecified
 */
- (NSString *)defaultValueForHeader:(NSString *)header;

/**
 Sets the value for the HTTP headers set in request objects made by the RequestProvider. If `nil`, removes the existing value for that header.
 
 @param header The HTTP header to set a default value for
 @param value The value set as default for the specified header, or `nil
 */
- (void)setDefaultHeader:(NSString *)header
                   value:(NSString *)value;


/**
 Add HTTP headers set in request objects made by the RequestProvider.
 Previous set HTTP Headers, including default HTTP Headers set by framework, will be kept or replaced but won't be removed.
 
 @param default headers users want to add.
 */
- (void)addDefaultHeaders:(NSDictionary *)userDefaultHeaders;

/**
 Sets the "Authorization" HTTP header set in request objects made by the RequestProvider to a basic authentication value with Base64-encoded username and password. This overwrites any existing value for this header.
 
 @param username The HTTP basic auth username
 @param password The HTTP basic auth password
 */
- (void)setAuthorizationHeaderWithUsername:(NSString *)username
                                  password:(NSString *)password;

/**
 Sets the "Authorization" HTTP header set in request objects made by the RequestProvider to a token-based authentication value, such as an OAuth access token. This overwrites any existing value for this header.
 
 @param token The authentication token
 */
- (void)setAuthorizationHeaderWithToken:(NSString *)token;


/**
 Clears any existing value for the "Authorization" HTTP header.
 */
- (void)clearAuthorizationHeader;


///-------------------------------
/// @name Creating Request Objects
///-------------------------------

/**
 Creates an `NSMutableURLRequest` object with the specified HTTP method and path.
 
 If the HTTP method is `GET`, `HEAD`, or `DELETE`, the parameters will be used to construct a url-encoded query string that is appended to the request's URL. Otherwise, the parameters will be encoded according to the value of the `parameterEncoding` property, and set as the request body.
 
 @param method The HTTP method for the request, such as `GET`, `POST`, `PUT`, or `DELETE`. This parameter must not be `nil`.
 @param path The path to be appended to the RequestProvider's base URL and used as the request URL. If `nil`, no path will be appended to the base URL.
 @param parameters The parameters to be either set as a query string for `GET` requests, or the request HTTP body.
 
 @return An `NSMutableURLRequest` object
 */
- (NSMutableURLRequest *)requestWithMethod:(NSString *)method
                                      path:(NSString *)path
                                parameters:(NSDictionary *)parameters;

/**
 Creates an `NSMutableURLRequest` object with the specified HTTP method and path, and constructs a `multipart/form-data` HTTP body, using the specified parameters and multipart form data block. See http://www.w3.org/TR/html4/interact/forms.html#h-17.13.4.2
 
 Multipart form requests are automatically streamed, reading files directly from disk along with in-memory data in a single HTTP body. The resulting `NSMutableURLRequest` object has an `HTTPBodyStream` property, so refrain from setting `HTTPBodyStream` or `HTTPBody` on this request object, as it will clear out the multipart form body stream.
 
 @param method The HTTP method for the request. This parameter must not be `GET` or `HEAD`, or `nil`.
 @param path The path to be appended to the RequestProvider's base URL and used as the request URL.
 @param parameters The parameters to be encoded and set in the request HTTP body.
 @param block A block that takes a single argument and appends data to the HTTP body. The block argument is an object adopting the `AFMultipartFormData` protocol. This can be used to upload files, encode HTTP body as JSON or XML, or specify multiple values for the same parameter, as one might for array values.
 
 @return An `NSMutableURLRequest` object
 */
- (NSMutableURLRequest *)multipartFormRequestWithMethod:(NSString *)method
                                                   path:(NSString *)path
                                             parameters:(NSDictionary *)parameters
                              constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block;


@end
