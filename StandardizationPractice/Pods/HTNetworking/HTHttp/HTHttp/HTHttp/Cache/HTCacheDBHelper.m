//
//  HTCacheDBHelper.m
//  HTHttp
//
//  Created by Wang Liping on 15/9/2.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "HTCacheDBHelper.h"
#import "FMDatabaseQueue.h"
#import "HTHttpLog.h"

NSString * const HTHTTPCacheDBName = @"HTHTTPCache.db";
NSString * const HTHTTPCacheDBFolder = @"HTHTTPCache";

@implementation HTCacheDBHelper

#pragma mark - Life Cycle

+ (instancetype)sharedInstance {
    static HTCacheDBHelper *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[HTCacheDBHelper alloc] init];
    });
    
    return _sharedInstance;
}

#pragma mark - Setup Database

+ (NSArray *)setupSqls {
    return @[@"DROP TABLE IF EXISTS TBL_HT_CACHE_PROFILE",
             @"CREATE TABLE TBL_HT_CACHE_PROFILE (id INTEGER PRIMARY KEY AUTOINCREMENT, propertyname varchar(40), propertyvalue varchar(300))",
             @"INSERT INTO TBL_HT_CACHE_PROFILE (propertyname, propertyvalue) SELECT 'db_version', '1010000'",
             @"DROP TABLE IF EXISTS TBL_HT_CACHE_RESPONSE",
             @"CREATE TABLE TBL_HT_CACHE_RESPONSE (id INTEGER PRIMARY KEY AUTOINCREMENT, requestkey varchar(36,0), response blob, version INTEGER DEFAULT 0, createdate INTEGER DEFAULT 0, expiredate INTEGER DEFAULT 0, UNIQUE(requestkey))"];
}

#pragma mark - Helper Method

+ (NSString *)defaultDBFileName {
    return HTHTTPCacheDBName;
}

+ (NSString *)cacheFolder {
    NSArray *pathsToLibraryCache = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    if ([pathsToLibraryCache isKindOfClass:[NSArray class]] && [pathsToLibraryCache count] > 0) {
        NSString *cachesDirectory = [pathsToLibraryCache objectAtIndex:0];
        return [cachesDirectory stringByAppendingPathComponent:HTHTTPCacheDBFolder];
    }
    
    // 正常情况下不会执行到这里.
    return @"";
}

+ (BOOL)isAllowBackup {
    return NO;
}

@end
