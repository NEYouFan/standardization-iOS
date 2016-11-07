//
//  RKRequestTypeOperation.h
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

#import <Foundation/Foundation.h>
#import "RKHTTPRequestOperationProtocol.h"

@interface RKRequestTypeOperation : NSObject

/**
 *  注册针对类型requestType的发送类.
 *
 *  @param requestOperationClass 实际发送请求的类.
 *  @param requestType           请求类型名.
 */
+ (void)registerClass:(Class<RKHTTPRequestOperationProtocol>)requestOperationClass forRequestType:(NSString *)requestType;

/**
 *  反注册发送请求的类.
 *
 *  @param requestOperationClass 实际发送请求的类.
 */
+ (void)unregisterClass:(Class<RKHTTPRequestOperationProtocol>)requestOperationClass;

/**
 *  获取用于发送某类请求的名字.
 *
 *  @param requestType 请求类型名.
 *
 *  @return 发送请求的类.
 */
+ (Class<RKHTTPRequestOperationProtocol>)operationForRequestType:(NSString *)requestType;

/**
 *  已注册的请求类型.
 *
 *  @return 返回一个字符串的集合.
 */
+ (NSSet *)registeredRequestTypes;

@end
