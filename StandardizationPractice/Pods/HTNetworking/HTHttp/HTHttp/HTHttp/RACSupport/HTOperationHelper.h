//
//  HTOperationHelper.h
//  HTHttp
//
//  Created by Wang Liping on 15/9/14.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <HTHttp/RACSupport/RKObjectRequestOperation+HTRAC.h>

@class RACSignal;
@class RKObjectRequestOperation;
@class RKObjectManager;

typedef RACSignal* (^HTNextSignalBlock)(RKObjectRequestOperation *lastOperation, RKObjectManager *manager);

@interface HTOperationHelper : NSObject

/**
 *  返回一组互相依赖的Operation对应的信号.
 *
 *  @param firstOperation 第一个需要执行的operation.
 *  @param blockList      HTNextSignalBlock的数组. 每一个Block接收上一个信号返回的RKObjectRequestOperation *对象并且转换成为下一个Operation的请求对应的Siganl.
 *                        HTNextSignalBlock的实现方法里面需要做: 1 从得到的RKObjectRequestOperation *对象中得到下一个请求所需要的参数，构建出新的RKObjectRequestOperation对象.        
 *                        2 返回RKObjectReqeustOperation对象对应的Signal.
 *  @param manager        需要调度operation的manager.
 *
 *  @return 返回一个cold的RACSignal对象.
 */
+ (RACSignal *)combinedSignalWith:(RKObjectRequestOperation *)firstOperation nextSignalBlocks:(NSArray *)blockList inMananger:(RKObjectManager *)manager;

/**
 *  返回一组并行的Operation对应的信号
 *
 *  @param operationList RKObjectRequestOperation的数组.
 *  @param mananger      需要调度Operation的Manager
 *
 *  @return 返回一个RACSignal.
 *  使用方法:
 *  RACSignal *batchedSignal = [HTOperationHelper batchedSignalWith:operationList inManager:manager];
 *  [mergedSignal subscribeNext:^(id x) {
 *      // 处理每个operation返回的信息.
 *  } error:^(NSError *error) {
 *      // 任何一个operation发生错误导致所有任务结束.
 *      // TODO: 作为异步的网络请求, 这个时候有一个错误，其余的可以被取消掉吗？
 *  } completed:^{
 *     // 所有operation completed时触发.
 *  }];
 *
 */
+ (RACSignal *)batchedSignalWith:(NSArray *)operationList inManager:(RKObjectManager *)mananger;

/**
 *  当返回的Signal被subscribe时, 首先触发conditionOperation， 如果conditionOperation成功, 则执行trueOperation; 否则，执行falseOperation.
 *
 *  @param conditionOperation 先执行的operation
 *  @param trueOperation      condition operation成功后执行
 *  @param falseOperation     condition operation error后执行.
 *  @param mananger           需要调度Operation的Manager
 *
 *  @return 返回一个可被subscribe的信号.
 */
+ (RACSignal *)if:(RKObjectRequestOperation *)conditionOperation then:(RKObjectRequestOperation *)trueOperation else:(RKObjectRequestOperation *)falseOperation inManager:(RKObjectManager *)mananger;

/**
 *  类似 + (RACSignal *)if:(RKObjectRequestOperation *)conditionOperation then:(RKObjectRequestOperation *)trueOperation else:(RKObjectRequestOperation *)falseOperation;
 *  添加条件说明是否将获取到了非法结果也作为Error来对待.
 *  RKObjectRequestOperation的error分为两种: 一种是请求出错了；另一种是请求是成功的，但是结果并不是想要的结果
 *
 *  @param conditionOperation          先执行的operation
 *  @param trueOperation               condition operation成功后执行
 *  @param falseOperation              condition operation error后执行.
 *  @param mananger                    需要调度Operation的Manager
 *  @param validResultBlock            检查结果是否非法并将非法结果当作错误处理. 当validResultBlock为nil时, 不替换掉operation自身的validResultBlock.
 *
 *  @return 返回一个可被subscribe的冷信号.
 */
+ (RACSignal *)if:(RKObjectRequestOperation *)conditionOperation then:(RKObjectRequestOperation *)trueOperation else:(RKObjectRequestOperation *)falseOperation inManager:(RKObjectManager *)mananger validResultBlock:(HTValidResultBlock)validResultBlock;

/**
 *  默认的valid Result block. 一般validResultBlock使用nil即可，这样即使没有正确解析出任何数据，但是解析过程正确，也会转到success分支而不是error分支.
 *  默认的valid Result block检查返回的结果，如果mappingResult为空或者仅仅有error信息，那么认为发生了错误.
 *  用户可以根据情况定义自己的validResultBlock或者使用默认的或者使用nil.
 *
 *  @return 返回一个有效的HTValidResultBlock.
 */
+ (HTValidResultBlock)defaultValidResultBlock;

@end
