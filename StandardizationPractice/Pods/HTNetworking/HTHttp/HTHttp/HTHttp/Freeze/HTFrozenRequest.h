//
//  HTFreezedRequest.h
//  Pods
//
//  Created by Wangliping on 15/10/30.
//
//

#import <Foundation/Foundation.h>

@class FMResultSet;

extern NSString * const HTFreezeTable;
extern NSString * const HTFreezeColumnRequestKey;
extern NSString * const HTFreezeColumnRequest;
extern NSString * const HTFreezeColumnVersion;
extern NSString * const HTFreezeColumnCreateDate;
extern NSString * const HTFreezeColumnExpireDate;

@interface HTFrozenRequest : NSObject

@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, assign) NSInteger version;
@property (nonatomic, strong) NSDate *createDate;       // Freeze date.
@property (nonatomic, strong) NSDate *expireDate;
@property (nonatomic, copy)   NSString *requestKey;

// 是否已过期
- (BOOL)isExpired;

// Request的过期时间和创建时间是否正确.
- (BOOL)isDateInvalid;

// 更新为查询结果.
- (void)updateFromCursor:(FMResultSet *)result;

// 保存到持久化存储中.
- (void)save;

// key所对应的
+ (BOOL)hasRecordWithRequestKey:(NSString *)requestKey;

@end
