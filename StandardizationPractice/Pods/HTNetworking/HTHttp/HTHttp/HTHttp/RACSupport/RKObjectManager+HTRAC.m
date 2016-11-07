//
//  RKObjectManager+HTRAC.m
//  HTHttp
//
//  Created by Wang Liping on 15/9/7.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "RKObjectManager+HTRAC.h"
#import "ReactiveCocoa/ReactiveCocoa.h"
#import "RKObjectRequestOperation+HTRAC.h"

@implementation RKObjectManager (HTRAC)

- (RACSignal *)rac_getObject:(id)object
                        path:(NSString *)path
                  parameters:(NSDictionary *)parameters {
    return [self rac_operationWithObject:object method:RKRequestMethodGET path:path parameters:parameters];
}

- (RACSignal *)rac_getObjectsAtPath:(NSString *)path
                         parameters:(NSDictionary *)parameters {
    return [self rac_operationWithObject:nil method:RKRequestMethodGET path:path parameters:parameters];
}

- (RACSignal *)rac_postObject:(id)object
                         path:(NSString *)path
                   parameters:(NSDictionary *)parameters {
    return [self rac_operationWithObject:object method:RKRequestMethodPOST path:path parameters:parameters];
}

- (RACSignal *)rac_putObject:(id)object
                        path:(NSString *)path
                  parameters:(NSDictionary *)parameters {
    return [self rac_operationWithObject:object method:RKRequestMethodPUT path:path parameters:parameters];
}

- (RACSignal *)rac_deleteObject:(id)object
                           path:(NSString *)path
                     parameters:(NSDictionary *)parameters {
    return [self rac_operationWithObject:object method:RKRequestMethodDELETE path:path parameters:parameters];
}

- (RACSignal *)rac_patchObject:(id)object
                          path:(NSString *)path
                    parameters:(NSDictionary *)parameters {
    return [self rac_operationWithObject:object method:RKRequestMethodPATCH path:path parameters:parameters];
}

- (RACSignal *)rac_operationWithObject:(id)object
                                method:(RKRequestMethod)method
                                  path:(NSString *)path
                            parameters:(NSDictionary *)parameters {
    RKObjectRequestOperation *operation = [self appropriateObjectRequestOperationWithObject:object method:method path:path parameters:parameters];
    return [operation rac_enqueueInManager:self];
}

- (RACSignal *)rac_operationWithObject:(id)object
                                method:(RKRequestMethod)method
                                  path:(NSString *)path
                            parameters:(NSDictionary *)parameters
                            retryCount:(NSInteger)retryCount {
    if (0 == retryCount) {
        return [self rac_operationWithObject:object method:method path:path parameters:parameters];
    }
    
    // 由于Operation不能反复被调度, 因此不通过Operation来获取信号.
    RACSignal *signal = [self rac_startNewOperationWithObject:object method:method path:path parameters:parameters];
    // 如果不加replay, 那么多次subscribe的时候会执行多次.
    return [[signal retry:retryCount] replay];
    
    // Note: 不能使用下面的. 否则不会真正的执行重试.
    // return [[signal replay] retry:retryCount];
}

// 每次都会新建新的Operation并且发送请求，该Signal存在副作用. 如果需要每次新建Operation但是每次订阅时只发送一次，请replay后再使用.
- (RACSignal *)rac_startNewOperationWithObject:(id)object
                                        method:(RKRequestMethod)method
                                          path:(NSString *)path
                                    parameters:(NSDictionary *)parameters {
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        RKObjectRequestOperation *operation = [self appropriateObjectRequestOperationWithObject:object method:method path:path parameters:parameters];
        [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            [subscriber sendNext:operation];
            [subscriber sendCompleted];
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            [subscriber sendError:error];
        }];
        [self enqueueObjectRequestOperation:operation];
        
        return [RACDisposable disposableWithBlock:^{
            [operation cancel];
        }];
    }];
    
    return signal;
}

@end
