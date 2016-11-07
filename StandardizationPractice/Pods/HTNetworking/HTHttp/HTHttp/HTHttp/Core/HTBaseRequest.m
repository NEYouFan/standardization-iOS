//
//  HTBaseRequest.m
//  HTHttp
//
//  Created by Wang Liping on 15/9/7.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "HTBaseRequest.h"
#import "RKMapping.h"
#import "RKResponseDescriptor.h"
#import "RKRequestDescriptor.h"
#import "RKObjectManager.h"
#import "NSURLRequest+HTCache.h"
#import "NSURLResponse+HTCache.h"
#import "RKHTTPUtilities.h"
#import "RKErrorMessage.h"
#import "RKRequestTypes.h"
#import "NSObject+HTModel.h"
#import "HTModelProtocol.h"
#import "NSURLRequest+HTCache.h"
#import "NSURLRequest+HTFreeze.h"
#import "NSURLRequest+RKRequest.h"
#import "NSURLRequest+HTMock.h"
#import "HTCachePolicyManager.h"
#import "HTFreezePolicyMananger.h"
#import "HTHTTPRequestOperation.h"
#import "HTMockHTTPRequestOperation.h"
#import "HTHttpLog.h"

static const NSTimeInterval kHTDefaultRequestTimeInterval = 60;
static const NSTimeInterval kHTDefaultTimeInterval = 60;

@interface HTBaseRequest () <HTModelProtocol>

@property (nonatomic, strong, readwrite) RKObjectRequestOperation *requestOperation;

@end

@implementation HTBaseRequest

+ (void)initialize {
    RKObjectManager *manager = [RKObjectManager sharedManager];
    NSAssert(nil != manager, @"manager必须在使用所有网络请求创建前创建完毕");
    
    RKRequestDescriptor *requestDescriptor = [self requestDescriptor];
    if (nil != requestDescriptor) {
        [manager addRequestDescriptor:requestDescriptor];
    }
    
    NSArray *responseDesscriptors = [self responseDescriptors];
    for (RKResponseDescriptor *responseDescriptor in responseDesscriptors) {
        [manager addResponseDescriptor:responseDescriptor];
    }
}

#pragma mark - Basic Configuration

+ (RKRequestMethod)requestMethod {
    return RKRequestMethodGET;
}

+ (NSString *)baseUrl {
    return @"";
}

+ (NSString *)requestUrl {
    NSAssert(nil, @"requestUrl必须设置");
    return @"";
}

- (NSTimeInterval)requestTimeoutInterval {
    return kHTDefaultRequestTimeInterval;
}

- (NSDictionary *)requestParams {
    return nil;
}

- (NSDictionary *)requestHeaderFieldValueDictionary {
    return nil;
}

#pragma mark - Cache Configuration

- (BOOL)enableCache {
    return HTCachePolicyNoCache != [self cacheId];
}

- (Class<HTCachePolicyProtocol>)cachePolicyClass {
    return nil;
}

- (NSString *)requestMethodString {
    return RKStringFromRequestMethod([[self class] requestMethod]);
}

- (NSString *)cacheKey {
    return [self cacheKeyWithManager:nil];
}

- (NSString *)cacheKeyWithManager:(RKObjectManager *)mananger {
    NSString *baseUrl = [[self class] baseUrl];
    if ([baseUrl length] == 0) {
        baseUrl = (nil == mananger) ? [[[self class] defaultBaseURL] absoluteString] : [mananger.requestProvider.baseURL absoluteString];
    }
    
    NSDictionary *requestParamsForCacheKey = [self cacheKeyFilteredRequestParams:[self requestParams]];
    return [NSURLRequest ht_cacheKeyWithMethod:[self requestMethodString] baseUrl:baseUrl requestUrl:[[self class] requestUrl] parameters:requestParamsForCacheKey sensitiveData:[self cacheSensitiveData]];
}

- (NSDictionary *)cacheKeyFilteredRequestParams:(NSDictionary *)params {
    return params;
}

- (BOOL)isDataFromCache {
    return _requestOperation.HTTPRequestOperation.response.ht_isFromCache;
}

- (NSInteger)cacheVersion {
    return 0;
}

- (NSTimeInterval)cacheExpireTimeInterval {
    return 0;
}

- (id)cacheSensitiveData {
    return nil;
}

#pragma mark - Request Operations

- (void)start {
    [self startWithManager:nil];
}

- (void)startWithManager:(RKObjectManager *)manager {
    if (nil == manager) {
        manager = [self defaultObjectManager];
    }
    
    BOOL needCustomRequest = [self needCustomRequest];
    HTLogHTTPDebug(@"Start HTRequest as required, request class name: %@, url: %@, method: %@, custom request : %@", NSStringFromClass([self class]), [[self class] requestUrl],
                   RKStringFromRequestMethod([[self class] requestMethod]), needCustomRequest ? @"YES" : @"NO");
    
    RKObjectRequestOperation *operation = needCustomRequest ? [self buildCustomRequestOperationWithManager:manager] : [self buildRequestOperationWithManager:manager];
    NSAssert(nil != operation, @"请求的operation无法创建");
    [self configOperation:operation];
    [manager enqueueObjectRequestOperation:operation];
}

- (void)cancel {
    [_requestOperation cancel];
}

- (BOOL)isExecuting {
    return [[self requestOperation] isExecuting];
}

#pragma mark - RKObjectManager Configuration

- (BOOL)needCustomRequest {
    // 默认情况下, 如果需要Cache, 则需要对request进行定制.
    // 如果requestType有定义，也需要对request进行定制，即使requestType是RKRequestTypeHTTP. 原因是，调用者可以为RKRequestTypeHTTP定义其他的发送请求的方法.
    // 如果允许冻结，那么也需要对request进行定制，设置freezeId等.
    return [self enableCache] || ([[self requestType] length] > 0) || [self canFreeze] || [self enableMock];
}

+ (RKRequestDescriptor *)requestDescriptor {
    RKMapping *requestMapping = [self requestMapping];
    Class requestObjectClass = [self requestObjectClass];
    if (nil == requestMapping || nil == requestObjectClass) {
        return nil;
    }
    
    RKRequestDescriptor *requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:[self requestMapping] objectClass:[self requestObjectClass] rootKeyPath:[self requestRootKeyPath] method:RKRequestMethodAny];
    return requestDescriptor;
}

+ (RKMapping *)requestMapping {
    return nil;
}

+ (Class)requestObjectClass {
    return nil;
}

+ (NSString *)requestRootKeyPath {
    return @"";
}

+ (NSArray<RKResponseDescriptor *> *)responseDescriptors {
    RKResponseDescriptor *responseDescriptor = [self responseDescriptor];
    if (nil == responseDescriptor) {
        return nil;
    }
    
    return [NSArray arrayWithObject:responseDescriptor];
}

+ (RKResponseDescriptor *)responseDescriptor {
    RKMapping *responseMapping = [self responseMapping];
    if (nil == responseMapping) {
        return nil;
    }
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:responseMapping method:[self requestMethod] pathPattern:[self pathPattern] keyPath:[self keyPath] statusCodes:[self statusCodes]];
    
    return responseDescriptor;
}

+ (RKMapping *)responseMapping {
    return nil;
}

+ (NSString *)pathPattern {
    // 默认情况下同requestUrl一致即可.
    NSString *requestUrl = [self requestUrl];
    return [requestUrl length] > 0 ? requestUrl : @"";
}

+ (NSString *)keyPath {
    // 默认传nil表示全部匹配.
    return nil;
}

+ (NSIndexSet *)statusCodes {
    return RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
}

- (RKMappingResult *)requestResult {
    return _requestOperation.mappingResult;
}

#pragma mark - Special Configuration

- (NSString *)requestType {
    // 这里返回nil而不用RKRequestTypeHTTP的原因是，可以采用默认的发送方式而不需要多一步获取发送请求类的操作.
    return nil;
}

- (HTConstructingMultipartFormBlock)constructingBodyBlock {
    return nil;
}

- (HTValidResultBlock)validResultBlock {
    return nil;
}

- (void)customRequest:(NSMutableURLRequest *)request {
    // Nothing needs to be done.
}

- (NSString *)mockJsonFilePath {
    if (!self.enableMock || [_mockJsonFilePath length] > 0) {
        return _mockJsonFilePath;
    }
    
    return [self defaultMockJsonFilePath];
}

- (NSString *)defaultMockJsonFilePath {
    NSString *method = [RKStringFromRequestMethod([[self class] requestMethod]) lowercaseString];
    NSString *requestUrl = [[self class] requestUrl];
    NSString *requestUrlToName = [requestUrl stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    NSString *jsonFileName = [NSString stringWithFormat:@"%@%@", method, requestUrlToName];
    return [[NSBundle mainBundle] pathForResource:jsonFileName ofType:@"json"];
}

#pragma mark - Frozen Requests

- (BOOL)canFreeze {
    return HTFreezePolicyNoFreeze != _freezePolicyId;
}

- (Class<HTFreezePolicyProtocol>)frozenPolicyClass {
    return nil;
}

- (NSTimeInterval)freezeExpireTimeInterval {
    return 0;
}

- (NSString *)freezeKey {
    return [self freezeKeyWithManager:nil];
}

- (NSString *)freezeKeyWithManager:(RKObjectManager *)mananger {
    NSString *baseUrl = [[self class] baseUrl];
    if ([baseUrl length] == 0) {
        baseUrl = (nil == mananger) ? [[[self class] defaultBaseURL] absoluteString] : [mananger.requestProvider.baseURL absoluteString];
    }
    
    // Freeze Key与Cache Key的计算方式相同. 区别在于不需要进行参数过滤.
    return [NSURLRequest ht_cacheKeyWithMethod:[self requestMethodString] baseUrl:baseUrl requestUrl:[[self class] requestUrl] parameters:[self requestParams] sensitiveData:[self freezeSensitiveData]];
}

- (id)freezeSensitiveData {
    return nil;
}

#pragma mark - Callbacks

- (void)startWithSuccess:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success
                 failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure {
    [self setCompletionBlockWithSuccess:success failure:failure];
    [self start];
}

- (void)startWithManager:(RKObjectManager *)manager
                 success:(void (^)(RKObjectRequestOperation *, RKMappingResult *))success
                 failure:(void (^)(RKObjectRequestOperation *, NSError *))failure {
    [self setCompletionBlockWithSuccess:success failure:failure];
    [self startWithManager:manager];
}

- (void)setCompletionBlockWithSuccess:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success
                              failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure {
    self.successCompletionBlock = success;
    self.failureCompletionBlock = failure;
}

- (void)clearCompletionBlock {
    self.successCompletionBlock = nil;
    self.failureCompletionBlock = nil;
}

#pragma mark - Auto Generated Code 

// 该方法的实现允许Request子类将子类的属性转换成为JSON对象或者JSON字符串. 
+ (NSArray *)modelPropertyBlacklist {
    return [[[HTBaseRequest class] ht_allPropertyInfoDic] allKeys];
}

#pragma mark - Send Requests

+ (RKObjectManager *)objectManager {
    RKObjectManager *manager = [RKObjectManager sharedManager];
    NSAssert(nil != manager, @"请检查HTNetworkingInit()是否有被正确调用");
    return manager;
}

+ (void)cancelAllRequests {
    [[self objectManager] cancelAllObjectRequestOperationsWithMethod:RKRequestMethodAny];
}

- (RKObjectManager *)defaultObjectManager {
    return [[self class] objectManager];
}

+ (NSURL *)defaultBaseURL {
    return [self objectManager].requestProvider.baseURL;
}

- (void)handleSuccessfulResultWithRequest:(HTBaseRequest *)request operation:(RKObjectRequestOperation *)operation result:(RKMappingResult *)mappingResult {
    if ([request.requestDelegate respondsToSelector:@selector(htRequestFinished:)]) {
        [request.requestDelegate htRequestFinished:request];
    }
    
    if (request.successCompletionBlock) {
        request.successCompletionBlock(operation, mappingResult);
    }
    
    // 避免循环引用.
    // Note: 这里不能通过[operation setCompletionBlockWithSuccess:nil failure:nil];达到目的，尽管能够正确的打破request和operation之间的循环引用.
    // 原因是，setCompletionBlockWithSuccess并不是简单的清除block, 而是设置了一个新的completion block, 在completion block被调用的时候才会执行清除操作.
    // 而NSOperation的completion block是仅仅只会执行一次的, 在operation执行完毕后调用setCompletionBlockWithSuccess可能会引发内存泄漏的.
    [operation clearCompletionBlocks];
    
    
    // 清理request的completion block.
    // 该操作并非必需的，因为request持有了success与failure block, 但success与failure block默认情况下并不持有request.
    // 但是，实际应用开发过程中会出现如下情况: controller持有request, request持有block, block中会访问controller的属性，此时正常用法是需要在block中使用weak-strong pattern避免循环引用.
    // 然后由于request对于block的持有是隐式的, 所以应用开发人员不太会意识到这里会出现循环应用。理论上，应用开发人员不需要关注内部实现，所以此处在请求结束后清理掉先前设置的completion block.
    // 带来的影响是，request在start之前一定需要确保success与failure block被设置了。
    // 此外，如果应用开发者仅仅在request中设置block, 而不调用，那么该循环引用不会被打破.
    [request clearCompletionBlock];
}

- (void)handleErrorWithRequest:(HTBaseRequest *)request operation:(RKObjectRequestOperation *)operation error:(NSError *)error {
    if ([request.requestDelegate respondsToSelector:@selector(htRequestFailed:)]) {
        [request.requestDelegate htRequestFailed:request];
    }
    
    if (request.failureCompletionBlock) {
        request.failureCompletionBlock(operation, error);
    }
    
    // 避免循环引用.
    [operation clearCompletionBlocks];
    
    [request clearCompletionBlock];
}

#pragma mark - Custom Request

- (NSURLRequest *)customURLRequest:(NSURLRequest *)request withRKManager:(RKObjectManager *)objectManager {
    if (nil == request) {
        return request;
    }
    
    // 所创建的request已经应用上了RKObjectManager的默认配置了.
    // 个性化定制request.
    NSMutableURLRequest *customizedRequest = [request mutableCopy];
    // 基本配置.
    if (0 != self.requestTimeoutInterval && kHTDefaultTimeInterval != self.requestTimeoutInterval) {
        customizedRequest.timeoutInterval = self.requestTimeoutInterval;
    }
    
    // 不能直接作用于Manager的default Headers. 因为Manager的Default Headers是被所有请求应用的.
    // 直接替换掉Request默认的Header设置.
    NSDictionary *customHeader = [self requestHeaderFieldValueDictionary];
    [customHeader enumerateKeysAndObjectsUsingBlock:^(id field, id value, BOOL * __unused stop) {
        // Request的设置直接替换掉默认的设置.
        [customizedRequest setValue:value forHTTPHeaderField:field];
    }];
    
    // 设置Cache相关.
    customizedRequest.ht_cachePolicy = [self cacheId];
    customizedRequest.ht_responseVersion = [self cacheVersion];
    customizedRequest.ht_cacheExpireTimeInterval = [self cacheExpireTimeInterval];
    customizedRequest.ht_cacheKey = [self cacheKeyWithManager:objectManager];
    
    // 设置requestType相关.
    customizedRequest.rk_requestTypeName = [self requestType];
    
    // 注册cache policyClass.
    Class<HTCachePolicyProtocol> policyClass = [self cachePolicyClass];
    if (customizedRequest.ht_cachePolicy > HTCachePolicyCacheFirst && policyClass != nil) {
        [[HTCachePolicyManager sharedInstance] registeCachePolicyWithPolicyId:customizedRequest.ht_cachePolicy policy:policyClass];
    }
    
    customizedRequest.ht_canFreeze = [self canFreeze];
    if (customizedRequest.ht_canFreeze) {
        customizedRequest.ht_freezeExpireTimeInterval = [self freezeExpireTimeInterval];
        customizedRequest.ht_freezeId = [self freezeKeyWithManager:objectManager];
        customizedRequest.ht_freezePolicyId = [self freezePolicyId];
        Class<HTFreezePolicyProtocol> policyClass = [self frozenPolicyClass];
        if (customizedRequest.ht_freezePolicyId > HTFreezePolicySendFreezeAutomatically && policyClass != nil) {
            [[HTFreezePolicyMananger sharedInstance] registeFreezePolicyWithPolicyId:customizedRequest.ht_freezePolicyId policy:policyClass];
        }
    }
    
    if ([self enableMock]) {
        customizedRequest.ht_mockResponseObject = self.mockResponseObject;
        customizedRequest.ht_mockResponseData = self.mockResponseData;
        customizedRequest.ht_mockResponseString = self.mockResponseString;
        customizedRequest.ht_mockError = self.mockError;
        customizedRequest.ht_mockResponse = self.mockResponse;
        customizedRequest.ht_mockBlock = self.mockBlock;
        customizedRequest.ht_mockJsonFilePath = self.mockJsonFilePath;
    }
    
    // 允许子类对Request作额外的自定义.
    [self customRequest:customizedRequest];
    
    return customizedRequest;
}

- (RKObjectRequestOperation *)buildCustomRequestOperationWithManager:(RKObjectManager *)manager {
    RKRequestMethod requestMethod = [[self class] requestMethod];
    NSString *path = [[self class] requestFullPath];
    NSDictionary *params = [self requestParams];
    HTConstructingMultipartFormBlock block = [self constructingBodyBlock];
    NSURLRequest *originRequest = nil;
    if (nil == block) {
        originRequest = [manager requestWithObject:nil method:requestMethod path:path parameters:params];
    } else {
        originRequest = [manager multipartFormRequestWithObject:nil method:requestMethod path:path parameters:params constructingBodyWithBlock:[self constructingBodyBlock]];
    }
    
    NSURLRequest *customizedRequest = [self customURLRequest:originRequest withRKManager:manager];
    // 回调block在configOperaion里完成.
    return [manager objectRequestOperationWithRequest:customizedRequest success:nil failure:nil];
}

- (RKObjectRequestOperation *)buildRequestOperationWithManager:(RKObjectManager *)manager {
    RKRequestMethod requestMethod = [[self class] requestMethod];
    NSString *path = [[self class] requestFullPath];
    NSDictionary *params = [self requestParams];
    return [manager appropriateObjectRequestOperationWithObject:nil method:requestMethod path:path parameters:params];
}

- (void)configOperation:(RKObjectRequestOperation *)operation {
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [self handleSuccessfulResultWithRequest:self operation:operation result:mappingResult];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self handleErrorWithRequest:self operation:operation error:error];
    }];
    
    HTValidResultBlock validResultBlock = [self validResultBlock];
    if (validResultBlock != nil) {
        operation.validResultBlock = validResultBlock;
    }
    
    self.requestOperation = operation;
}

+ (NSString *)requestFullPath {
    NSString *baseUrl = [self baseUrl];
    NSString *requestUrl = [self requestUrl];
    NSString *path = [baseUrl length] > 0 ? [NSString stringWithFormat:@"%@%@", baseUrl, requestUrl] : requestUrl;
    return path;
}

@end
