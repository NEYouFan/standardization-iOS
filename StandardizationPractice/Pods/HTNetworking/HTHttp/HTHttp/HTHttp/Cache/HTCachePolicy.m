//
//  HTCachePolicy.m
//  HTHttp
//
//  Created by NetEase on 15/8/13.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "HTCachePolicy.h"
#import "RKHTTPRequestOperation.h"

@implementation HTCachePolicy

+ (BOOL)hasCacheForRequest:(RKHTTPRequestOperation *)requestOperation {
    return NO;
}

+ (NSCachedURLResponse *)cachedResponseForRequest:(RKHTTPRequestOperation *)requestOperation {
    return nil;
}

@end
