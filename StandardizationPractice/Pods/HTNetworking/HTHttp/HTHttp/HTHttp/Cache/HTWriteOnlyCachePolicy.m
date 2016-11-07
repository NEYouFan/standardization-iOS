//
//  HTWriteOnlyCachePolicy.m
//  Pods
//
//  Created by Wangliping on 15/11/16.
//
//

#import "HTWriteOnlyCachePolicy.h"

@implementation HTWriteOnlyCachePolicy

+ (BOOL)hasCacheForRequest:(RKHTTPRequestOperation *)requestOperation {
    return NO;
}

+ (NSCachedURLResponse *)cachedResponseForRequest:(RKHTTPRequestOperation *)requestOperation {
    return nil;
}


@end
