//
//  HTNetworkAgentHelper.m
//  Pods
//
//  Created by Wang Liping on 15/10/9.
//
//

#import "HTNetworkingHelper.h"
#import "RKObjectManager.h"
#import "HTHTTPRequestOperation.h"
#import "RestKit.h"
#import "HTHttpLog.h"

RKObjectManager* HTNetworkingInit(NSURL *baseURL) {
    if (nil != [RKObjectManager sharedManager]) {
        HTLogHTTPError(@"HTNetworkingInit方法没有在创建其他RKObjectManager前调用!");
    }
    
    // 不考虑初始化多次的问题. 通过文档来约束. 在发请求之前可以初始化多次.
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:baseURL];
    [manager registerRequestOperationClass:[HTHTTPRequestOperation class]];
    
    
    [RKObjectManager setSharedManager:manager];
    
    return manager;
}
