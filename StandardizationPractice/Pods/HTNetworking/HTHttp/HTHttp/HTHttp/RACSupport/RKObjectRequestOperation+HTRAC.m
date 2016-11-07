//
//  RKObjectRequestOperation+HTRAC.m
//  HTHttp
//
//  Created by Wang Liping on 15/9/8.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import <HTHttp/RACSupport/RKObjectRequestOperation+HTRAC.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <RestKit/Network/RKObjectManager.h>
#import <RestKit/ObjectMapping/RKErrorMessage.h>
#import <objc/runtime.h>

static const void *keyHTEnqueueSignal = &keyHTEnqueueSignal;

@implementation RKObjectRequestOperation (HTRAC)

#pragma mark - Property

- (RACSignal *)rac_enqueueSignal {
    return objc_getAssociatedObject(self, keyHTEnqueueSignal);
}

- (void)setRac_enqueueSignal:(RACSignal *)enqueueSignal {
    objc_setAssociatedObject(self, keyHTEnqueueSignal, enqueueSignal, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - Signal Of Operations

- (RACSignal *)rac_enqueueInManager:(RKObjectManager *)manager {
    if (nil != self.rac_enqueueSignal) {
        return self.rac_enqueueSignal;
    }
    
    self.rac_enqueueSignal = [self generateSignalInManager:manager];
    return self.rac_enqueueSignal;
}

#pragma mark - Helper Methods

- (RACSignal *)generateSignalInManager:(RKObjectManager *)manager {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        // didSubscribe block是同步执行的. didSubscirbe和subscibe的方法在同一线程中.
        if ([self isFinished]) {
            if (self.error) {
                [subscriber sendError:self.error];
            } else {
                [subscriber sendNext:self];
                [subscriber sendCompleted];
            }
        } else {
            void (^oldCompBlock)() = self.completionBlock;
            [self setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                // sendNext本身是同步的. next消息的接收和sendNext在同一线程中.
                [subscriber sendNext:operation];
                [subscriber sendCompleted];
                
                if (oldCompBlock) {
                    oldCompBlock();
                }
            } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                [subscriber sendError:error];
                
                if (oldCompBlock) {
                    oldCompBlock();
                }
            }];
            
            RKObjectManager *defaultManager = [RKObjectManager sharedManager];
            RKObjectManager *validManager = (nil == manager) ? defaultManager : manager;
            if (![self isExecuting] && ![self isFinished] && ![self isInQueue:validManager.operationQueue] && ![self isInQueue:defaultManager.operationQueue]) {
                [validManager enqueueObjectRequestOperation:self];
            }
        }
        
        return [RACDisposable disposableWithBlock:^{
            [self cancel];
        }];
    }];
}

- (BOOL)isInQueue:(NSOperationQueue *)queue {
    return nil != queue && [queue operationCount] > 0 && [[queue operations] containsObject:self];
}

@end
