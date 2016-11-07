//
//  HTBaseRequest.h
//  HTHttp
//
//  Created by Wang Liping on 15/9/7.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <RestKit/ObjectMapping/RKHTTPUtilities.h>
#import <HTHttp/Cache/HTCachePolicyProtocol.h>
#import <HTHttp/Freeze/HTFreezePolicyProtocol.h>
#import <HTHttp/RACSupport/RKObjectRequestOperation+HTRAC.h>
#import <HTHttp/Core/NSURLRequest+HTMock.h>

@class RKRequestDescriptor;
@class RKResponseDescriptor;
@class RKMappingResult;
@class RKObjectRequestOperation;
@class RACSignal;
@class HTCachePolicy;
@class HTBaseRequest;

@protocol AFMultipartFormData;

/**
 *  构建表单上传数据的block.
 *
 *  @param 遵循`AFMultipartFormData`协议的对象.
 */
typedef void (^HTConstructingMultipartFormBlock)(id<AFMultipartFormData> formData);

/**
 *  配置请求的block.
 *
 *  @param request HTBaseRequest对象.
 */
typedef void (^HTConfigRequestBlock)(HTBaseRequest *request);

@class HTBaseRequest;

@protocol HTRequestDelegate <NSObject>

/**
 *  请求已经成功结束.
 *
 *  @param request 请求对象.
 */
- (void)htRequestFinished:(HTBaseRequest *)request;

/**
 *  请求失败.
 *
 *  @param request 请求对象.
 */
- (void)htRequestFailed:(HTBaseRequest *)request;

@end

@interface HTBaseRequest : NSObject

#pragma mark - Basic Configuration

/**
 *  对一个请求，基本的配置包括: 请求方法, 请求的Url, 请求的baseUrl, 请求的参数, custom Header, 成功的回调，失败的回调, 超时时间.
 */

/**
*  成功的回调
*/
@property (nonatomic, copy) void (^successCompletionBlock)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult);

/**
 *  失败的回调
 */
@property (nonatomic, copy) void (^failureCompletionBlock)(RKObjectRequestOperation *operation, NSError *error);

/**
 *  创建并发送请求.
 *
 *  @param success 网络请求成功时的回调.
 *  @param failure 网络请求失败时的回调.
 */
- (void)startWithSuccess:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success
                 failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure;

/**
 *  通过manager创建并发送请求.
 *
 *  @param manager 如果manager为nil, 那么使用默认的manager.
 */

/**
 *  通过manager创建并发送请求. 一般使用不带manager的接口即可.
 *
 *  @param manager 用于发送请求的OKObjectManager对象.
 *  @param success 网络请求成功时的回调.
 *  @param failure 网络请求失败时的回调.
 */
- (void)startWithManager:(RKObjectManager *)manager
                 success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success
                 failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure;

/**
 *  设置回调
 *
 *  @param success 创建请求后设置的成功回调.
 *  @param failure 创建请求后设置的失败回调.
 */
- (void)setCompletionBlockWithSuccess:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success
                              failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure;

/// 把block置nil来打破循环引用
- (void)clearCompletionBlock;

/**
 *  用于回调的delegate.
 */
@property (nonatomic, weak) id<HTRequestDelegate> requestDelegate;

/**
 *  Request请求的方法
 *
 *  @return Request请求的方法
 */
+ (RKRequestMethod)requestMethod;

/**
 *  Request请求的Url
 *
 *  @return Request请求的Url.
 */
+ (NSString *)requestUrl;

/**
 *  Request请求的baseUrl
 *
 *  @return Request请求的baseUrl. 默认情况下为空，仅当baseUrl与HTNetworkAgent的baseUrl不相同时才需要提供.
 *  当baseUrl与HTNetworkAgent的baseUrl不相同时, response descriptor的path pattern也必须为全路径.
 */
+ (NSString *)baseUrl;

/**
 *  请求的连接超时时间，默认为60秒
 *
 *  @return 请求的超时时间.
 */
- (NSTimeInterval)requestTimeoutInterval;

/**
 *  请求的参数
 *
 *  @return 请求的参数.
 */
- (NSDictionary *)requestParams;

/**
 *  请求自定义的Header. 默认情况下为nil, 如果有，那么会加到HTTP请求的Header中. 如果原来的header存在对应的key, 则会被替换掉.
 *
 *  @return
 */
- (NSDictionary *)requestHeaderFieldValueDictionary;



#pragma mark - Cache Configuration

/**
 *  对一个请求，与Cache有关的配置包括: 是否启用Cache; Cache Policy Id; Cache Key的计算方法; Cache Policy Class.
 *
 */

/**
 *  是否启用Cache.
 */
@property (nonatomic, assign, readonly) BOOL enableCache;

/**
 *  Cache Policy Id. 默认情况下为HTCachePolicyNoCache即不使用Cache. 如果enableCache为YES, 则需要提供cacheId, 这时可以设置为HTCachePolicyCacheFirst.
 */
@property (nonatomic, assign) HTCachePolicyId cacheId;

/**
 *  Cache 策略类. 如果cacheId不为HTCachePolicyNoCache或者HTCachePolicyCacheFirst，需要明确指定一个cache策略类，对应的cache策略才会生效.
 *
 *  @return 可用的Cache策略类.
 */
- (Class<HTCachePolicyProtocol>)cachePolicyClass;

/**
 *  每个Request对应的唯一的Cache Key. 根据该Key可以查询到指定request的cache内容.
 *
 *  @return 返回一个可用的字符串作为cache key.
 */
- (NSString *)cacheKey;

/**
 *  每个Request对应的唯一的Cache Key. 根据该Key可以查询到指定request的cache内容.
 *
 *  @param mananger cacheKey的计算与发送请求的RKObjectManager的baseURL相关.
 *
 *  @return 返回一个可用的字符串作为cache key.
 */
- (NSString *)cacheKeyWithManager:(RKObjectManager *)mananger;

/**
 *  允许计算cache Key时，忽略掉部分参数. 一般情况下，request的所有参数都需要用于计算cache key, 但是应用可以选择忽略掉某些参数，例如时间戳参数等等.
 *
 *  @param NSDictionary request对应的参数.
 *
 *  @return 返回用于cache key计算的参数.
 */
- (NSDictionary *)cacheKeyFilteredRequestParams:(NSDictionary *)params;

/**
 *  得到的结果是否是从Cache中获取到的. 用于做一些额外的上层逻辑.
 *
 *  @return 如果response是从本地cache中取到，返回YES; 否则，返回NO.
 */
- (BOOL)isDataFromCache;

/**
 *  cache数据的版本. 默认为0. 如果取得的cache数据版本不匹配，那么仍然需要向服务器请求数据.
 *
 *  @return 返回cache数据的版本，默认为0; 仅当版本升级后需要放弃之前的cache数据时才需要设定.
 */
- (NSInteger)cacheVersion;

/**
 *  cache失效时间. 为0时使用cache Manager的默认失效时间.
 *
 *  @return 默认为0. 返回该request对应的cache失效的时间，需要自己控制cache失效时间时设定.
 */
- (NSTimeInterval)cacheExpireTimeInterval;

/**
 *  需要加入cache Key计算的数据；例如，如果cache的内容是版本号敏感的，在cacheSensitiveData中可以返回应用的版本号信息.
 *  Note: 举例，如果某个APP所有的请求都是版本号敏感的，那么可以从HTBaseRequest中派生一个类出来，该类的cacheSensitiveData返回版本号信息，然后新的request子类从
 *  自己的新基类中派生即可.
 *  
 *  @return 需要假如cache key计算的数据. 默认返回nil.
 */
- (id)cacheSensitiveData;

#pragma mark - Request Operations

/**
 *  对一个请求，与操作相关的方法包括: Start, Cancel, isExecuting
 *
 */

/**
 *  启动并且发送请求.
 */
- (void)start;

/**
 *  通过manager创建并发送请求. 一般没有特殊情况，一个应用内只需要使用一个Manager，因此直接调用start方法即可.
 *
 *  @param manager 如果manager为nil, 那么使用默认的manager.
 */
- (void)startWithManager:(RKObjectManager *)manager;

/**
 *  取消对应的请求.
 */
- (void)cancel;

/**
 *  是否正在执行
 *
 *  @return 如果请求正在执行，返回YES, 否则返回NO.
 */
- (BOOL)isExecuting;

#pragma mark - RKObjectManager Configuration

/**
 *  对一个请求，与RestKit相关的配置包括: requestDescriptor, responseDescriptor, requestResult 与 requestOperation.
 *
 */

/**
 *  是否需要自定义Request.
 *
 *  @return 如果需要自定义request, 包括需要添加自定义Header, 自定义超时时间则需要设置为YES.
    默认情况下，当cache功能、请求冻结功能、模拟数据功能或者请求不是HTTP请求时，返回YES.
 */
- (BOOL)needCustomRequest;

/**
 *  请求对应的Request Descriptor. 默认情况下会根据request的requestMapping, requestObjectClass以及requestRootKeyPath来构建对应的Reqeust Descriptor.
 *  一般通过params和path来描述请求，故默认情况下的requestDescriptor为nil. 应用开发者可以使用requestDescriptor来替代params和path进行请求的描述.
 *  @return 返回Request对应的RKRequestDescriptor对象.
 */
+ (RKRequestDescriptor *)requestDescriptor;

/**
 *  构建RequestDescriptor所需要的RequestMapping, 描述Request Object同Request的JSON的对应关系.
 *  一般通过params和path来描述请求，故默认情况下返回nil.
 *
 */
+ (RKMapping *)requestMapping;

/**
 *  构建RequestDescriptor所需要的requestObjectClass.
 *  一般通过params和path来描述请求，故默认情况下返回nil.
 *
 */
+ (Class)requestObjectClass;

/**
 *  构建RequestDescriptor所需要的requestRootKeyPath.
 *  一般通过params和path来描述请求，故默认情况下返回nil.
 *
 */
+ (NSString *)requestRootKeyPath;

/**
 *  请求的ResponseDescriptor数组. 通常情况下，一个request对应一个RKResponseDescriptor即可，如果请求需要两个及以上的ResponseDescriptor, 在子类中实现该方法即可.
 *
 *  @return 返回一个数组，数组中每一项是RKResponseDescriptor对象.
 */
+ (NSArray<RKResponseDescriptor *> *)responseDescriptors;

/**
 *  请求对应的ResponseDescriptor. 
 *
 *  @return 返回Response Descriptor对象.
 */
+ (RKResponseDescriptor *)responseDescriptor;

/**
 *   和request URL匹配的path pattern.
 *
 */
+ (NSString *)pathPattern;

/**
 *  构建ResponseDescriptor所需要的Mapping, 描述Response中的JSON/XML数据与Model的对象关系.
 *
 *  @return 返回RKMapping对象.
 */
+ (RKMapping *)responseMapping;

/**
 *  构建ResponseDescriptor所需要的keyPath.
 *
 *  @return 默认为nil. 详细参见RKRequestDescriptor的注释.
 */
+ (NSString *)keyPath;

/**
 *  构建ResponseDescriptor所需要的statusCodes. 详细参见RKRequestDescriptor的注释.
 *
 */
+ (NSIndexSet *)statusCodes;

/**
 *  请求得到的结果. 仅在请求成功之后才可以获取到正确的值.
 *
 *  @return  返回RKMappingResult对象，对象中会包含解析后的Model对象的数组.
 */
- (RKMappingResult *)requestResult;

/**
 *  请求对应的Operation. 不允许外部修改，仅仅允许查看.
 */
@property (nonatomic, strong, readonly) RKObjectRequestOperation *requestOperation;

#pragma mark - Special Configuration

/**
 *  对一个请求，特殊的一些配置包括: Delegate回调方式; POST请求需要的constructingBodyBlock
 *
 */

/**
 *  请求类型. 默认类型为HTTP类型. 如果该请求适用于私有协议，那么需要自定义一个协议类型，并且通过RKRequestTypeOperation注册实际发送请求的类.
 *  例如: [RKRequestTypeOperation registerClass:[RKCustomRequestOperation Class] forRequestType:@"customRequestType"];
 *  则所有返回customRequestType的request类实际发送请求的过程都在RKCustomRequestOperation中完成.
 *
 *  @return 返回字符串表示请求类型. 默认返回为nil. 如果返回值为RKRequestTypes.h中定义的RKRequestTypeHTTP并且没有额外注册发送HTTP请求的类，那么和返回nil是等效的.
 */
- (NSString *)requestType;

/**
 *  表单上传的request用来构建HTTP BODY的block
 *
 *  @return 返回一个block.
 */
- (HTConstructingMultipartFormBlock)constructingBodyBlock;

/**
 *  用于校验结果是否有效的block, 当结果无效时，即block有效且返回值为NO时，结果会当作Error来处理.
 *
 *  @return 返回一个block, 该block会接收一个返回值. 默认检查MappingResult是否为空或者是否仅仅包含ErrorMsg.
 */
- (HTValidResultBlock)validResultBlock;

/**
 *  对request进行一些特殊的自行扩展的修改. 通常情况下不作任何处理.
 *
 *  @param request 实际使用的request对象.
 */
- (void)customRequest:(NSMutableURLRequest *)request;

#pragma mark - Frozen Requests

/**
 *  是否允许被冻结.
 */
@property (nonatomic, assign, readonly) BOOL canFreeze;

/**
 *  处理冻结的策略类Id.
 */
@property (nonatomic, assign) HTFreezePolicyId freezePolicyId;

/**
 *  被冻结的请求Key.
 *
 *  @return 返回一个可用的字符串作为Freeze key.
 */
- (NSString *)freezeKey;

/**
 *  每个Request对应的唯一的Freeze Key. 根据该Key可以查询到被冻结的请求.
 *
 *  @param mananger 该Key的计算与发送请求的RKObjectManager的baseURL相关.
 *
 *  @return 返回一个可用的字符串作为Freeze key.
 */
- (NSString *)freezeKeyWithManager:(RKObjectManager *)mananger;

/**
 *  过期时间. 例如，一个请求，因为网络不好冻结后一直没有在联网状态下开启过应用，一周后显然不应该重新发送.
 */
- (NSTimeInterval)freezeExpireTimeInterval;

/**
 *  Freeze 策略类. 如果cacheId不为HTFreezePolicyNoFreeze或者HTFreezePolicySendFreezeAutomatically，需要明确指定一个策略类，对应的策略才会生效.
 *
 *  @return 可用的策略类.
 */
- (Class<HTFreezePolicyProtocol>)frozenPolicyClass;

/**
 *  需要加入Freeze Key计算的数据；例如，如果冻结的请求是版本号敏感的，在freezeSensitiveData中可以返回应用的版本号信息.
 *  Note: 举例，如果某个APP所有的请求都是版本号敏感的，那么可以从HTBaseRequest中派生一个类出来，该类的freezeSensitiveData返回版本号信息，然后新的request子类从
 *  自己的新基类中派生即可.
 *
 *  @return 需要假如Freeze key计算的数据. 默认返回nil.
 */
- (id)freezeSensitiveData;

#pragma mark - 兼容性

/**
 *  API的版本号.
 */
@property (nonatomic, assign) NSInteger htVersion;

#pragma mark - Mock Data For Test

/**
 *  是否开启Mock数据选项
 */
@property (nonatomic, assign) BOOL enableMock;

/**
 *  mock response object, 例如一个合法的JSON object.
 */
@property (nonatomic, strong) id mockResponseObject;

/**
 *  mock response data; 如果提供了mockResponseObject或者mockResponseString或者mock
 */
@property (nonatomic, strong) NSData *mockResponseData;
@property (nonatomic, copy) NSString *mockResponseString;
@property (nonatomic, strong) NSError *mockError;
@property (nonatomic, strong) NSHTTPURLResponse *mockResponse;
@property (nonatomic, copy) HTMockBlock mockBlock;

/**
 *  包含Mock数据的Json文件路径.
 */
@property (nonatomic, copy) NSString *mockJsonFilePath;


#pragma mark - Send Request 

/**
 *  返回HTNetworkAgent对应网络请求的baseURL.
 *
 *  @return 有效的baseURL.
 *
 */
+ (NSURL *)defaultBaseURL;

/**
 *  实际执行请求的objectManager.
 */
+ (RKObjectManager *)objectManager;

/**
 *  取消所有请求.
 */
+ (void)cancelAllRequests;

@end

