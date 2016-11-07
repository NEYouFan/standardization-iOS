//
//  SPBaseRequest.m
//  StandardizationPractice
//
//  Created by 陶泽宇 on 2016/10/20.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import "SPBaseRequest.h"

@implementation SPBaseRequest


- (void)setCompletionBlockWithSuccess:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success
                              failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure {
    void (^successCompletionBlock)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) =^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        // 处理通用的成功逻辑
        if (success) {
            success(operation, mappingResult);
        }
    };
    
    void (^failureCompletionBlock)(RKObjectRequestOperation *operation, NSError *error) = ^(RKObjectRequestOperation *operation, NSError *error){
        // 处理通用的失败逻辑
        if (error.code == NSURLErrorCancelled) {
            return;
        }
        if (failure) {
            failure(operation, error);
        }
    };
    self.successCompletionBlock = successCompletionBlock;
    self.failureCompletionBlock = failureCompletionBlock;
}

@end
