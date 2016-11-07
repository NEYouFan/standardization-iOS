//
//  HTAutoBaseRequest.h
//  HTHttp
//
//  Created by Wangliping on 16/1/11.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import "HTBaseRequest.h"

/// 鉴于自动生成的Request子类不方便在实现文件中添加对基类方法的覆盖，定义HTAutoBaseRequest允许通过配置属性的方式来配置Request子类.
/// 手动编写、不需要额外配置的请求建议仍然从HTBaseRequest中派生.

@class HTAutoBaseRequest;

/**
 *  计算cache key的Block.
 *
 *  @param request  需要计算cache key的请求对象.
 *  @param mananger 对于每个RKObjectMananger, 计算cache key的方式可能会有区别，例如不同的Manager会有不同的baseUrl.
 *
 *  @return 字符串, 表示该请求的唯一标识符，cache 使用者根据该key从cache中获取到对应的response.
 */
typedef NSString * (^HTCacheKeyCaculateBlock)(HTAutoBaseRequest *request, RKObjectManager *mananger);

/**
 *  在计算cache key中允许排除某些请求参数的Block, 例如，请求参数中的time stamp可以被忽略.
 *
 *  @param request 需要计算cache key的请求对象.
 *  @param params  请求所带的参数.
 *
 *  @return 过滤后的NSDictionary对象，如果不需要过滤，则直接返回params.
 */
typedef NSDictionary * (^HTCacheKeyFilteredRequestParamsBlock)(HTAutoBaseRequest *request, NSDictionary *params);

/**
 *  计算freeze key的Block.
 *
 *  @param request  需要计算freeze key的请求对象.
 *  @param mananger 对于每个RKObjectMananger, 计算freeze key的方式可能会有区别，例如不同的Manager会有不同的baseUrl.
 *
 *  @return 字符串, 表示该请求的唯一标识符，freeze 使用者根据该key查找到对应的冻结请求
 */
typedef NSString * (^HTFreezeKeyCaculateBlock)(HTAutoBaseRequest *request, RKObjectManager *mananger);

/**
 *  自定义Request的Block. 允许SDK使用者对request添加任何自定义.
 *
 *  @param autoHTRequest 需要自定义请求的HTAutoBaseRequest的对象.
 *  @param request       将被自定义的request.
 */
typedef void (^HTCustomRequestBlock)(HTAutoBaseRequest *autoHTRequest, NSMutableURLRequest *request);

@interface HTAutoBaseRequest : HTBaseRequest

/**
 *  请求超时. 不设置时采用基类的默认设置.
 */
@property (nonatomic, assign) NSTimeInterval customRequestTimeoutInterval;

/**
 *  请求是否需要自定义. 设置为NO时采用基类的默认设置, 例如，启用了Cache等功能, 即使该属性设置为NO, 仍然会对请求进行一些自定义。
 */
@property (nonatomic, assign) BOOL configNeedCustomRequest;

/**
 *  cache策略类. 默认为nil.
 */
@property (nonatomic, strong) Class<HTCachePolicyProtocol> cachePolicyClass;

/**
 *  外部设置的cache Key. 如果有设置，则不再按照默认的机制进行计算.
 */
@property (nonatomic, copy)   NSString *customCacheKey;

/**
 *  计算cache Key的block, 如果有设置，则按照该block提供的方式计算针对某一个RKObjectManager的cache key.
 */
@property (nonatomic, copy)   HTCacheKeyCaculateBlock cacheKeyBlock;

/**
 *  计算cache key时过滤参数的block. 当使用默认的机制计算cache key时生效.
 */
@property (nonatomic, copy)   HTCacheKeyFilteredRequestParamsBlock cacheParamsFilterBlock;

/**
 *  如果对该请求作缓存，持久化存储时对应的版本号，默认为0.
 */
@property (nonatomic, assign) NSInteger cacheVersion;

/**
 *  缓存超时时间. 默认为0表示按照Cache Manager内置的默认超时机制处理.
 */
@property (nonatomic, assign) NSTimeInterval cacheExpireTimeInterval;

/**
 *  影响cache key的数据. 默认为nil. SDK使用者可以提供App版本号或者请求的版本号作为cacheSensitiveData, 从而控制不同版本间是否仍然需要采用Cache.
 */
@property (nonatomic, strong) id cacheSensitiveData;

/**
 *  冻结请求的超时时间. 默认为0表示按照内置的默认超时机制处理.
 */
@property (nonatomic, assign) NSTimeInterval freezeExpireTimeInterval;

/**
 *  freeze策略类. 默认为nil.
 */
@property (nonatomic, strong) Class<HTFreezePolicyProtocol> frozenPolicyClass;

/**
 *  影响freeze key的数据. 默认为nil. SDK使用者可以提供App版本号或者请求的版本号作为cacheSensitiveData, 从而控制不同版本间是否仍然需要采用Cache.
 */
@property (nonatomic, strong) id freezeSensitiveData;

/**
 *  外部设置的freeze Key. 如果有设置，则不再按照默认的机制进行计算.
 */
@property (nonatomic, copy) NSString *customFreezeKey;

/**
 *  计算freeze Key的block, 如果有设置，则按照该block提供的方式计算针对某一个RKObjectManager的cache key.
 */
@property (nonatomic, copy) HTFreezeKeyCaculateBlock freezeKeyBlock;

/**
 *  请求类型. 参见RKRequestType.h. 默认为nil, 表示HTTP请求.
 */
@property (nonatomic, copy) NSString *customRequestType;

/**
 *  上传流数据时构建HTTP Body的block. 如果不是自动生成代码，推荐采用覆盖基类方法- (HTConstructingMultipartFormBlock)constructingBodyBlock的方式来实现定制.
 */
@property (nonatomic, copy) HTConstructingMultipartFormBlock customConstructingBlock;

/**
 *  校验生成结果的block. 如果不是自动生成代码，推荐采用覆盖基类方法- (HTValidResultBlock)validResultBlock的方式来实现定制.
 */
@property (nonatomic, copy) HTValidResultBlock customValidResultBlock;

/**
 *  定制request请求的block. 如果不是自动生成代码，推荐采用覆盖基类方法- (void)customRequest:(NSMutableURLRequest *)request的方式来实现定制.
 */
@property (nonatomic, copy) HTCustomRequestBlock customRequestBlock;


@end
