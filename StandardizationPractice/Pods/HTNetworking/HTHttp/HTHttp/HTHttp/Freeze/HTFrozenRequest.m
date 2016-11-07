//
//  HTFreezedRequest.m
//  Pods
//
//  Created by Wangliping on 15/10/30.
//
//

#import "HTFrozenRequest.h"
#import "FMResultSet.h"
#import "HTFreezeDBHelper.h"
#import "HTFreezeRequestHelper.h"
#import "HTHTTPLog.h"
#import "HTHTTPDate.h"
#import <objc/runtime.h>

NSString * const HTFreezeTable = @"TBL_HT_FREEZE_REQUEST";
NSString * const HTFreezeColumnRequestKey = @"requestkey";
NSString * const HTFreezeColumnRequest = @"request";
NSString * const HTFreezeColumnRequestProperty = @"property";   // 用于存放Request在Category中定义的属性.
NSString * const HTFreezeColumnVersion = @"version";
NSString * const HTFreezeColumnCreateDate = @"createdate";
NSString * const HTFreezeColumnExpireDate = @"expiredate";

@implementation HTFrozenRequest

- (BOOL)isExpired {
    // 过期时间早于当前时间，认为已过期.
    return (nil != _expireDate && [_expireDate earlierDate:[[HTHTTPDate sharedInstance] now]] == _expireDate);
}

- (BOOL)isDateInvalid {
    // 过期时间早于创建时间, 说明request无效.
    return (nil != _expireDate && [_expireDate earlierDate:_createDate] == _expireDate);
}

#pragma mark - Save & Load

- (void)updateFromCursor:(FMResultSet *)result {
    self.version = [result intForColumn:HTFreezeColumnVersion];
    long long createDateInterval = [result longLongIntForColumn:HTFreezeColumnCreateDate];
    long long expireDateInterval = [result longLongIntForColumn:HTFreezeColumnExpireDate];
    self.createDate = createDateInterval > 0 ? [NSDate dateWithTimeIntervalSince1970:createDateInterval] : nil;
    self.expireDate = expireDateInterval > 0 ? [NSDate dateWithTimeIntervalSince1970:expireDateInterval] : nil;
    
    self.requestKey = [result stringForColumn:HTFreezeColumnRequestKey];
    
    NSData *data = [result dataForColumn:HTFreezeColumnRequest];
    if (nil != data) {
        self.request = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }

    NSData *propertyData = [result dataForColumn:HTFreezeColumnRequestProperty];
    NSDictionary *properties = (nil != propertyData) ? [NSKeyedUnarchiver unarchiveObjectWithData:propertyData] : nil;
    // 为了避免Crash, 加一个try-catch. 理论上，是需要在循环内部加try-catch的，以便一个属性出错的时候还可以继续.
    // 但实际情况中，不会出现找不到属性的情况，故考虑到性能，不在循环内部加try-catch.
    @try {
        for (NSString *propertyName in properties) {
            NSObject *propertyValue = [properties objectForKey:propertyName];
            if ([self.request respondsToSelector:NSSelectorFromString(propertyName)]) {
                [self.request setValue:propertyValue forKey:propertyName];
            }
        }
    }
    @catch (NSException *exception) {
        HTLogHTTPError(@"*** Caught exception setting keys \"%@\" : %@", properties, exception);
    }
}

- (void)save {
    BOOL isRecordExists = [[self class] hasRecordWithRequestKey:_requestKey];
    
    NSString *sqlUpdate = @"";
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_request];
    if (nil == data) {
        return;
    }
    
    NSDictionary *properties = [HTFreezeRequestHelper categoryPropertiesOf:_request];
    NSData *propertyData = [NSKeyedArchiver archivedDataWithRootObject:properties];
    
    if (!isRecordExists) {
        sqlUpdate = [NSString stringWithFormat:@"INSERT INTO %@ (%@, %@, %@, %@, %@, %@) VALUES ('%@', ?, ?, %@, %qi, %qi)", HTFreezeTable, HTFreezeColumnRequestKey, HTFreezeColumnRequest, HTFreezeColumnRequestProperty, HTFreezeColumnVersion, HTFreezeColumnCreateDate, HTFreezeColumnExpireDate, _requestKey, @(_version), (long long)[_createDate timeIntervalSince1970], (long long)[_expireDate timeIntervalSince1970]];
    } else {
        sqlUpdate = [NSString stringWithFormat:@"UPDATE %@ SET %@ = ?, %@ = ?, %@ = %@, %@ = %qi, %@ = %qi WHERE %@ = '%@'", HTFreezeTable, HTFreezeColumnRequest, HTFreezeColumnRequestProperty, HTFreezeColumnVersion, @(_version), HTFreezeColumnCreateDate, (long long)[_createDate timeIntervalSince1970], HTFreezeColumnExpireDate, (long long)[_expireDate timeIntervalSince1970], HTFreezeColumnRequestKey, _requestKey];
    }
    
    [HT_HTTP_FREEZE_DB executeUpdate:sqlUpdate arguments:@[data, propertyData]];
}

+ (BOOL)hasRecordWithRequestKey:(NSString *)requestKey {
    if (0 == [requestKey length]) {
        return NO;
    }
    
    __block BOOL isRecordExists = NO;
    NSString *sql = [NSString stringWithFormat:@"SELECT 1 FROM %@ where %@ = '%@'", HTFreezeTable, HTFreezeColumnRequestKey, requestKey];
    [HT_HTTP_FREEZE_DB executeQuery:sql result:^(FMResultSet *rs, BOOL *end) {
        isRecordExists = (nil != rs);
    }];
    
    return isRecordExists;
}

@end