//
//  HTCachedResponse.h
//  HTHttp
//
//  Created by NetEase on 15/8/17.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMResultSet;

extern NSString * const HTCacheTable;
extern NSString * const HTCacheColumnRequestKey;
extern NSString * const HTCacheColumnResponse;
extern NSString * const HTCacheColumnVersion;
extern NSString * const HTCacheColumnCreateDate;
extern NSString * const HTCacheColumnExpireDate;

@interface HTCachedResponse : NSObject

@property (nonatomic, strong) NSCachedURLResponse *response;
@property (nonatomic, assign) NSInteger version;
@property (nonatomic, strong) NSDate *createDate;
@property (nonatomic, strong) NSDate *expireDate;
@property (nonatomic, copy)   NSString *requestKey;

// 是否已过期
- (BOOL)isExpired;

// Response的过期时间和创建时间是否正确.
- (BOOL)isDateInvalid;

// 更新为查询结果.
- (void)updateFromCursor:(FMResultSet *)result;

// 保存到持久化存储中.
- (void)save;

// key所对应的
+ (BOOL)hasRecordWithRequestKey:(NSString *)requestKey;

@end
