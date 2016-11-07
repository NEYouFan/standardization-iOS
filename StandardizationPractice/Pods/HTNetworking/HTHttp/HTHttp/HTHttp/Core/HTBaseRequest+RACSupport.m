//
//  HTBaseRequest+HTRAC.m
//  HTHttp
//
//  Created by Wangliping on 16/4/13.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import <HTHttp/Core/HTBaseRequest+RACSupport.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@implementation HTBaseRequest (RACSupport)

#pragma mark - RAC Signals

- (RACSignal *)basicSignalStart {
    return  [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [self startWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            // 为向前兼容，将request放在元组的最后. 此处无须担心循环引用, 在success和failure回调结束时会解引用.
            [subscriber sendNext:RACTuplePack(operation, mappingResult, self)];
            [subscriber sendCompleted];
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            [subscriber sendError:[HTBaseRequest errorWrappedWithOperation:operation error:error request:self]];
        }];
        
        return [RACDisposable disposableWithBlock:^{
            [self cancel];
        }];
    }];
}

- (RACSignal *)basicSignalStartWithManager:(RKObjectManager *)manager {
    return  [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [self startWithManager:manager success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            [subscriber sendNext:RACTuplePack(operation, mappingResult, self)];
            [subscriber sendCompleted];
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            [subscriber sendError:[HTBaseRequest errorWrappedWithOperation:operation error:error request:self]];
        }];
        
        return [RACDisposable disposableWithBlock:^{
            [self cancel];
        }];
    }];
}

- (RACSignal *)signalStart {
    return  [[self basicSignalStart] replay];
}

- (RACSignal *)signalStartWithRetry:(NSInteger)retryCount {
    return retryCount == 0 ? [self signalStart] : [[[self basicSignalStart] retry:retryCount] replay];
}

- (RACSignal *)signalStartWithManager:(RKObjectManager *)manager {
    return  [[self basicSignalStartWithManager:manager] replay];
}

- (RACSignal *)signalStartWithManager:(RKObjectManager *)manager retryCount:(NSInteger)retryCount {
    return retryCount == 0 ? [self signalStartWithManager:manager] : [[[self basicSignalStartWithManager:manager] retry:retryCount] replay];
}

// 将operation和error都包装到新的error中去.
+ (NSError *)errorWrappedWithOperation:(RKObjectRequestOperation *)operation error:(NSError *)error request:(HTBaseRequest *)request {
    if (nil == operation || nil == error) {
        return error;
    }
    
    NSDictionary *userInfo = @{@"operation":operation, @"error":error, @"request":request};
    return [NSError errorWithDomain:error.domain code:error.code userInfo:userInfo];
}

+ (RACSignal *)batchSignalsOfRequests:(NSArray<HTBaseRequest *> *)requestList {
    NSMutableArray *batchSignals = [NSMutableArray array];
    for (HTBaseRequest *request in requestList) {
        RACSignal *signal = [request signalStart];
        if (nil != signal) {
            [batchSignals addObject:signal];
        }
    }
    
    return [RACSignal merge:batchSignals];
}

+ (RACSignal *)signalSendRequest:(Class)requestClass withMananger:(RKObjectManager *)manager withConfigBlock:(HTConfigRequestBlock)configBlock {
    if (![requestClass isSubclassOfClass:[HTBaseRequest class]]) {
        return nil;
    }
    
    return  [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        HTBaseRequest *request = [[requestClass alloc] init];
        if (nil != configBlock) {
            configBlock(request);
        }
        
        if (nil == manager) {
            [request startWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                [subscriber sendNext:RACTuplePack(operation, mappingResult, request)];
                [subscriber sendCompleted];
            } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                [subscriber sendError:[self errorWrappedWithOperation:operation error:error request:request]];
            }];
        } else {
            [request startWithManager:manager success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                [subscriber sendNext:RACTuplePack(operation, mappingResult, request)];
                [subscriber sendCompleted];
            } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                [subscriber sendError:[self errorWrappedWithOperation:operation error:error request:request]];
            }];
        }
        
        return [RACDisposable disposableWithBlock:^{
            [request cancel];
        }];
    }];
}

+ (RACSignal *)ifRequestSucceed:(HTBaseRequest *)conditionRequest then:(HTBaseRequest *)trueRequest else:(HTBaseRequest *)falseRequest withMananger:(RKObjectManager *)mananger {
    if (nil == conditionRequest || nil == trueRequest || nil == falseRequest) {
        NSAssert(nil, @"Parameters are invalid");
        return nil;
    }
    
    RACSignal *signalCondition = [conditionRequest signalStartWithManager:mananger];
    // Note: 此处无法描述conditionRequest的输出作为trueRequest输入的情况，因为并不清楚trueRequest如何使用conditionRequest的输出，除非使用者自己按照类似的方式来描述各信号之间的关系.
    RACSignal *signalTrueRequest = [trueRequest signalStartWithManager:mananger];
    RACSignal *signalFalseReqeust = [falseRequest signalStartWithManager:mananger];
    
    RACSignal *signalNO = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@(NO)];
        [subscriber sendCompleted];
        return nil;
    }];
    
    RACSignal *signalYES = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@(YES)];
        [subscriber sendCompleted];
        return nil;
    }];
    
    // 如果成功，发送YES; 否则发送NO.
    RACSignal *boolSignal = [[[signalCondition ignoreValues] then:^RACSignal *{
        return signalYES;
    }] catchTo:signalNO];
    
    return [RACSignal if:boolSignal then:signalTrueRequest else:signalFalseReqeust];
}


@end
