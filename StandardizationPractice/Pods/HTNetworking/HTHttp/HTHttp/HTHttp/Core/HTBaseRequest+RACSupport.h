//
//  HTBaseRequest+HTRAC.h
//  HTHttp
//
//  Created by Wangliping on 16/4/13.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import "HTBaseRequest.h"

@interface HTBaseRequest (RACSupport)

#pragma mark - RAC Signals

/**
 *  发送请求的信号.
 *  信号的使用方式:
 *  RACSignal *signal = [request signalStart];
 [mergedSignal subscribeNext:^(id x) {
 RACTupleUnpack(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) = (RACTuple *)x;
 // 使用operaiton和mappingResult
 } error:^(NSError *error) {
 // 请求失败，errorCode与errorDomain可直接从error中获取.
 NSDictionary *userInfo = error.userInfo;
 RKObjectRequestOperation *operation = userInfo[@"operation"];
 NSError *originError = userInfo[@"error"];
 
 // 使用operation与originError, 对应原有failure block中的回调返回值.
 } completed:^{
 // 请求结束.
 }];
 *
 *  @return 返回一个RACSignal对象，该Signal即使被重复订阅也仅发送一次网络请求.
 */
- (RACSignal *)signalStart;

/**
 *  发送请求的信号.
 *
 *  @param retryCount 重试的次数. 为0时，该方法效果同- (RACSignal *)signalStart;
 *  @return 返回一个RACSignal对象，该Signal即使被重复订阅也仅发送一次网络请求.
 */
- (RACSignal *)signalStartWithRetry:(NSInteger)retryCount;

/**
 *  使用manager发送请求的信号.
 *
 *  @param manager 发送请求的Mananger.
 *
 *  @return 返回一个RACSignal对象，该Signal即使被重复订阅也仅发送一次网络请求.
 */
- (RACSignal *)signalStartWithManager:(RKObjectManager *)manager;

/**
 *  使用manager发送请求的信号.
 *
 *  @param manager 发送请求的Mananger.
 *  @param retryCount 重试的次数. 为0时，该方法效果同- (RACSignal *)signalStartWithManager:(RKObjectManager *)manager;
 *
 *  @return 返回一个RACSignal对象，该Signal即使被重复订阅也仅发送一次网络请求.
 */
- (RACSignal *)signalStartWithManager:(RKObjectManager *)manager retryCount:(NSInteger)retryCount;

/**
 *  多个请求的组合信号. 该信号被订阅时，所有请求正确结束才会触发completed事件；如果有一个请求错误，那么整个信号流会失败；适用于同一个页面的数据来源于多个不同请求的情况.
 *
 *  @param requestList HTBaseRequest的一个数组.
 *
 *  @return 返回一个RACSignal对象，该Signal即使被重复订阅也仅发送一次网络请求.
 */
+ (RACSignal *)batchSignalsOfRequests:(NSArray<HTBaseRequest *> *)requestList;

/**
 *  创建一个信号，该信号被订阅时，会创建一个新的request并且进行请求的配置与发送. 如果希望排除重复发送请求的副作用，请将信号replay后再使用.
 *
 *  @param requestClass request的类，必须是HTBaseRequest的子类.
 *  @param manager      发送请求的Manager.
 *  @param configBlock  用于对请求进行个性化的定制.
 *
 *  @return 返回一个RACSignal信号对象.
 */
+ (RACSignal *)signalSendRequest:(Class)requestClass withMananger:(RKObjectManager *)manager withConfigBlock:(HTConfigRequestBlock)configBlock;

/**
 *  发送请求的信号. 该信号描述如下的事件流：如果conditionRequest成功，则发送trueRequest; 否则发送falseRequest.
 *
 *  @param conditionRequest 作为判断条件的请求.
 *  @param trueRequest      conditionRequest成功后需要发送的请求.
 *  @param falseRequest     conditionRequest失败后需要发送的请求.
 *  @param mananger         发送请求的Manager, 如果为nil, 则使用HTNetworkAgent中默认的方式发送请求.
 *
 *  @return 返回一个RACSignal信号对象.
 */
+ (RACSignal *)ifRequestSucceed:(HTBaseRequest *)conditionRequest then:(HTBaseRequest *)trueRequest else:(HTBaseRequest *)falseRequest withMananger:(RKObjectManager *)mananger;

@end
