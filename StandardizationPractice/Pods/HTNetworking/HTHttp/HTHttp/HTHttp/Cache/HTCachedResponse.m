//
//  HTCachedResponse.m
//  HTHttp
//
//  Created by NetEase on 15/8/17.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "HTCachedResponse.h"
#import "FMResultSet.h"
#import "HTCacheDBHelper.h"
#import "HTHTTPDate.h"

NSString * const HTCacheTable = @"TBL_HT_CACHE_RESPONSE";
NSString * const HTCacheColumnRequestKey = @"requestkey";
NSString * const HTCacheColumnResponse = @"response";
NSString * const HTCacheColumnVersion = @"version";
NSString * const HTCacheColumnCreateDate = @"createdate";
NSString * const HTCacheColumnExpireDate = @"expiredate";

@implementation HTCachedResponse

- (BOOL)isExpired {
    // 过期时间早于当前时间，认为已过期.
    NSDate *now = [[HTHTTPDate sharedInstance] now];
    return (nil != _expireDate && [_expireDate earlierDate:now] == _expireDate);
}

- (BOOL)isDateInvalid {
    // 过期时间早于创建时间, 说明response无效.
    return (nil != _expireDate && [_expireDate earlierDate:_createDate] == _expireDate);
}

#pragma mark - Save & Load

- (void)updateFromCursor:(FMResultSet *)result {
    self.version = [result intForColumn:HTCacheColumnVersion];
    long long createDateInterval = [result longLongIntForColumn:HTCacheColumnCreateDate];
    long long expireDateInterval = [result longLongIntForColumn:HTCacheColumnExpireDate];
    self.createDate = createDateInterval > 0 ? [NSDate dateWithTimeIntervalSince1970:createDateInterval] : nil;
    self.expireDate = expireDateInterval > 0 ? [NSDate dateWithTimeIntervalSince1970:expireDateInterval] : nil;
    
    self.requestKey = [result stringForColumn:HTCacheColumnRequestKey];
    
    NSData *data = [result dataForColumn:HTCacheColumnResponse];
    self.response = [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

- (void)save {
    BOOL isRecordExists = [[self class] hasRecordWithRequestKey:_requestKey];
    
    NSString *sqlUpdate = @"";
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_response];
    if (nil == data) {
        return;
    }
    
    if (!isRecordExists) {
        sqlUpdate = [NSString stringWithFormat:@"INSERT INTO %@ (%@, %@, %@, %@, %@) VALUES ('%@', ?, %@, %qi, %qi)", HTCacheTable, HTCacheColumnRequestKey, HTCacheColumnResponse, HTCacheColumnVersion, HTCacheColumnCreateDate, HTCacheColumnExpireDate, _requestKey, @(_version), (long long)[_createDate timeIntervalSince1970], (long long)[_expireDate timeIntervalSince1970]];
    } else {
        sqlUpdate = [NSString stringWithFormat:@"UPDATE %@ SET %@ = ?, %@ = %@, %@ = %qi, %@ = %qi WHERE %@ = '%@'", HTCacheTable, HTCacheColumnResponse, HTCacheColumnVersion, @(_version), HTCacheColumnCreateDate, (long long)[_createDate timeIntervalSince1970], HTCacheColumnExpireDate, (long long)[_expireDate timeIntervalSince1970], HTCacheColumnRequestKey, _requestKey];
    }
    
    [HT_HTTP_DB executeUpdate:sqlUpdate arguments:@[data]];
}

+ (BOOL)hasRecordWithRequestKey:(NSString *)requestKey {
    if (0 == [requestKey length]) {
        return NO;
    }
    
    __block BOOL isRecordExists = NO;
    NSString *sql = [NSString stringWithFormat:@"SELECT 1 FROM %@ where %@ = '%@'", HTCacheTable, HTCacheColumnRequestKey, requestKey];
    [HT_HTTP_DB executeQuery:sql result:^(FMResultSet *rs, BOOL *end) {
        isRecordExists = (nil != rs);
    }];

    return isRecordExists;
}

@end
