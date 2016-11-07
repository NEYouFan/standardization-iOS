//
//  HTCacheManager.m
//  HTHttp
//
//  Created by NetEase on 15/8/12.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTCacheManager.h"
#import "NSURLRequest+HTCache.h"
#import "FMResultSet.h"
#import "HTHttpLog.h"
#import "HTCacheDBHelper.h"
#import "HTHTTPDate.h"

static dispatch_queue_t cache_manager_io_queue() {
    static dispatch_queue_t ht_cache_manager_io_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ht_cache_manager_io_queue = dispatch_queue_create("ht_cache_manager_io_queue", DISPATCH_QUEUE_SERIAL);
    });
    
    return ht_cache_manager_io_queue;
}

static const NSUInteger HTDefaultDiskCapacity  = 10 * 1024 * 1024;
static const NSUInteger HTDefaultMemCacheCount = 100;
static const NSUInteger HTDefaultMemCacheCost  = 10 * 1024 * 1024;
static const NSUInteger HTDefaultMaxCacheAge = 60 * 60 * 24 * 7; // 1 week

static HTCacheManager *sharedManager = nil;

@interface HTCacheManager ()

// 提供一个内存的Cache. 存的时候，cache和持久化同时存取
// 取的时候，优先从cache中获取；如果是从持久化中获取，那么将结果在 responseCache中放一份.
@property (nonatomic, strong) NSCache *responseCache;
@property (nonatomic, assign, readwrite) NSUInteger diskCacheCapacity;

@end

@implementation HTCacheManager

#pragma mark -

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (nil == sharedManager) {
            // sharedManager直接赋值的情况下，不需要再创建.
            sharedManager = [[HTCacheManager alloc] init];
        }
    });
    
    return sharedManager;
}

+ (void)setSharedManager:(HTCacheManager *)manager {
    // Note: 多个线程同时调用会存在问题. 需要在一开始使用的时候设置.
    sharedManager = manager;
}

- (instancetype)init {
    return [self initWithDiskCapacity:HTDefaultDiskCapacity];
}

- (instancetype)initWithDiskCapacity:(NSUInteger)diskCacheCapacity {
    self = [super init];
    if (self) {
        _responseCache = [[NSCache alloc] init];
        _responseCache.countLimit = HTDefaultMemCacheCount;
        _responseCache.totalCostLimit = HTDefaultMemCacheCost;
        
        _maxCacheAge = HTDefaultMaxCacheAge;
        if (0 != diskCacheCapacity) {
            _diskCacheCapacity = diskCacheCapacity;
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onReceiveMemoryWarning:)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
        
        [self initPersistedCache];
    }
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Public Methods

// 该Request是否存在cache
- (BOOL)hasCacheForRequest:(NSURLRequest *)request {
    return request.ht_isCached || [_responseCache objectForKey:[request ht_cacheKey]] || [self hasPersistCacheForRequest:request];
}

// 取出request对应的Cache.
- (HTCachedResponse*)cachedResponseForRequest:(NSURLRequest *)request {
    HTCachedResponse *cachedResponse = nil;
    NSString *key = [request ht_cacheKey];
    cachedResponse = [_responseCache objectForKey:key];
    if (nil != cachedResponse) {
        return cachedResponse;
    }
    
    cachedResponse = [self responseFromStoreWithRequest:request];
    if (nil != cachedResponse) {
        [_responseCache setObject:cachedResponse forKey:request];
    }
    
    return cachedResponse;
}

// 缓存request的结果.
- (void)storeCachedResponse:(HTCachedResponse *)cachedResponse forRequest:(NSURLRequest *)request {
    NSString *key = [request ht_cacheKey];
    if (0 == [key length] || nil == cachedResponse) {
        return;
    }
    
    if (0 == [cachedResponse.requestKey length]) {
        cachedResponse.requestKey= key;
    }
    
    if (nil == cachedResponse.createDate) {
        cachedResponse.createDate = [[HTHTTPDate sharedInstance] now];
    }
    
    if ([cachedResponse isDateInvalid]) {
        // 已过期, 不存储.
        return;
    }
    
    if (nil == cachedResponse.expireDate) {
        NSTimeInterval expireTimeInterval = [self expireTimeIntervalForRequest:request];
        if (0 != (long)expireTimeInterval) {
            cachedResponse.expireDate = [NSDate dateWithTimeInterval:expireTimeInterval sinceDate:cachedResponse.createDate];
        }
    }
    
    [_responseCache setObject:cachedResponse forKey:key];
    
    request.ht_isCached = YES;
    [self persistStoreResponse:cachedResponse forRequest:request];
}

- (NSTimeInterval)expireTimeIntervalForRequest:(NSURLRequest *)request {
    // request设置了过期时间则更使用request的更新时间.
    NSTimeInterval expireTimeInterval = (0 != (long)request.ht_cacheExpireTimeInterval) ? request.ht_cacheExpireTimeInterval : _defaultExpireTime;
    
    // 超出Cache允许的最长过期时间则使用最长的过期时间.
    return (expireTimeInterval > _maxCacheAge && 0 != _maxCacheAge) ? _maxCacheAge : expireTimeInterval;
}

- (void)removeCachedResponseForRequest:(NSURLRequest *)request completion:(HTCacheCompletionBlock)completion {
    NSString *cacheKey = [request ht_cacheKey];
    if (0 == [cacheKey length]) {
        return;
    }
    
    [_responseCache removeObjectForKey:cacheKey];
    [self removePersistedResponseWithCacheKey:cacheKey completion:completion];
}

- (void)removeAllCachedResponsesOnCompletion:(HTCacheCompletionBlock)completion {
    // 内存中的Cache不需要删除. NSCache类结合了各种自动删除策略，以确保不会占用过多的系统内存.
    // 但当调用者显式要求删除时，仍然删除Cache, 这样用户不会得到Cache的数据.
    [_responseCache removeAllObjects];
    
    dispatch_async(cache_manager_io_queue(), ^{
        [self removeAllPersistedResponses];
        // 删除完成后，到主线程回调. 删除没有进度信息，只有结束信息.
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion();
            });
        }
    });
}

- (void)removeCachedResponsesSinceDate:(NSDate *)date completion:(HTCacheCompletionBlock)completion {
    // memory cache不需要处理.
    
    dispatch_async(cache_manager_io_queue(), ^{
        [self removeAllPersistedResponsesSinceDate:date];
        // 删除完成后，到主线程回调. 删除没有进度信息，只有结束信息.
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion();
            });
        }
    });
}

- (void)removeAllExpiredResponse:(HTCacheCompletionBlock)completion {
    // memory cache不需要处理.
    
    dispatch_async(cache_manager_io_queue(), ^{
        [self removeAllExpiredPersistedResponse];
        // 删除完成后，到主线程回调. 删除没有进度信息，只有结束信息.
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion();
            });
        }
    });
}

- (void)clearMemoryCache {
    [_responseCache removeAllObjects];
}

// 设置某个请求的Cache超时时间.
- (void)setCacheExpireTime:(NSTimeInterval)interval forRequest:(NSURLRequest *)request {
    HTCachedResponse *response = [self cachedResponseForRequest:request];
    if (nil == response) {
        return;
    }
    
    [self storeCachedResponse:response forRequest:request];
}

#pragma mark - Notifications

- (void)onReceiveMemoryWarning:(NSNotification *)notify {
    [self clearMemoryCache];
}

#pragma mark - Cache Size

- (NSUInteger)memoryCacheCapacity {
    return _responseCache.totalCostLimit;
}

- (void)setMemoryCacheCapacity:(NSUInteger)memoryCacheCapacity {
    _responseCache.totalCostLimit = memoryCacheCapacity;
}

- (NSUInteger)memoryCacheCountLimit {
    return _responseCache.countLimit;
}

- (void)setMemoryCacheCountLimit:(NSUInteger)memoryCacheCountLimit {
    _responseCache.countLimit = memoryCacheCountLimit;
}

- (NSUInteger)getCurCacheSize {
    __block NSUInteger curCacheSize = 0;
    dispatch_sync(cache_manager_io_queue(), ^{
        curCacheSize = [self calculateCacheFileSize];
    });

    return curCacheSize;
}

- (void)calculateSizeWithCompletionBlock:(HTCacheSizeCompletionBlock)completion {
    dispatch_async(cache_manager_io_queue(), ^{
        NSUInteger curCacheSize = [self calculateCacheFileSize];
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(curCacheSize);
            });
        }
    });
}

- (NSUInteger)calculateCacheFileSize {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *cacheFile = [HTCacheDBHelper defaultDBFilePath];
    NSDictionary *attrDic = [fileManager attributesOfItemAtPath:cacheFile error:nil];
    NSNumber *fileSize = [attrDic objectForKey:NSFileSize];
    return fileSize.unsignedIntegerValue;
}

#pragma mark - Persist Store

// TODO: 有额外的Model后，这里不宜直接访问数据库表.
- (HTCachedResponse *)responseFromCursor:(FMResultSet *)result {
    HTCachedResponse *response = [[HTCachedResponse alloc] init];
    [response updateFromCursor:result];
    
    return response;
}

- (BOOL)hasPersistCacheForRequest:(NSURLRequest *)request {
    NSString *cacheKey = [request ht_cacheKey];
    
    __block BOOL isRecordExists = NO;
    dispatch_sync(cache_manager_io_queue(), ^{
        isRecordExists = [HTCachedResponse hasRecordWithRequestKey:cacheKey];
    });
    
    return isRecordExists;
}

- (HTCachedResponse *)responseFromStoreWithRequest:(NSURLRequest *)request {
    NSString *cacheKey = [request ht_cacheKey];
    if (0 == [cacheKey length]) {
        return nil;
    }
    
    __block HTCachedResponse *response = nil;
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ where %@ = '%@'", HTCacheTable, HTCacheColumnRequestKey, cacheKey];
    dispatch_sync(cache_manager_io_queue(), ^{
        [HT_HTTP_DB executeQuery:sql result:^(FMResultSet *rs, BOOL *end) {
            response = [self responseFromCursor:rs];
        }];
    });
    
    return response;
}

- (void)persistStoreResponse:(HTCachedResponse *)response forRequest:(NSURLRequest *)request {
    NSString *cacheKey = [request ht_cacheKey];
    if (nil == response || 0 == [cacheKey length]) {
        return;
    }
    
    response.requestKey = cacheKey;
    dispatch_async(cache_manager_io_queue(), ^{
        // 大小控制.
        NSUInteger cacheFileSize = [self calculateCacheFileSize];
        // 如果超出大小，首先执行VACUUM释放数据库文件所占大小空间.
        if (cacheFileSize >= _diskCacheCapacity) {
            [self releaseDiskCacheCapacity];
        }
        
        cacheFileSize = [self calculateCacheFileSize];
        // 如果超出大小，那么先删除过期的缓存.
        if (cacheFileSize >= _diskCacheCapacity) {
            [self removeAllExpiredPersistedResponse];
        }
        
        // 如果过期缓存删除后，缓存仍然超出限定大小，删除所有的缓存.
        cacheFileSize = [self calculateCacheFileSize];
        if (cacheFileSize >= _diskCacheCapacity) {
            [self removeAllPersistedResponses];
        }
        
        [response save];
    });
}

- (void)removePersistedResponseWithCacheKey:(NSString *)cacheKey completion:(HTCacheCompletionBlock)completion {
    if (0 == [cacheKey length]) {
        if (nil != completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion();
            });
        }
        
        return;
    }
    
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ where %@ = '%@'", HTCacheTable, HTCacheColumnRequestKey, cacheKey];
    dispatch_async(cache_manager_io_queue(), ^{
        [HT_HTTP_DB executeUpdate:sql];
        
        if (nil != completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion();
            });
        }
    });
}

- (void)removeAllPersistedResponses {
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@", HTCacheTable];
    [HT_HTTP_DB executeUpdate:sql];
    
    [self releaseDiskCacheCapacity];
}

- (void)removeAllPersistedResponsesSinceDate:(NSDate *)date {
    if (nil == date) {
        return;
    }
    
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ where %@ >= %qi", HTCacheTable, HTCacheColumnCreateDate, (long long)[date timeIntervalSince1970]];
    [HT_HTTP_DB executeUpdate:sql];
}

- (void)removeAllExpiredPersistedResponse {
    NSDate *now = [[HTHTTPDate sharedInstance] now];
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ where %@ < %qi", HTCacheTable, HTCacheColumnExpireDate, (long long)[now timeIntervalSince1970]];
    [HT_HTTP_DB executeUpdate:sql];
    
    [self releaseDiskCacheCapacity];
}

- (void)releaseDiskCacheCapacity {
    HTLogHTTPDebug(@"Release disk cache capacity");
    [HT_HTTP_DB executeUpdate:@"VACUUM"];
}

- (void)initPersistedCache {
    // 避免在主线程调用该方法.
    dispatch_sync(cache_manager_io_queue(), ^{
        [HTCacheDBHelper setupDB];
    });
}

@end
