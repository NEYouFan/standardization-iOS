//
//  HTBaseRequest+Advanced.h
//  HTHttp
//
//  Created by Wangliping on 16/4/12.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import "HTBaseRequest.h"

@interface HTBaseRequest (Advanced)

#pragma mark - Support Multi Object Managers

+ (void)registerInMananger:(RKObjectManager *)manager;

#pragma mark - Mock Test

/**
 *  激活Mock数据的测试.
 */
+ (void)enableMockTest;

/**
 *  激活Mock数据的测试.
 */
+ (void)disableMockTest;

/**
 *  激活Mock数据的测试.
 */
+ (void)enableMockTestInManager:(RKObjectManager *)manager;

/**
 *  激活Mock数据的测试.
 */
+ (void)disableMockTestInManager:(RKObjectManager *)manager;

@end
