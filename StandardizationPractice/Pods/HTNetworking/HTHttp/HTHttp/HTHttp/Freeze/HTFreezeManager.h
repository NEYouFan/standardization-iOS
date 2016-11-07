//
//  HTFreezeManager.h
//  Pods
//
//  Created by Wangliping on 15/10/29.
//
//

#import <Foundation/Foundation.h>
#import "HTFreezePolicyProtocol.h"

@class RKObjectManager;
@class HTFrozenRequest;

typedef void(^HTFreezeCompletionBlock)();

@protocol HTFreezeManagerProtocol <NSObject>

@required
- (RKObjectManager *)objectManagerForRequest:(NSURLRequest *)request;

@end

@interface HTFreezeManager : NSObject

/**
 *  初始化工作，主要是初始化单例的FreezeManager并且设置代理相关.
 */
+ (void)setupWithDelegate:(id<HTFreezeManagerProtocol>)delegate isStartMonitoring:(BOOL)isStartMonitoring;

/**
 *  单例的FreezeManager.
 *
 *  @return 返回HTFreezeManager对象.
 */
+ (instancetype)sharedInstance;

/**
 *  重新发送时RKObjectManager等发送相关信息由外部来提供.
 */
@property (nonatomic, weak) id<HTFreezeManagerProtocol> delegate;

/**
 *  非Wifi模式下是否自动解冻已被冻结的请求.
 */
@property (nonatomic, assign) BOOL enableWWANMode;

/**
 *  当前是否有监视网络状况. 仅当监视网络状况时才可以判断是否需要冻结.
 */
@property (nonatomic, assign, readonly) BOOL isMonitoring;

/**
 *  开始监控网络状况.
 */
- (void)startMonitoring;

/**
 *  冻结某个请求. 应用不需要手动调用.
 *
 *  @param request 需要被冻结的请求
 */
- (void)freeze:(NSURLRequest *)request;

/**
 *  删除某个已被冻结的请求.
 *
 *  @param freezeId 待删除的冻结请求的Id.
 */
- (void)remove:(NSString *)freezeId;

/**
 *  查询已经被冻结的请求. Note: 建议在子线程中调用，因为会读取持久化存储的数据.
 *
 *  @param freezeId 被冻结的请求Id.
 *
 *  @return 返回被冻结的请求.
 */
- (HTFrozenRequest *)queryByFreezeId:(NSString *)freezeId;

/**
 *  查询所有被冻结的请求  Note: 所查询的结果是HTFreezedRequest的数组而不是NSURLRequest的数组. 因为NSURLRequest不方便扩展相关的如过期时间等信息. 建议在子线程中调用，因为会读取持久化存储的数据.
 *
 *  @return 返回请求List. Array里面每一项都是一个Request.
 */
- (NSArray *)allFreezedRequests;

/**
 *  清除所有被冻结的请求.
 */
- (void)clearAllFreezedRequests;

/**
 *  清除所有被冻结的请求.
 */
- (void)clearAllFreezedRequestsOnCompletion:(HTFreezeCompletionBlock)completion;

/**
 *  清除内存中保存的所有被冻结的请求.
 */
- (void)clearAllFreezedRequestsInMemory;

@end

extern NSString * const kHTResendFrozenRequestSuccessfulNotification;
extern NSString * const kHTResendFrozenRequestFailureNotification;
extern NSString * const kHTResendFrozenNotificationOperationItem;
extern NSString * const kHTResendFrozenNotificationResultItem;
extern NSString * const kHTResendFrozenNotificationErrorItem;
