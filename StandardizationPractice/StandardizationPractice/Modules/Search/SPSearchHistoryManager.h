//
//  SPSearchHistoryManager.h
//  StandardizationPractice
//
//  Created by 陶泽宇 on 2016/10/25.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SPSearchHistoryManager : NSObject

+ (instancetype)sharedManager;

- (void)addHistory:(NSString *)history;
- (NSArray *)loadHistory:(void(^)(NSArray *result))block;
- (NSArray *)selectFromHistory:(NSString *)keyWord completion:(void(^)(NSArray *result))Block;
- (void)removeAllHistory;


@end
