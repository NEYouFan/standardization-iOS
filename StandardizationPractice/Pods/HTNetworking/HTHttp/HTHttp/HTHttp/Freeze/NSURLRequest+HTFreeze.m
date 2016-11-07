//
//  NSURLRequest+HTFreeze.m
//  Pods
//
//  Created by Wangliping on 15/10/29.
//
//

#import "NSURLRequest+HTFreeze.h"
#import "NSURLRequest+HTCache.h"
#import <objc/runtime.h>

const void *keyHTCanFreeze = &keyHTCanFreeze;
const void *keyHTIsFrozen = &keyHTIsFrozen;
const void *keyHTFreezePolicyId = &keyHTFreezePolicyId;
const void *keyHTFreezeId = &keyHTFreezeId;
const void *keyHTFreezeExpireTimeInterval = &keyHTFreezeExpireTimeInterval;

@implementation NSURLRequest (HTFreeze)

- (BOOL)ht_canFreeze {
    NSNumber *object = objc_getAssociatedObject(self, keyHTCanFreeze);
    return [object boolValue];
}

- (void)setHt_canFreeze:(BOOL)canFreeze {
    objc_setAssociatedObject(self, keyHTCanFreeze, @(canFreeze), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)ht_isFrozen {
    NSNumber *object = objc_getAssociatedObject(self, keyHTIsFrozen);
    return [object boolValue];
}

- (void)setHt_isFrozen:(BOOL)isFrozen {
    objc_setAssociatedObject(self, keyHTIsFrozen, @(isFrozen), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (HTFreezePolicyId)ht_freezePolicyId {
    NSNumber *object = objc_getAssociatedObject(self, keyHTFreezePolicyId);
    return (HTFreezePolicyId)[object integerValue];
}

- (void)setHt_freezePolicyId:(HTFreezePolicyId)freezePolicyId {
    objc_setAssociatedObject(self, keyHTFreezePolicyId, @(freezePolicyId), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)ht_freezeId {
    NSString *freezeId = objc_getAssociatedObject(self, keyHTFreezeId);
    if (0 == [freezeId length]) {
        freezeId = [self ht_defaultFreezeId];
        if (0 != [freezeId length]) {
            // 存起来避免重复计算.
            // 忽略Request属性被修改后，cache需要重新计算的情形.
            // 原因: 内部使用过程中，一定是request组装完毕后才会计算ht_freezeId; 外部使用的话也需要拿到组装完成的request后才可以利用该key获取数据.
            objc_setAssociatedObject(self, keyHTFreezeId, freezeId, OBJC_ASSOCIATION_COPY_NONATOMIC);
        }
    }
    
    return freezeId;
}

- (void)setHt_freezeId:(NSString *)freezeId {
    objc_setAssociatedObject(self, keyHTFreezeId, freezeId, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSTimeInterval)ht_freezeExpireTimeInterval {
    NSNumber *object = objc_getAssociatedObject(self, keyHTFreezeExpireTimeInterval);
    return (NSTimeInterval)[object doubleValue];
}

- (void)setHt_freezeExpireTimeInterval:(NSTimeInterval)freezeExpireTimeInterval {
    objc_setAssociatedObject(self, keyHTFreezeExpireTimeInterval, @(freezeExpireTimeInterval), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)ht_defaultFreezeId {
    return [self ht_defaultCacheKey];
}

@end
