HTNetworking高级使用教程
---

本教程主要介绍HTNetworking的一些高级使用技巧，包括：

###[灵活使用Cache功能](#灵活使用Cache功能)
###[冻结请求](#冻结请求)
###[请求调度](#请求调度)
###[功能扩展](#功能扩展)
###[使用不同的RKObjectMananger来发送请求](#使用不同的RKObjectMananger来发送请求)
###[HTHTTPModel的使用](#HTHTTPModel的使用)
###[日志使用](#日志使用)

<p id="灵活使用Cache功能">
## 一 灵活使用Cache功能

HTNetworking提供的cache功能不依赖于服务器的实现以及系统默认的cache策略，使用者可以通过简单的配置就实现业务对于缓存的需求，并提供良好的扩展性以及强大的个性化配置，同时，适当的缓存机制使得部分应用不再需要自己提供持久化存储的功能。

### 1 默认支持的cache策略
默认支持的cache策略包括如下三种，指定request类的`cacheId`属性即可开启对应的策略；

1. `HTCachePolicyNoCache`: 不使用cache; 即不从cache中读取数据, 也不写数据到缓存中；
2. `HTCachePolicyCacheFirst`: 优先读取cache中的数据，如果cache中不存在数据，才发送网络请求；网络请求的结果一定会写会缓存；
3. `HTCachePolicyWriteOnly`: 不读取cache中的数据，但从网络请求获取到数据后保存到缓存中供后续使用；

以上三种策略能够满足常见的需求。

对于需求："先从cache中取数据进行展示，然后再从网络请求中获取数据并且更新界面与缓存"这一类需求，可以通过对cache策略`HTCachePolicyCacheFirst`和`HTCachePolicyWriteOnly`的组合使用来予以支持。


	/**
	 *  演示如何先从cache中获取数据，然后再保证从服务器获取最新的数据并且保存到cache中.
	 */
	- (void)demoSendRequestWithAdvanceCachePolicy {
	    HTDemoGetUserPhotoListRequest *request = [[HTDemoGetUserPhotoListRequest alloc] init];
	    request.cacheId = HTCachePolicyCacheFirst;
	    [request startWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
			// .... 结果处理与界面更新
			
			// 如果数据来自缓存，再继续发送从网络中获取数据.
	        if (operation.HTTPRequestOperation.response.ht_isFromCache) {
	            [self getUserPhotoListWithWritingCache];
	        }
	    } failure:^(RKObjectRequestOperation *operation, NSError *error) {

	    }];
	}
	
	/**
	 *  演示发送这样的请求，不从Cache中读数据，但是每次获取到的数据都保存到Cache中.
	 */
	- (void)getUserPhotoListWithWritingCache {
	    HTDemoGetUserPhotoListRequest *request = [[HTDemoGetUserPhotoListRequest alloc] init];
	    // 强制从网络中获取最新的数据.
	    request.cacheId = HTCachePolicyWriteOnly;
	    [request startWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
			// 结果处理与界面更新
	    } failure:^(RKObjectRequestOperation *operation, NSError *error) {

	    }];
	}


### 2 HTCacheMananger

HTCacheMananger提供了对Cache的管理功能，包括配置cache占用内存的大小、查询请求是否存在缓存、清理cache等，主要的对外接口如下：


	@interface HTCacheManager : NSObject
	
	/**
	 *  该Request是否存在cache
	 *
	 *  @param request 网络请求对应的request对象
	 *
	 *  @return 如果request存在对应的Cache, 则返回YES, 否则返回NO.
	 */
	- (BOOL)hasCacheForRequest:(NSURLRequest *)request;
	
	/**
	 *  取出request对应的Cache.
	 *
	 *  @param HTCachedResponse 网络请求对应的request对象
	 *
	 *  @return 返回request对应的HTCachedResponse.
	 */
	- (HTCachedResponse *)cachedResponseForRequest:(NSURLRequest *)request;
	
	/**
	 *  删除与request对应的缓存的response. 异步接口.
	 *
	 *  @param request 网络请求对应的request对象
	 *  @param completion 删除完毕后的回调.
	 */
	- (void)removeCachedResponseForRequest:(NSURLRequest *)request completion:(HTCacheCompletionBlock)completion;
	
	/**
	 *  清除Cache.
	 *
	 *  @param completion 清除cache完毕后的回调.
	 */
	- (void)removeAllCachedResponsesOnCompletion:(HTCacheCompletionBlock)completion;
	
	/**
	 *  清除某个时间点之后保存的所有cache.
	 *
	 *  @param date       时间. 在参数date时间之后保存的cache都会被清理掉.
	 *  @param completion 清理完毕后的回调.
	 */
	- (void)removeCachedResponsesSinceDate:(NSDate *)date completion:(HTCacheCompletionBlock)completion;
	
	/**
	 *  清理内存Cache.
	 */
	- (void)clearMemoryCache;
	
	/**
	 *  当前disk Cache已占用的大小. 同步接口，避免在主线程中调用该方法.
	 *
	 *  @return 当前disk Cache已占用的大小.
	 */
	- (NSUInteger)getCurCacheSize;
	
	/**
	 *  计算disk Cache已占用的大小并将结果回调.
	 *
	 *  @param completion 计算结束后的回调.
	 */
	- (void)calculateSizeWithCompletionBlock:(HTCacheSizeCompletionBlock)completion;
	
	@end


### 3 cache功能定制与扩展

#### 支持不同的cache策略

如果希望自定义cache策略，可以从`HTCachePolicy`中自派生一个策略类，并且按需求实现`HTCachePolicyProtocol`中定义的方法：

	@interface HTCustomCachePolicy : HTCachePolicy
	
	@end

需要实现的方法如下：

	@protocol HTCachePolicyProtocol <NSObject>
	
	@required
	
	/**
	 *  是否存在requestOperation对应的缓存结果.
	 *
	 *  @param requestOperation 网络请求Operation对象.
	 *
	 *  @return 有对应缓存结果，返回YES, 否则, 返回NO.
	 */
	+ (BOOL)hasCacheForRequest:(RKHTTPRequestOperation *)requestOperation;
	
	/**
	 *  获取requestOperation对应的缓存结果.
	 *
	 *  @param requestOperation 网络请求Operation对象.
	 *
	 *  @return 返回缓存的结果，如果没有，返回nil.
	 */
	+ (NSCachedURLResponse *)cachedResponseForRequest:(RKHTTPRequestOperation *)requestOperation;
	
	@end

然后，指定cachePolicyId来注册策略类：

    [[HTCachePolicyManager sharedInstance] registeCachePolicyWithPolicyId:(HTCachePolicyUserDefined + 1) policy:[HTCustomCachePolicy class]];
    
在创建请求后，指定request的cache Id, 则会启用对应的策略类来进行请求的发送：    
    
    HTDemoCustomizeRequest *request = [[HTDemoCustomizeRequest alloc] init];
    // 设置cache Id.
    request.cacheId = HTCachePolicyUserDefined + 1;
    request.cacheExpireTimeInterval = 3600;
    
    // 发送请求
    [request startWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
		// 结果处理
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
		// 错误处理
    }];

#### cache Key的计算

为了能够查找到指定Request的缓存结果，必须对每一个Request计算一个key值出来，默认的key值计算包含了请求方法(GET, POST), 请求的URL, 请求的参数等信息，但使用者可以根据自己的情况来控制哪些应该加入key值的计算;

1. 覆写`HTBaseRequest`类的实例方法`cacheKeyFilteredRequestParams`来过滤掉不希望加入计算key值计算的参数，例如`timestamp`等；

	示例：
	
		- (NSDictionary *)cacheKeyFilteredRequestParams:(NSDictionary *)params {
		    NSMutableDictionary *filterParams = [[NSMutableDictionary alloc] initWithDictionary:params];
		    [filterParams removeObjectForKey:@"timestamp"];
		    
		    return filterParams;
		}

2. 覆写方法`- (id)cacheSensitiveData`可以选择额外添加需要加入cache key计算的信息， 包括请求头、应用版本地址等等，从而可以控制缓存在应用版本升级后或者请求头部不同时，是否失效.

	示例:(应用升级后缓存失效)

		- (id)cacheSensitiveData {
    		return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
		}
		
3. 覆写方法`- (NSString *)cacheKey`自行计算cache key.	
<p id="冻结请求">
## 二 冻结请求

在某些场景下，网络断开时，请求无法发送，希望可以自动将该请求冻结，在网络恢复正常时再重新发送。`HTNetworking`提供便捷的机制来自动冻结请求，以及在网络恢复正常时根据业务需要重新发送请求，并将请求结果通知给感兴趣的页面（或模块），整个过程对正常的网络请求流程无影响。

### 1 允许冻结请求

通过配置请求的冻结策略来控制是否允许冻结请求.

	- (HTFreezePolicyId)freezePolicyId {
	    return HTFreezePolicySendFreezeAutomatically;
	}
	
	- (NSTimeInterval)freezeExpireTimeInterval {
	    return 3600;
	}

同时，由于冻结请求需要显式的监听网络状况，因此需要开启监听才可能发送被冻结的请求.

    // 开启冻结请求的功能. 通常，freezeMananger的delegate可以是一个单例, 为请求的再次发送提供配置.
    [HTFreezeManager setupWithDelegate:self isStartMonitoring:YES];
    

### 2 冻结请求的恢复

被冻结的请求会根据冻结的策略在有效时间内自动恢复；但在重新发送请求前会通过代理`HTFreezeManagerProtocol`请求使用哪一个`RKObjectMananger`发送请求; `HTFreezeManagerProtocol`的定义如下：

	@protocol HTFreezeManagerProtocol <NSObject>
	
	@required
	- (RKObjectManager *)objectManagerForRequest:(NSURLRequest *)request;
	
	@end

此外，如果某个页面需要知道被冻结的请求是否被重新发送，需要监听冻结请求的发送成功与失败事件; 通过NSNotificationCenter来处理的原因是，上次负责发送请求的页面或者类实例可能在应用退出后被销毁了;

    // 监听冻结请求的发送成功与失败事件.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onFrozenRequestSuccessful:) name:kHTResendFrozenRequestSuccessfulNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onFrozenRequestFailure:) name:kHTResendFrozenRequestFailureNotification object:nil];

在收到通知后，可以从中取到request信息，然后根据情况判断是否要作相应的处理；
	
	- (void)onFrozenRequestSuccessful:(NSNotification *)notify {
	    NSDictionary *userInfo = [notify userInfo];
	    
	    RKObjectRequestOperation *operation = [userInfo objectForKey:kHTResendFrozenNotificationOperationItem];
	    RKMappingResult *result = [userInfo objectForKey:kHTResendFrozenNotificationResultItem];
	    
		// 可以判断operation中的request是否是想要处理的请求然后进行处理
	}
	
	- (void)onFrozenRequestFailure:(NSNotification *)notify {
	    NSDictionary *userInfo = [notify userInfo];
	    
	    RKObjectRequestOperation *operation = [userInfo objectForKey:kHTResendFrozenNotificationOperationItem];
	    NSError *error = [userInfo objectForKey:kHTResendFrozenNotificationErrorItem];
	    
		// 可以判断operation中的request是否是想要处理的请求然后进行处理
	}

### 3 冻结请求的管理与查询

冻结请求的管理类提供了一些管理与查询接口，具体如下：


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

<p id="请求调度">
## 三 请求调度

请求调度是指可以描述多个请求之间的先后、依赖、并行关系等，常见的需求包括：

1. 登录请求结束后马上需要根据获取到的token获取到相关业务数据；
2. 同一页面的数据来源于不同的业务服务器，需要等多个请求一起结束后才可以刷新页面；
3. 请求A成功获取到合法数据后需要继续执行请求B, 否则发送请求C.

`HTNetworking`利用`ReactiveCocoa`提供的机制来提供对请求调度功能的支持，核心是将"请求发送"这一事件转变为`ReactiveCocoa`的信号`RACSignal`，然后使用者通过对`RACSignal`的使用来实现请求事件流的控制；

`HTBaseRequest`中开放如下方法来提供`RACSignal`信号：

	- (RACSignal *)signalStart;

一般使用方法：


    HTDemoGetUserPhotoListRequest *request = [[HTDemoGetUserPhotoListRequest alloc] init];
    RACSignal *signal = [request signalStart];
    [signal subscribeNext:^(id x) {
        RACTupleUnpack(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) = (RACTuple *)x;
	
		// 请求结果处理.
    } error:^(NSError *error) {
        RKObjectRequestOperation *operation = error.userInfo[@"operation"];
        NSError *realError = error.userInfo[@"error"];
        if (nil == realError) {
            realError = error;
        }
        
		// 错误处理.
    } completed:^{
		// 请求结束.
    }];

针对需求“多个请求并行，当所有请求结束后再做数据刷新“， 示例如下：

	HTDemoGetUserPhotoListRequest *requestA = [[HTDemoGetUserPhotoListRequest alloc] init];
    RACSignal *signalA = [requestA signalStart];
    
    HTDemoGetPhotoListRequest *requestB = [[HTDemoGetPhotoListRequest alloc] init];
    RACSignal *signalB = [requestB signalStart];
    
    NSMutableArray *signalList = [NSMutableArray array];
    if (nil != signalA) {
        [signalList addObject:signalA];
    }
    
    if (nil != signalB) {
        [signalList addObject:signalB];
    }
    
    // 信号的组合
    RACSignal *mergedSignal = [RACSignal merge:signalList];
    [mergedSignal subscribeNext:^(id x) {
        RACTupleUnpack(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) = (RACTuple *)x;
		// 请求结果处理.
    } error:^(NSError *error) {
        RKObjectRequestOperation *operation = error.userInfo[@"operation"];
        NSError *realError = error.userInfo[@"error"];
        if (nil == realError) {
            realError = error;
        }
        
		// 错误处理.
    } completed:^{
		// 所有请求结束
    }];

在基本信号的基础上，提供了针对如下case的组合信号

1. 多个请求的组合信号
	
		+ (RACSignal *)batchSignalsOfRequests:(NSArray<HTBaseRequest *> *)requestList;

2. 重试信号

		/**
		 *  发送请求的信号.
		 *
		 *  @param retryCount 重试的次数. 为0时，该方法效果同- (RACSignal *)signalStart;
		 *  @return 返回一个RACSignal对象，该Signal即使被重复订阅也仅发送一次网络请求.
		 */
		- (RACSignal *)signalStartWithRetry:(NSInteger)retryCount;

3. A请求成功，则发送B, 否则发送C

		/*
		*
		 *  发送请求的信号. 该信号描述如下的事件流：如果conditionRequest成功，则发送trueRequest; 否则发送falseRequest.
		 *
		 *  @param conditionRequest 作为判断条件的请求.
		 *  @param trueRequest      conditionRequest成功后需要发送的请求.
		 *  @param falseRequest     conditionRequest失败后需要发送的请求.
		 *  @param mananger         发送请求的Manager, 如果为nil, 则使用默认的Manager发送请求.
		 *
		 *  @return 返回一个RACSignal信号对象.
		 */
		+ (RACSignal *)ifRequestSucceed:(HTBaseRequest *)conditionRequest then:(HTBaseRequest *)trueRequest else:(HTBaseRequest *)falseRequest withMananger:(RKObjectManager *)mananger;

而对于其他信号操作的组合，请参见[ReactiveCocoa Basic Operators](https://github.com/ReactiveCocoa/ReactiveCocoa/blob/master/Documentation/Legacy/BasicOperators.md)

下例是利用`flattenMap`来实现A请求结束后，A的输出作为B的输入并且继续发送请求B的流程.

	/**
	 *  展示如何利用ReactiveCocoa与HTBaseRequest发送多个相互依赖的请求.
	 */
	- (void)demoHTDependentSignals {
	    NSString *methodName = NSStringFromSelector(_cmd);
	    
	    HTDemoGetUserInfoRequest *getUserInfoRequest = [[HTDemoGetUserInfoRequest alloc] init];
	    HTDemoRACPhotoListRequest *getPhotoListRequest = [[HTDemoRACPhotoListRequest alloc] init];
	   
	    RACSignal *combinedSignal = [[getUserInfoRequest signalStart] flattenMap:^RACStream *(id value) {
	        RACTupleUnpack(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) = (RACTuple *)value;
	        NSAssert(nil != operation, @"received value is incorrect");
	        RKDemoUserInfo *userInfo = mappingResult.dictionary[@"data"];
	        getPhotoListRequest.userName = userInfo.name;
	        return [getPhotoListRequest signalStart];
	    }];
	    
	    [combinedSignal subscribeNext:^(id x) {
	        RACTupleUnpack(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) = (RACTuple *)x;
	        [self showResultSilently:YES operation:operation result:mappingResult error:nil];
	    } error:^(NSError *error) {
	        RKObjectRequestOperation *operation = error.userInfo[@"operation"];
	        NSError *realError = error.userInfo[@"error"];
	        if (nil == realError) {
	            realError = error;
	        }
	        
	        [self showResultSilently:NO operation:operation result:nil error:realError];
	    } completed:^{
	        NSLog(@"%@ : %@", methodName, @"completed");
	    }];
	}

<p id="功能扩展">
## 四 功能扩展
### 1 返回数据格式的扩展

默认支持的返回数据格式是JSON, 使用者可以通过`RKMIMETypeSerialization`提供的方法扩展支持不同的数据格式。

	@interface RKMIMETypeSerialization : NSObject
	
	+ (void)registerClass:(Class<RKSerialization>)serializationClass forMIMEType:(id)MIMETypeStringOrRegularExpression;
	
	+ (void)unregisterClass:(Class<RKSerialization>)serializationClass;
	
	@end

例如, 下面的代码允许针对"text/html"这种MIMEType也使用JSON格式解析：

    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"text/html"];

`RKNSJSONSerialization`遵循协议`RKSerialization`; 如果使用者希望定义自己的数据格式与序列化方式，那么只需要实现一个序列化类，协议`RKSerialization`即可，协议`RKSerialization`的定义如下:

	@protocol RKSerialization <NSObject>
	
	+ (id)objectFromData:(NSData *)data error:(NSError **)error;
	
	+ (NSData *)dataFromObject:(id)object error:(NSError **)error;
	
	@end

### 2 传输协议的扩展

除了支持HTTP协议外，`HTNetworking`也支持使用私有TCP协议发送数据，同时并不影响上层对于请求的描述，这样应用开发者不需要关心底下的实现细节，只需要描述请求的类型即可。

要支持自己的私有协议，需要实现以下功能：

1. 发送请求和接收请求结果的类;该类必须遵循`RKHTTPRequestOperationProtocol`；该类需要接收`NSURLRequest`作为输入，在请求结束后提供`NSURLResponse`作为输出，并提供请求发送、暂停以及结果回调的接口；
2. 在该类中，使用者需要提供NSURLRequest到私有TCP协议报文的转换逻辑，在发送之前将接收的`NSURLRequest`输入内容转为私有TCP协议报文；
3. 在该类中，使用者需要提供私有协议回应报文到NSURLResponse的转换逻辑，再接收到数据后将数据转为HTTP请求的标准响应数据；
4. 假定实现的传输类名为`HTMyOperation`, 则注册一下该请求：
		  
		  // 请求类型为`MyRequestType`的Request, 都会使用`HTMyOperation`发送请求.
        [RKRequestTypeOperation registerClass:[HTMyOperation class] forRequestType:@"MyRequestType"];

5. 请求类中覆写基类的实例方法，描述请求类型.

		- (NSString *)requestType {
		    return @"MyRequestType";
		}

### 3 处理逻辑的扩展

本节需要对`RestKit`有一定了解；

`RKObjectMananger`中提供了对处理逻辑的扩展，即可以通过注册自己的请求处理类来替换掉原有的实现，请求处理类必须是原有请求处理类的子类。比较常见的扩展是对请求发送前和发送后添加一些额外的逻辑，此时可以实现一个`RKHTTPRequestOperation`的子类，然后注册到object mananger中，在自己实现的派生类中进行一些处理。

以默认提供的cache功能为例，请求处理类`HTHTTPRequestOperation`定义如下：

	@interface HTHTTPRequestOperation : RKHTTPRequestOperation
	
	@end

注册到RKObjectManager中：
	
	[[HTBaseRequest objectManager] registerRequestOperationClass:[HTHTTPRequestOperation class]];

HTHTTPRequestOperation中的主要处理流程如下：(示意代码)

	// 发送请求前进行处理
	- (void)start {
	    if ([self haveCache]) {        
	    	// 有缓存，取缓存.
	        [self updateResponseWithCache];
	
			// 结束流程
	        [self finishOperation];
	    } else {
	    
	    	// 发送请求到服务器
	        [super start];
	    }
	}

	// 请求结束后添加处理
	- (void)setCompletionBlockWithSuccess:(void (^)(RKHTTPRequestOperation *operation, id responseObject))success
	                              failure:(void (^)(RKHTTPRequestOperation *operation, NSError *error))failure {
	    [super setCompletionBlockWithSuccess:^(RKHTTPRequestOperation *operation, id responseObject) {
	        if ([operation isKindOfClass:[HTHTTPRequestOperation class]]) {
	        	  // 判断是否要缓存
	            HTHTTPRequestOperation *htOperation = (HTHTTPRequestOperation *)operation;
	            // 判定结果是否从缓存中来.
	            BOOL isResultFromCache = htOperation.isResponseFromCache;
	            // 如果结果不是从缓存中获取到，那么将Response存入缓存中.
	            if (!isResultFromCache) {
	                [htOperation ht_cacheResponse];
	            }
	        }
	
	        success(operation, responseObject);
	    } failure:^(RKHTTPRequestOperation *operation, NSError *error) {
	        failure(operation, error);
	    }];
	}

使用者在扩展时可以参照`HTHTTPRequestOperation`与`HTMockHTTPRequestOperation`的扩展方式进行扩展。

<p id="使用不同的RKObjectMananger来发送请求">
## 五 使用不同的RKObjectMananger来发送请求
`HTNetworking`请求的发送实际依赖于`RKObjectManager`对象, 框架库中在初始化`HTNetworking`时需要创建一个默认的`RKObjectMananger`对象, 通常情况下, `NSURLRequest`对象的请求与构建都会通过默认的`RKObjectMananger`对象进行, 但是，使用者也可以自己创建RKObjectManager对象，然后通过自己创建的对象来发送请求。

示例如下：

	/**
	 *  方法1：演示如何使用另一个RKObjectMananger实例来发送请求. 请求的response描述符手动添加到manager中.
	 */
	- (void)demoSendRequestInAnotherManger {
	    NSURL *baseURL = [NSURL URLWithString:HTBaseRequestDemoBaseUrl];
	    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:baseURL];
	    [manager addResponseDescriptor:[HTDemoGetUserInfoRequest responseDescriptor]];
	    
	    HTDemoGetUserInfoRequest *request = [[HTDemoGetUserInfoRequest alloc] init];
	    request.requestDelegate = self;
	    [request startWithManager:manager];
	}
	
	/**
	 *  方法2：演示如何通过注册的方式将请求的response descriptor添加到另一个RKObjectManager, 并且使用另一个RKObjectManager发送请求.
	 */
	- (void)demoSendRequestInAnotherMangerWithRegister {
	    NSURL *baseURL = [NSURL URLWithString:HTBaseRequestDemoBaseUrl];
	    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:baseURL];
	    [HTDemoGetUserInfoRequest registerInMananger:manager];
	    
	    HTDemoGetUserInfoRequest *request = [[HTDemoGetUserInfoRequest alloc] init];
	    request.requestDelegate = self;
	    [request startWithManager:manager];
	}

<p id="HTHTTPModel的使用">
## 六 HTHTTPModel的使用

### 1 HTHTTPModel

`HTHTTPModel`提供了一些基本的Model与JSON的转换功能，从该类派生的类可以直接使用这些转换功能；主要接口如下：
	
	@interface HTHTTPModel : NSObject <NSCopying, NSCoding, HTModelProtocol>

	#pragma mark - JSON / Model Convertor
	
	/**
	 *  根据JSON内容创建对应的Model类对象.
	 *
	 *  @param json json对象，为NSString, NSData或者NSDictionary.
	 *
	 *  @return 返回创建的Model对象.
	 */
	+ (instancetype)modelWithJSON:(id)json;
	
	/**
	 *  根据字典内容创建对应的Model类对象.
	 *
	 *  @param dictionary 字典
	 *
	 *  @return 返回创建的Model对象.
	 */
	+ (instancetype)modelWithDictionary:(NSDictionary *)dictionary;
	
	/**
	 *  将JSON内容转为Model的属性.
	 *
	 *  @param dic json对象，为NSString, NSData或者NSDictionary.
	 *
	 *  @return 成功返回YES, 失败返回NO.
	 */
	- (BOOL)modelSetWithJSON:(id)json;
	
	/**
	 *  将字典内容转为Modle的属性.
	 *
	 *  @param dic 字典.
	 *
	 *  @return 成功返回YES, 失败返回NO.
	 */
	- (BOOL)modelSetWithDictionary:(NSDictionary *)dic;
	
	/**
	 *  转换为JSON Object, 比如字典或者数组.
	 *
	 *  @return 返回JSON Object, 可以是数组或者字典.
	 */
	- (id)modelToJSONObject;
	
	/**
	 *  转换为JSON DATA.
	 *
	 *  @return 转为JSON格式的NSData.
	 */
	- (NSData *)modelToJSONData;
	
	/**
	 *  转换为JSON String.
	 *
	 *  @return 返回JSON格式的字符串.
	 */
	- (NSString *)modelToJSONString;
	
	@end
	
使用示例：

    HTArticle *article = [[HTArticle alloc] init];
    // ... 给article赋值
    
    // Model JSON转换
    NSData *jsonData = [article modelToJSONData];
    NSString *jsonString = [article modelToJSONString];
    id jsonObject = [article modelToJSONObject];
    HTArticle *jsonArticle = [HTArticle modelWithDictionary:jsonObject];
    HTArticle *jsonObjectArticle = [HTArticle modelWithJSON:jsonObject];
    HTArticle *jsonDataArticle = [HTArticle modelWithJSON:jsonData];
    HTArticle *jsonStringArticle = [HTArticle modelWithJSON:jsonString];
    
    // Copy
    HTArticle *anotherArticle = [article copy];
    
    // Encode/Decode    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:article];
    HTArticle *decodeArticle = [NSKeyedUnarchiver unarchiveObjectWithData:data];

其中，HTArticle定义如下：

	@class HTAuthor;
	
	@interface HTArticle : HTHTTPModel
	
	@property (nonatomic, copy) NSString *title;
	@property (nonatomic, copy) NSString *body;
	@property (nonatomic, strong) HTAuthor *author;
	@property (nonatomic, strong) NSArray<NSString *> *comments;
	
	@end
    	
注意点：

1. 属性中如果不是合法的可转成JSON的类型，例如NSData, 通过`modelToJSONString`得到的结果为nil.
2. 嵌套的数据类型例如`HTAuthor`同样要派生自`HTHTTPModel`.
3. 如果存在如下属性，即集合类型(Array, Set, Dictionary等)中的每项不是基本类型(NSString，NSNumber)等，而是从`HTHTTPModel`中派生的，那么需要指明属性值与类型的对应关系；

		@property (nonatomic, strong) NSArray<HTSubscriber *> *subscribers;
		
		@implementation HTArticle

		+ (NSDictionary *)collectionCustomObjectTypes {
		    return @{@"subscribers" : @"HTSubscriber"};
		}
		
		@end

### 2 NSObject+HTModel分类

如果不希望直接从HTHTTPModel中派生，也可以直接使用NSObject+HTModel实现model与json的转换; 使用方式类似`HTHTTPModel`, 详情参见`NSObject+HTModel.h`.

### 3 转换功能的扩展

数据模型类如果遵循`HTModelProtocol`并且实现以下可选方法，可以提供自定义的转换方式.

	@protocol HTModelProtocol
	
	/**
	 *  自定义对于value的转换规则. Note: 一般情况下，默认的转换规则已经够用. 此方法一般用于实现对NSDate的不同形式的格式化字符串或者对NSData等没有默认规则的转化方法.
	 *  如果希望对该value采用默认的规则，即不提供任何定制的处理，则返回nil.
	 *  @param value   待转换的Value
	 *  @param keyPath Value对应的Keypath
	 *
	 *  @return 返回转换后的value.
	 */
	- (id)customTransformedValueToJson:(id)value forKeyPath:(NSString *)keyPath;
	
	/**
	 *  自定义对于value的转换规则. Note: 一般情况下，默认的转换规则已经够用. 此方法一般用于实现对NSDate的不同形式的格式化字符串或者对NSData等没有默认规则的转化方法.
	 *  如果希望对该value采用默认的规则，即不提供任何定制的处理，则返回nil.
	 *  @param value   待转换的Value
	 *  @param keyPath Value对应的Keypath
	 *
	 *  @return 返回转换后的value.
	 */
	- (id)customTransformedValueFromJson:(id)value forKeyPath:(NSString *)keyPath;
	
	@end

<p id="日志使用">
## 七 日志使用

HTNetworking中与网络请求以及数据解析相关的日志都在RestKit模块中，RestKit模块日志与HTLog的日志底层采用同样的日志库CocoaLumberjack提供，因为开关的控制类似，但细节稍有区别，下面想起描述。

### 1 默认日志等级与配置方法

默认日志等级是 `RKLogLevelDefault`; 在Debug模式下是`RKLogLevelInfo`, 而Release模式下是`RKLogLevelWarning`。

可以参见 `RKLog.h` 中关于RKLogLevelDefault的定义

```objective-c

/**
 Set the Default Log Level

 Based on the presence of the DEBUG flag, we default the logging for the RestKit parent component
 to Info or Warning.

 You can override this setting by defining RKLogLevelDefault as a pre-processor macro.
 */
#ifndef RKLogLevelDefault
    #ifdef DEBUG
        #define RKLogLevelDefault RKLogLevelInfo
    #else
        #define RKLogLevelDefault RKLogLevelWarning
    #endif
#endif


```

### 2 改变RestKit的日志等级与开关的方法

如果希望改变日志级别，则在`AppDelegate.m`的`didFinishLaunchingWithOptions`方法中，调用如下方法，则整个 `RestKit` 模块的日志级别调整为 `RKLogLevelInfo` .

```objective-c	   

RKLogConfigureByName("RestKit*", RKLogLevelInfo);

```

如果希望关闭日志，则level参数传递`RKLogLevelOff`即可。

### 3 日志输出与打印

由于`RestKit`相关日志也是由`CocoaLumberjack`提供，所以`Logger`的控制，例如控制是否输出到文件，也是由`HTLog`提供的同一套机制控制的，只要往`DDLog`中添加指定的`Logger`即可。

在`AppDelegate.m`的`didFinishLaunchingWithOptions`方法中，调用如下方法, 则在Debug模式下会输出日志到控制台(TTY)和苹果的日志系统(ASL); 而在Release模式下会输出日志到苹果的日志系统，并且`RKLogLevelError`级别的日志会输出到文件.

```objective-c	   

HTLogInit();

```

其中，HTLogInit();方法的实现如下：

```objective-c	

void HTLogInit()
{
#if DEBUG
    //debug版本，打开ASL和TTY，使用ModuleFormatter输出 module名
    DDTTYLogger.sharedInstance.logFormatter = [HTLogFormatter new];
    [DDLog addLogger:DDTTYLogger.sharedInstance];
    [DDLog addLogger:DDASLLogger.sharedInstance];
    [[DDTTYLogger sharedInstance] setColorsEnabled:YES];
#else
    //release版，关闭ASL，打开TTY和file logger，将所有log level设置为error
    [DDLog addLogger:DDASLLogger.sharedInstance];
    
    DDFileLogger * fileLogger = [[DDFileLogger alloc] init];
    
    fileLogger.maximumFileSize = 1024 * 1;  //  1 KB
    fileLogger.rollingFrequency = 60;       // 60 Seconds
    
    fileLogger.logFileManager.maximumNumberOfLogFiles = 4;
    
    [DDLog addLogger:fileLogger withLevel:DDLogLevelError];
#endif
}

```

如果希望调整输出到文件的日志级别，或者调整是否输出到ASL或者TTY, 可以自己编写类似的代码替换掉上面的代码，例如希望关闭ASL和TTY, 仅打开file logger, 并且所有`Info`级别的日志都写在文件中 ，那么在`didFinishLaunchingWithOptions`里不调用`HTLogInit();` 而是调用如下代码即可：

```objective-c	

    DDFileLogger * fileLogger = [[DDFileLogger alloc] init];
    
    fileLogger.maximumFileSize = 1024 * 1;  //  1 KB
    fileLogger.rollingFrequency = 60;       // 60 Seconds
    
    fileLogger.logFileManager.maximumNumberOfLogFiles = 4;
    
    [DDLog addLogger:fileLogger withLevel:DDLogLevelInfo];
    
```    