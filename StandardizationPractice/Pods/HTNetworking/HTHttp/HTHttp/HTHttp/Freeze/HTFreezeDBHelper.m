//
//  HTFreezeDBHelper.m
//  Pods
//
//  Created by Wangliping on 15/11/2.
//
//

#import "HTFreezeDBHelper.h"

NSString * const HTHTTPFreezeDBName = @"HTHTTPFreeze.db";
NSString * const HTHTTPFreezeDBFolder = @"HTHTTPFreeze";

@implementation HTFreezeDBHelper

#pragma mark - Life Cycle

+ (instancetype)sharedInstance {
    static HTFreezeDBHelper *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[HTFreezeDBHelper alloc] init];
    });
    
    return _sharedInstance;
}

#pragma mark - Setup Database

+ (NSArray *)setupSqls {
    return @[@"DROP TABLE IF EXISTS TBL_HT_FREEZE_PROFILE",
             @"CREATE TABLE TBL_HT_FREEZE_PROFILE (id INTEGER PRIMARY KEY AUTOINCREMENT, propertyname varchar(40), propertyvalue varchar(300))",
             @"INSERT INTO TBL_HT_FREEZE_PROFILE (propertyname, propertyvalue) SELECT 'db_version', '1010000'",
             @"DROP TABLE IF EXISTS TBL_HT_FREEZE_REQUEST",
             @"CREATE TABLE TBL_HT_FREEZE_REQUEST (id INTEGER PRIMARY KEY AUTOINCREMENT, requestkey varchar(36,0), request blob, property blob, version INTEGER DEFAULT 0, createdate INTEGER DEFAULT 0, expiredate INTEGER DEFAULT 0, UNIQUE(requestkey))"];
}

#pragma mark - Helper Method

+ (NSString *)defaultDBFileName {
    return HTHTTPFreezeDBName;
}

+ (NSString *)cacheFolder {
    NSArray *pathsToLibraryCache = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    if ([pathsToLibraryCache isKindOfClass:[NSArray class]] && [pathsToLibraryCache count] > 0) {
        NSString *cachesDirectory = [pathsToLibraryCache objectAtIndex:0];
        return [cachesDirectory stringByAppendingPathComponent:HTHTTPFreezeDBFolder];
    }
    
    // 正常情况下不会执行到这里.
    return @"";
}

+ (BOOL)isAllowBackup {
    return NO;
}

@end
