//
//  HTNetworking.h
//  HTHttp
//
//  Created by Wangliping on 16/4/11.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#ifndef HTNetworking_h
#define HTNetworking_h

#if __has_include("HTBaseRequest.h")
#import "HTBaseRequest.h"
#import "HTAutoBaseRequest.h"
#import "HTHTTPModel.h"
#import "NSObject+HTModel.h"
#import <HTHttp/Core/NSObject+HTMapping.h>
#import <HTHttp/Core/HTBaseRequest+Advanced.h>
#import <HTHttp/Core/HTBaseRequest+RACSupport.h>
#import <HTHttp/Cache/NSURLRequest+HTCache.h>
#import <HTHttp/Cache/NSURLResponse+HTCache.h>
#import <HTHttp/Freeze/NSURLRequest+HTFreeze.h>
#import <HTHttp/Core/HTNetworkingHelper.h>
#import <HTHttp/Core/HTMockURLResponse.h>
#endif

#if __has_include(<RestKit/RestKit.h>)
#import <RestKit/RestKit.h>
#endif

#if __has_include(<RestKit/Network/RKRequestTypeOperation.h>)
#import <RestKit/Network/RKRequestTypeOperation.h>
#endif

#if __has_include(<HTHttp/Support/HTHttpLog.h>)
#import <HTHttp/Support/HTHttpLog.h>
#endif

#if __has_include(<HTHttp/Cache/HTCacheManager.h>)
#import <HTHttp/Cache/HTCacheManager.h>
#import <HTHttp/Cache/HTCachePolicyManager.h>
#endif

#if __has_include(<ReactiveCocoa/ReactiveCocoa.h>)
#import <ReactiveCocoa/ReactiveCocoa.h>
#endif

#if __has_include(<HTHttp/Freeze/HTFreezeManager.h>)
#import <HTHttp/Freeze/HTFreezeManager.h>
#import <HTHttp/Freeze/HTFreezePolicy.h>
#import <HTHttp/Freeze/HTFreezePolicyMananger.h>
#endif

#endif /* HTNetworking_h */
