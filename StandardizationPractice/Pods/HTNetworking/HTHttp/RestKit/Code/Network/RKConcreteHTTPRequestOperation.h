//
//  RKConcreteHTTPRequestOperation.h
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

#import <AFNetworking/AFHTTPRequestOperation.h>
#import <RestKit/Network/RKHTTPRequestOperationProtocol.h>

/**
 The `RKConcreteHTTPRequestOperation` class is a subclass of `AFHTTPRequestOperation` for HTTP or HTTPS requests made by RestKit. It provides per-instance configuration of the acceptable status codes and content types and integrates with the `RKLog` system to provide detailed requested and response logging. Instances of `RKHTTPRequest` are created by `RKObjectRequestOperation` and its subclasses to HTTP requests that will be object mapped. When used to make standalone HTTP requests, `RKHTTPRequestOperation` instance behave identically to `AFHTTPRequestOperation` with the exception of emitting logging information.
 
 ## Determining Request Processability
 
 The `RKConcreteHTTPRequestOperation` class diverges from the behavior of `AFHTTPRequestOperation` in the implementation of `canProcessRequest`, which is used to determine if a request can be processed. Because `RKConcreteHTTPRequestOperation` handles Content Type and Status Code acceptability at the instance rather than the class level, it by default returns `YES` when sent a `canProcessRequest:` method. Subclasses are encouraged to implement more specific logic if constraining the type of requests handled is desired.
 */
@interface RKConcreteHTTPRequestOperation : AFHTTPRequestOperation <RKHTTPRequestOperationProtocol>

///------------------------------------------------------------
/// @name Configuring Acceptable Status Codes and Content Types
///------------------------------------------------------------

/**
 The set of status codes which the operation considers successful.
 
 When `nil`, the acceptability of status codes is deferred to the superclass implementation.
 
 **Default**: `nil`
 */
@property (nonatomic, strong) NSIndexSet *acceptableStatusCodes;

/**
 The set of content types which the operation considers successful.
 
 The set may contain `NSString` or `NSRegularExpression` objects. When `nil`, the acceptability of content types is deferred to the superclass implementation.
 
 **Default**: `nil`
 */
@property (nonatomic, strong) NSSet *acceptableContentTypes;

/**
 *  HTTP请求开始时发出的通知名.
 *
 *  @return 返回一个字符串，表示使用该类发请求时，会通过NSNotificationCenter发送该通知.
 */
+ (NSString *)httpRequestStartNotification;

/**
 *  HTTP请求开始时发出的通知名.
 *
 *  @return 返回一个字符串，表示使用该类发请求完成时，会通过NSNotificationCenter发送该通知.
 */
+ (NSString *)httpRequestEndNotification;



@end
