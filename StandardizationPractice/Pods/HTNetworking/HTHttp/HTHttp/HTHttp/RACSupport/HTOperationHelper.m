//
//  HTOperationHelper.m
//  HTHttp
//
//  Created by Wang Liping on 15/9/14.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "HTOperationHelper.h"
#import "RKObjectRequestOperation.h"
#import "RKObjectRequestOperation+HTRAC.h"
#import "ReactiveCocoa/ReactiveCocoa.h"
#import "RKErrorMessage.h"

@implementation HTOperationHelper

+ (RACSignal *)combinedSignalWith:(RKObjectRequestOperation *)firstOperation nextSignalBlocks:(NSArray *)blockList inMananger:(RKObjectManager *)manager {
    RACSignal *signal = [firstOperation rac_enqueueInManager:manager];
    for (HTNextSignalBlock nextBlock in blockList) {
        if (nil == nextBlock) {
            continue;
        }
        
        signal = [signal flattenMap:^RACStream *(id value) {
            NSAssert([value isKindOfClass:[RKObjectRequestOperation class]], @"上一个信号的返回值必须是RKObjectRequestOperation");
            return nextBlock(value, manager);
        }];
    }
    
    return signal;
}

+ (RACSignal *)batchedSignalWith:(NSArray *)operationList inManager:(RKObjectManager *)mananger {
    NSMutableArray *signalList = [NSMutableArray array];
    for (RKObjectRequestOperation *operation in operationList) {
        RACSignal *signal = [operation rac_enqueueInManager:mananger];
        if (nil != signal) {
            [signalList addObject:signal];
        }
    }
    
    return [signalList count] > 0 ? [RACSignal merge:signalList] : nil;
}

+ (RACSignal *)if:(RKObjectRequestOperation *)conditionOperation
             then:(RKObjectRequestOperation *)trueOperation
             else:(RKObjectRequestOperation *)falseOperation
        inManager:(RKObjectManager *)mananger {
    return [self if:conditionOperation then:trueOperation else:falseOperation inManager:mananger validResultBlock:nil];
}

+ (RACSignal *)if:(RKObjectRequestOperation *)conditionOperation then:(RKObjectRequestOperation *)trueOperation else:(RKObjectRequestOperation *)falseOperation inManager:(RKObjectManager *)mananger  validResultBlock:(HTValidResultBlock)validResultBlock {
    if (nil == conditionOperation || nil == trueOperation || nil == falseOperation || nil == mananger) {
        // 为降低难度, 不考虑其中某些operation为nil的状况.
        NSAssert(nil, @"Parameters are invalid");
        return nil;
    }

    if (nil != validResultBlock) {
        conditionOperation.validResultBlock = validResultBlock;
    }

    RACSignal *originSignal = [conditionOperation rac_enqueueInManager:mananger];
    RACSignal *signalCondition = [originSignal replay];
    RACSignal *signalTrueOperaion = [signalCondition flattenMap:^RACStream *(id value) {
        return [trueOperation rac_enqueueInManager:mananger];
    }];
    RACSignal *signalFalseOperation = [falseOperation rac_enqueueInManager:mananger];
    
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
    
    return [RACSignal if:boolSignal then:signalTrueOperaion else:signalFalseOperation];
}

+ (HTValidResultBlock)defaultValidResultBlock {
    return ^(RKObjectRequestOperation *operation) {
        RKMappingResult *result = operation.mappingResult;
        if (0 == [result count]) {
            return NO;
        }
        
        if (1 == [result count] && [result.firstObject isKindOfClass:[RKErrorMessage class]]) {
            return NO;
        }
        
        return YES;
    };
}

@end
