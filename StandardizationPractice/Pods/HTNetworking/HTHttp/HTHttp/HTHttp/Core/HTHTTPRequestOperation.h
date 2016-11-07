//
//  HTHTTPReqeustOperation.h
//  HTHttp
//
//  Created by NetEase on 15/7/24.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import <RestKit/Network/RKHTTPRequestOperation.h>

extern NSString * const HTResponseFromCacheUserInfoKey;
extern NSString * const HTResponseCacheVersionUserInfoKey;
extern NSString * const HTResponseCacheExpireTimeUserInfoKey;

/**
 *  用于支持Cache的RequestOperation类. 如果要支持Cache功能，要么显式创建HTHTTPRequestOperation对象，要么在使用前通过[objectManager registerRequestOperationClass:[HTHTTPRequestOperation class]];注册该类.
 */
@interface HTHTTPRequestOperation : RKHTTPRequestOperation

/**
 resonse是否从Cache中取得.
 
 默认为NO.
 */

@property (nonatomic, assign, readonly) BOOL isResponseFromCache;


@end
