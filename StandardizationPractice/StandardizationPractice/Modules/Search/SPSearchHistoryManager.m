//
//  SPSearchHistoryManager.m
//  StandardizationPractice
//
//  Created by 陶泽宇 on 2016/10/25.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import "SPSearchHistoryManager.h"
#import "SPDataBaseHelper.h"

static dispatch_queue_t cache_manager_io_queue() {
    static dispatch_queue_t ht_cache_manager_io_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ht_cache_manager_io_queue = dispatch_queue_create("sp_database_manager_io_queue", DISPATCH_QUEUE_SERIAL);
    });
    
    return ht_cache_manager_io_queue;
}

@implementation SPSearchHistoryManager

+ (instancetype)sharedManager {
    static SPSearchHistoryManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (nil == sharedManager) {
            // sharedManager直接赋值的情况下，不需要再创建.
            sharedManager = [[SPSearchHistoryManager alloc] init];
        }
    });
    
    return sharedManager;
}


- (instancetype)init{
    if (self = [super init]) {
        // 避免在主线程调用该方法.
        dispatch_sync(cache_manager_io_queue(), ^{
            [SPDataBaseHelper setupDB];
        });
    }
    return self;
}


# pragma mark  DATABASE INSERT DELETE SELECT

- (void)addHistory:(NSString *)history{
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO TBL_SP_CACHE_PROFILE (location) VALUES ('%@')",history];
    dispatch_sync(cache_manager_io_queue(), ^{
        [[SPDataBaseHelper sharedInstance] executeQuery:sql result:^(FMResultSet *rs, BOOL *end) {
            ;
        }];
    });
}

- (NSArray *)loadHistory:(void(^)(NSArray *result))block{
    NSString *sql = [NSString stringWithFormat:@"SELECT DISTINCT location FROM TBL_SP_CACHE_PROFILE"];
    dispatch_sync(cache_manager_io_queue(), ^{
        __block NSMutableArray *dataArray = [NSMutableArray arrayWithCapacity:5];
        [[SPDataBaseHelper sharedInstance] executeQuery:sql result:^(FMResultSet *rs, BOOL *end) {
            if (*end == YES) {
                if (block) {
                    block(dataArray);
                }
                return;
            }
            [dataArray addObject:[rs stringForColumn:@"location"]];
        }];
    });
    
    return nil;
}

- (NSArray *)selectFromHistory:(NSString *)keyWord completion:(void(^)(NSArray *result))block{
    NSString *sql = [NSString stringWithFormat:@"SELECT DISTINCT location FROM TBL_SP_CACHE_PROFILE WHERE location LIKE '%%%@%%'",keyWord];
    dispatch_sync(cache_manager_io_queue(), ^{
        __block NSMutableArray *dataArray = [NSMutableArray arrayWithCapacity:5];
        [[SPDataBaseHelper sharedInstance] executeQuery:sql result:^(FMResultSet *rs, BOOL *end) {
            if (*end == YES) {
                if (block) {
                    block(dataArray);
                }
                return;
            }
            [dataArray addObject:[rs stringForColumn:@"location"]];
        }];
    });

    return nil;
}

- (void)removeAllHistory {
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM TBL_SP_CACHE_PROFILE"];
    [[SPDataBaseHelper sharedInstance] executeUpdate:sql];
    [self releaseDiskCacheCapacity];
}

- (void)releaseDiskCacheCapacity {
    [[SPDataBaseHelper sharedInstance] executeUpdate:@"VACUUM"];
}
@end
