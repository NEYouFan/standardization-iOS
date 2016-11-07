//
//  RKHTTPRequestOperationProtocol.h
//  Pods
//
//  Created by Wang Liping on 15/9/29.
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

#import <Foundation/Foundation.h>

@protocol RKHTTPRequestOperationProtocol <NSObject, NSCopying, NSCoding>

@required

/**
 Initializes and returns a newly allocated operation object with a url connection configured with the specified url request.
 
 This is the designated initializer.
 
 @param urlRequest The request object to be used by the operation connection.
 */
- (instancetype)initWithRequest:(NSURLRequest *)urlRequest;

/**
 Pauses the execution of the request operation.
 
 A paused operation returns `NO` for `-isReady`, `-isExecuting`, and `-isFinished`. As such, it will remain in an `NSOperationQueue` until it is either cancelled or resumed. Pausing a finished, cancelled, or paused operation has no effect.
 */
- (void)pause;

/**
 Whether the request operation is currently paused.
 
 @return `YES` if the operation is currently paused, otherwise `NO`.
 */
- (BOOL)isPaused;

/**
 Resumes the execution of the paused request operation.
 
 Pause/Resume behavior varies depending on the underlying implementation for the operation class. In its base implementation, resuming a paused requests restarts the original request. However, since HTTP defines a specification for how to request a specific content range, `AFHTTPRequestOperation` will resume downloading the request from where it left off, instead of restarting the original request.
 */
- (void)resume;

/**
 *  Start the request operation.
 */
- (void)start;

/**
 *  同步等待直到任务结束.
 */
- (void)waitUntilFinished;

/**
 *  Cancel the request operation.
 */
- (void)cancel;

/**
 *  不需启动Operation, 直接结束流程，调用必要的回调.
 */
- (void)finishWithoutStarting;

/**
 *  Return whether the operation is cancelled.
 */
@property (readonly, getter=isCancelled) BOOL cancelled;

/**
 *  Return whether the operation is finished.
 */
@property (readonly, getter=isFinished) BOOL finished;

/**
 *  Return whether the operation is executing.
 */
@property (readonly, getter=isExecuting) BOOL executing;

/**
 *  Return whether the operation is ready.
 */
@property (readonly, getter=isReady) BOOL ready;

///-----------------------------------------
/// @name Getting URL Connection Information
///-----------------------------------------

/**
 The request used by the operation's connection.
 */

@property (readonly, nonatomic, strong) NSURLRequest *request;

/**
 The last response received by the operation's connection.
 */
//@property (readonly, nonatomic, strong) NSURLResponse *response;

/**
 The error, if any, that occurred in the lifecycle of the request.
 */
@property (readonly, nonatomic, strong) NSError *error;

///----------------------------
/// @name Getting Response Data
///----------------------------

/**
 The data received during the request.
 */
@property (readonly, nonatomic, strong) NSData *responseData;

/**
 The string representation of the response data.
 */
@property (readonly, nonatomic, copy) NSString *responseString;

///------------------------------------------------------------
/// @name AFHTTPRequestOperation "Getting HTTP URL Connection Information"
///------------------------------------------------------------

/**
 The last HTTP response received by the operation's connection.
 */
@property (readonly, nonatomic, strong) NSHTTPURLResponse *response;


///---------------------------------
/// @name Managing Callback Queues
///---------------------------------

/**
 The dispatch queue for `completionBlock`. If `NULL` (default), the main queue is used.
 */
#if OS_OBJECT_HAVE_OBJC_SUPPORT
@property (nonatomic, strong) dispatch_queue_t completionQueue;
#else
@property (nonatomic, assign) dispatch_queue_t completionQueue;
#endif

/**
 The dispatch group for `completionBlock`. If `NULL` (default), a private dispatch group is used.
 */
#if OS_OBJECT_HAVE_OBJC_SUPPORT
@property (nonatomic, strong) dispatch_group_t completionGroup;
#else
@property (nonatomic, assign) dispatch_group_t completionGroup;
#endif

/**
 The credential used for authentication challenges in `-connection:didReceiveAuthenticationChallenge:`.
 
 This will be overridden by any shared credentials that exist for the username or password of the request URL, if present.
 */
@property (nonatomic, strong) NSURLCredential *credential;
//
/////-------------------------------
///// @name Managing Security Policy
/////-------------------------------
//
///**
// The security policy used to evaluate server trust for secure connections.
// */
//@property (nonatomic, strong) AFSecurityPolicy *securityPolicy;


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

@optional
// Note: 通常情况下回调时需要给出Operation本身，但是此处并不需要.
- (void)setHTTPCompletionBlockWithSuccess:(void (^)(id responseObject))success
                                  failure:(void (^)(NSError *error))failure;

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
