//
//  RKObjectManager+HTRAC.h
//  HTHttp
//
//  Created by Wang Liping on 15/9/7.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import <RestKit/Network/RKObjectManager.h>

@class RACSignal;

@interface RKObjectManager (HTRAC)

/**
 *  获取与getObject方法对应的Signal.
 *
 *  @param object The object with which to construct the object request operation. If `nil`, then the path must be provided.
 *  @param path The path to be appended to the RKRequestProvider's base URL and used as the request URL. If nil, the request URL will be obtained by consulting the router for a route registered for the given object's class and the `RKRequestMethodGET` request method.
 *  @param parameters The parameters to be encoded and appended as the query string for the request URL.
 *
 *  @return RACSignal对象.
 */
- (RACSignal *)rac_getObject:(id)object
                        path:(NSString *)path
                  parameters:(NSDictionary *)parameters;

/**
 *  获取与getObject方法对应的Signal.
 *
 *  @param path The path to be appended to the RKRequestProvider's base URL and used as the request URL. If nil, the request URL will be obtained by consulting the router for a route registered for the given object's class and the `RKRequestMethodGET` request method.
 *  @param parameters The parameters to be encoded and appended as the query string for the request URL.
 *
 *  @return RACSignal对象.
 */
- (RACSignal *)rac_getObjectsAtPath:(NSString *)path
                         parameters:(NSDictionary *)parameters;

/**
 *  获取与postObject方法对应的Signal.
 *
 *  @param object The object with which to construct the object request operation. If `nil`, then the path must be provided.
 *  @param path The path to be appended to the RKRequestProvider's base URL and used as the request URL. If nil, the request URL will be obtained by consulting the router for a route registered for the given object's class and the `RKRequestMethodGET` request method.
 *  @param parameters The parameters to be encoded and appended as the query string for the request URL.
 *
 *  @return RACSignal对象.
 */
- (RACSignal *)rac_postObject:(id)object
                        path:(NSString *)path
                  parameters:(NSDictionary *)parameters;

/**
 *  获取与putObject方法对应的Signal.
 *
 *  @param object The object with which to construct the object request operation. If `nil`, then the path must be provided.
 *  @param path The path to be appended to the RKRequestProvider's base URL and used as the request URL. If nil, the request URL will be obtained by consulting the router for a route registered for the given object's class and the `RKRequestMethodGET` request method.
 *  @param parameters The parameters to be encoded and appended as the query string for the request URL.
 *
 *  @return RACSignal对象.
 */
- (RACSignal *)rac_putObject:(id)object
                        path:(NSString *)path
                  parameters:(NSDictionary *)parameters;

/**
 *  获取与deleteObject方法对应的Signal.
 *
 *  @param object The object with which to construct the object request operation. If `nil`, then the path must be provided.
 *  @param path The path to be appended to the RKRequestProvider's base URL and used as the request URL. If nil, the request URL will be obtained by consulting the router for a route registered for the given object's class and the `RKRequestMethodGET` request method.
 *  @param parameters The parameters to be encoded and appended as the query string for the request URL.
 *
 *  @return RACSignal对象.
 */
- (RACSignal *)rac_deleteObject:(id)object
                        path:(NSString *)path
                  parameters:(NSDictionary *)parameters;

/**
 *  获取与patchObject方法对应的Signal.
 *
 *  @param object The object with which to construct the object request operation. If `nil`, then the path must be provided.
 *  @param path The path to be appended to the RKRequestProvider's base URL and used as the request URL. If nil, the request URL will be obtained by consulting the router for a route registered for the given object's class and the `RKRequestMethodGET` request method.
 *  @param parameters The parameters to be encoded and appended as the query string for the request URL.
 *
 *  @return RACSignal对象.
 */
- (RACSignal *)rac_patchObject:(id)object
                        path:(NSString *)path
                  parameters:(NSDictionary *)parameters;

/**
 *  创建RKObjectRequestOperation对象并获取对应的Signal.
 *
 * @param object The object with which to construct the object request operation. If `nil`, then the path must be provided.
 * @param path The path to be appended to the RKRequestProvider's base URL and used as the request URL. If nil, the request URL will be obtained by consulting the router for a route registered for the given object's class and the `RKRequestMethodGET` request method.
 * @param parameters The parameters to be encoded and appended as the query string for the request URL.
 *
 *  @return 返回RACSignal对象.
 */
- (RACSignal *)rac_operationWithObject:(id)object
                                method:(RKRequestMethod)method
                                  path:(NSString *)path
                            parameters:(NSDictionary *)parameters;

/**
 *  创建RKObjectRequestOperation对象并获取对应的Signal.
 *
 * @param object The object with which to construct the object request operation. If `nil`, then the path must be provided.
 * @param method The request method for the request.
 * @param path The path to be appended to the RKRequestProvider's base URL and used as the request URL. If nil, the request URL will be obtained by consulting the router for a route registered for the given object's class and the `RKRequestMethodGET` request method.
 * @param parameters The parameters to be encoded and appended as the query string for the request URL.
 * @param retryCount 重试次数.
 *
 *  @return 返回RACSignal对象.
 */
- (RACSignal *)rac_operationWithObject:(id)object
                                method:(RKRequestMethod)method
                                  path:(NSString *)path
                            parameters:(NSDictionary *)parameters
                            retryCount:(NSInteger)retryCount;

/**
 *  创建一个Signal, 每次Signal订阅时都会创建新的RKObjectRequestOperation对象并发送请求. 该信号存在副作用. 如果希望订阅信号后不产生副作用，请使用replay后的信号.
 *  RACSignal *signal = [self rac_startNewOperationWithObject:object method:method path:path parameters:parameters];
 *  RACSignal *signalWithNoSideEffect = [signal replay];
 *  [signalWithNoSideEffect subscribeNext:^(id x) { } error:^(NSError *error) { } completed:^{}];
 *
 * @param object The object with which to construct the object request operation. If `nil`, then the path must be provided.
 * @param method The request method for the request.
 * @param path The path to be appended to the RKRequestProvider's base URL and used as the request URL. If nil, the request URL will be obtained by consulting the router for a route registered for the given object's class and the `RKRequestMethodGET` request method.
 * @param parameters The parameters to be encoded and appended as the query string for the request URL.
 *
 *  @return 返回RACSignal对象.
 */
- (RACSignal *)rac_startNewOperationWithObject:(id)object
                                        method:(RKRequestMethod)method
                                          path:(NSString *)path
                                    parameters:(NSDictionary *)parameters;

@end
