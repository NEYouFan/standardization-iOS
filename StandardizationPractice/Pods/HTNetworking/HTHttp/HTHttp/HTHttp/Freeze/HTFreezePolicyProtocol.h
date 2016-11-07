//
//  HTFreezePolicyProtocol.h
//  Pods
//
//  Created by Wangliping on 15/10/29.
//
//

#import <Foundation/Foundation.h>

@class HTFrozenRequest;

typedef NS_ENUM(NSUInteger, HTFreezePolicyId) {
    HTFreezePolicyNoFreeze = 0,
    HTFreezePolicySendFreezeAutomatically = 1,
    HTFreezeolicyUserDefined = 100,
};

@protocol HTFreezePolicyProtocol <NSObject>

@required

/**
 *  是否可以发送请求
 *
 *  @param request 被冻结的请求对象
 *
 *  @return 可发送，返回YES； 否则，返回NO.
 */
+ (BOOL)canSend:(HTFrozenRequest *)frozenRequest;

/**
 *  是否可以删除请求.
 *
 *  @param request 被冻结的请求对象.
 *
 *  @return 可发送，返回YES; 否则，返回NO.
 */
+ (BOOL)canDelete:(HTFrozenRequest *)frozenRequest;

@end
