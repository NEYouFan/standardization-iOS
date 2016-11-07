//
//  NSURLResponse+HTCache.m
//  Pods
//
//  Created by Wangliping on 15/12/30.
//
//

#import "NSURLResponse+HTCache.h"
#import <objc/runtime.h>

static const void *keyHTIsFromCache = &keyHTIsFromCache;

@implementation NSURLResponse (HTCache)

- (BOOL)ht_isFromCache {
    NSNumber *object = objc_getAssociatedObject(self, keyHTIsFromCache);
    return object.boolValue;
}

- (void)setHt_isFromCache:(BOOL)isFromCache {
    objc_setAssociatedObject(self, keyHTIsFromCache, @(isFromCache), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
