//
//  RKObjectRequestOperation+HTRAC.h
//  HTHttp
//
//  Created by Wang Liping on 15/9/8.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import <RestKit/Network/RKObjectRequestOperation.h>

@class RACSignal;
@class RKObjectManager;

@interface RKObjectRequestOperation (HTRAC)

@property (nonatomic, strong, readonly) RACSignal *rac_enqueueSignal;

/**
 *  获取RKObjectRequestOperation对应的信号.
 *
 *  @param manager 调度Operation的RKObjectManager.
 *
 *  @return RACSignal对象.
 */
- (RACSignal *)rac_enqueueInManager:(RKObjectManager *)manager;

@end
