//
//  NSURLRequest+HTFreeze.h
//  Pods
//
//  Created by Wangliping on 15/10/29.
//
//

#import <Foundation/Foundation.h>
#import "HTFreezePolicyProtocol.h"

@interface NSURLRequest (HTFreeze)

/**
 *  是否允许被冻结.
 */
@property (nonatomic, assign) BOOL ht_canFreeze;

/**
 *  该请求是否已被冻结.
 */
@property (nonatomic, assign) BOOL ht_isFrozen;

/**
 *  处理冻结的策略类Id.
 */
@property (nonatomic, assign) HTFreezePolicyId ht_freezePolicyId;

/**
 *  被冻结的请求Id.
 */
@property (nonatomic, copy) NSString *ht_freezeId;

/**
 *  过期时间. 例如，一个请求，因为网络不好冻结后一直没有在联网状态下开启过应用，一周后显然不应该重新发送.
 */
@property (nonatomic, assign) NSTimeInterval ht_freezeExpireTimeInterval;

/**
 *  默认的freezeId.
 *  因为一般情况下，冻结请求不同于缓存，如果参数有变化或者header有变化，都不应该再发送，因为没有任何意义了，比如说cookie或者timestamp发生了变化.
 *
 *  @return 返回一个字符串作为请求的freezeId.
 */
- (NSString *)ht_defaultFreezeId;

@end
