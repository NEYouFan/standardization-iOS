//
//  HTDatabaseHelper.m
//  HTHttp
//
//  Created by NetEase on 15/8/17.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "HTDatabaseHelper.h"
#import "HTCommonUtility.h"
#import "FMDatabaseQueue.h"
#import "HTHttpLog.h"

NSString * const HTDatabaseName = @"HTCache.db";

@interface HTDatabaseHelper ()

@property (nonatomic, strong) FMDatabase *usingdb;
@property (nonatomic, copy) NSString *dbname;
@property (nonatomic, strong) NSRecursiveLock* threadLock;

@end

@implementation HTDatabaseHelper

#pragma mark - Life Cycle

+ (instancetype)sharedInstance {
    static HTDatabaseHelper *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[[self class] alloc] init];
    });
    
    return _sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _threadLock = [[NSRecursiveLock alloc]init];
        [self setDBName:[[self class] defaultDBFileName]];
    }
    
    return self;
}

#pragma mark - Setup Database

+ (BOOL)setupDB {
    NSString *cacheFolder = [self cacheFolder];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:cacheFolder]) {
         [fileManager createDirectoryAtPath:cacheFolder withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    
    NSString *dbFilePath = [cacheFolder stringByAppendingPathComponent:[self defaultDBFileName]];
    BOOL isDbExist = [[NSFileManager defaultManager] fileExistsAtPath:dbFilePath];
    
    FMDatabase* db = [[[self class] sharedInstance] getDatabase];
    [db setShouldCacheStatements:NO];
    BOOL isFirstInstall = !isDbExist;
    BOOL bRet = YES;
    if (isFirstInstall) {
        bRet = [self setupDatabase:db];
    } else {
        bRet = [self upgradeDB:db];
    }
    
    [[[self class] sharedInstance] finish];
    
    HTLogHTTPInfo(@"dbfile path is %@", dbFilePath);
    
    if (isFirstInstall && ![self isAllowBackup]) {
        // 缓存数据库不要备份到iCloud.
        [HTCommonUtility addDoNotBackupAttribute:dbFilePath];
    }
    
    return bRet;
}

+ (BOOL)setupDatabase:(FMDatabase*)db {
    if (db == nil)
        return NO;
    
    NSArray *sqls = [self setupSqls];
    [[[self class] sharedInstance] beginTransactionBlockTry:^{
        [self executeSqlGroup:sqls];
    }];
    
    return YES;
}

+ (BOOL)executeSqlGroup:(NSArray*)sqls {
    __block BOOL ret = YES;
    [sqls enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString* sql = obj;
//        sql = [[sql trim] stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
        if ([sql length] > 0 && ![[[self class] sharedInstance] executeUpdate:obj]) {
            *stop = NO;
            ret = NO;
        }
    }];
    
    return ret;
}

+ (BOOL)upgradeDB:(FMDatabase*)db {
    // To support upgrade database in future.
    return YES;
}

+ (NSArray *)setupSqls {
    return [NSMutableArray array];
}

#pragma mark - Database Operation

- (void)setDBName:(NSString *)fileName {
    if ([self.dbname isEqualToString:fileName]) {
        return;
    }
    
    self.dbname = [fileName hasSuffix:@".db"] ? fileName : [NSString stringWithFormat:@"%@.db",fileName];
    [_usingdb close];
    self.usingdb = nil;
    
    NSString *filePath = [[self class] dbFilePath:self.dbname];
    HTLogHTTPInfo(@"database file path : %@", filePath);
    
    _usingdb = [[FMDatabase alloc] initWithPath:filePath];
    [_usingdb open];
}

- (FMDatabase*)getDatabase {
    [self.threadLock lock];
    return self.usingdb;
}

- (void)closeDatabase {
    [self.threadLock lock];
    
    [_usingdb close];
    self.usingdb = nil;
    [self.threadLock unlock];
}

- (void)finish {
    [self.threadLock unlock];
}

#pragma mark - ExecuteSQL

- (void)executeQuery:(NSString*) sql result:(void (^)(FMResultSet* rs, BOOL *end))result {
    if (0 == sql.length) {
        NSAssert(nil, @"sql is invalid !");
        return;
    }
    
    FMDatabase * db	= [self getDatabase];
    FMResultSet *rs	= [db executeQuery:sql];
    @try {
        BOOL end = NO;
        while ([rs next]) {
            result(rs, &end);
            
            if (end) {
                break;
            }
        }
    }
    @finally {
        [rs close];
        [self finish];
    }
}

- (BOOL)executeUpdate:(NSString *) sql {
    if (0 == sql.length) {
        NSAssert(nil, @"sql is invalid !");
        return NO;
    }
    
    FMDatabase * db	= [self getDatabase];
    BOOL ret = NO;
    @try {
        ret = [db executeUpdate:sql];
    }
    @finally {
        [self finish];
    }
    
    return ret;
}

- (BOOL)executeUpdate:(NSString *)sql arguments:(NSArray *)args {
    if (0 == sql.length) {
        NSAssert(nil, @"sql is invalid !");
        return NO;
    }
    
    FMDatabase * db	= [self getDatabase];
    BOOL ret = NO;
    @try {
        ret = [db executeUpdate:sql withArgumentsInArray:args];
    }
    @finally {
        [self finish];
    }
    
    return ret;
}

#pragma mark - Transaction

- (void)beginTransactionBlockTry:(void(^)(void))blockTry {
    [self beginTransactionBlockTry:blockTry blockCatch:nil];
}

- (void)beginTransactionBlockTry:(void(^)(void))blockTry blockCatch:(void(^)(void))blockCatch {
    if (!blockTry) {
        return;
    }
    
    FMDatabase* db = [self getDatabase];
    BOOL isTransaction = ![db inTransaction] && [db beginTransaction];
    @try {
        if(blockTry) {
            blockTry();
        }
        
        if (isTransaction) {
            [db commit];
        }
    }
    @catch (NSException* exception) {
        if (isTransaction) {
            [db rollback];
        }
        
        if (blockCatch) {
            blockCatch();
        }
    }
    @finally {
        [self finish];
    }
}

#pragma mark - Helper Method

+ (NSString *)defaultDBFileName {
    return HTDatabaseName;
}

+ (BOOL)isAllowBackup {
    return NO;
}

+ (BOOL)isDBExist:(NSString *)dbFileName {
    NSString *dbFilePath = [self dbFilePath:dbFileName];
    return [[NSFileManager defaultManager] fileExistsAtPath:dbFilePath];
}

+ (NSString *)cacheFolder {
    NSArray *pathsToLibraryCache = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    if ([pathsToLibraryCache isKindOfClass:[NSArray class]] && [pathsToLibraryCache count] > 0) {
        NSString *cachesDirectory = [pathsToLibraryCache objectAtIndex:0];
        return cachesDirectory;
    }
    
    // 正常情况下不会执行到这里.
    return @"";
}

+ (NSString*)dbFilePath:(NSString*)dbFileName {
    if (0 == dbFileName.length) {
        return @"";
    }
    
    NSString *cacheFolder = [self cacheFolder];
    return [cacheFolder stringByAppendingPathComponent:dbFileName];
}

+ (NSString *)defaultDBFilePath {
    return [self dbFilePath:[self defaultDBFileName]];
}

@end

