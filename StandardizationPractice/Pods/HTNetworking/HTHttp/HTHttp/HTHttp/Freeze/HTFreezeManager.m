//
//  HTFreezeManager.m
//  Pods
//
//  Created by Wangliping on 15/10/29.
//
//

#import "HTFreezeManager.h"
#import "AFNetworkReachabilityManager.h"
#import "RKObjectManager.h"
#import "HTFreezePolicyMananger.h"
#import "NSURLRequest+HTFreeze.h"
#import "HTFreezeDBHelper.h"
#import "HTFrozenRequest.h"
#import "HTHTTPDate.h"
#import "HTHttpLog.h"

NSString * const kHTResendFrozenRequestSuccessfulNotification = @"HTResendFrozenRequestSuccessfulNotification";
NSString * const kHTResendFrozenRequestFailureNotification = @"HTResendFrozenRequestFailureNotification";
NSString * const kHTResendFrozenNotificationOperationItem = @"HTResendFrozenNotificationOperationItem";
NSString * const kHTResendFrozenNotificationResultItem = @"HTResendFrozenNotificationResultItem";
NSString * const kHTResendFrozenNotificationErrorItem = @"HTResendFrozenNotificationErrorItem";

// 最大允许5M的空间来存放Frozen Requests.
NSUInteger const kMaxDataSize = 5 * 1024 * 1024;

// 最大内存中允许10个冻结请求
NSUInteger const kMaxFrozenRequestsInMemory = 10;

// 两次恢复请求的最小间隔时间，避免网络状况不太好时频繁恢复请求.
NSTimeInterval const kMinRestoreInterval = 10;

// Note: Request的版本号. 如果更改过NSURLRequest的Category中的定义导致之前版本的.
NSInteger const kRequestVersion = 0;

// 默认一天过期. 即一天内不会被解冻的请求会被丢弃.
NSTimeInterval const KDefaultExpireInterval = 24 * 60 * 60;

// 一次性最多允许同时恢复6个请求.
NSInteger const kMaxRestoreRequestCount = 6;

static dispatch_queue_t freeze_manager_queue() {
    static dispatch_queue_t freeze_manager_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        freeze_manager_queue = dispatch_queue_create("freeze_manager_queue", DISPATCH_QUEUE_CONCURRENT);
    });
    
    return freeze_manager_queue;
}

static dispatch_queue_t freeze_manager_io_queue() {
    static dispatch_queue_t ht_freeze_manager_io_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ht_freeze_manager_io_queue = dispatch_queue_create("ht_freeze_manager_io_queue", DISPATCH_QUEUE_SERIAL);
    });
    
    return ht_freeze_manager_io_queue;
}

@interface HTFreezeManager ()

// 由于NSCache不支持全部查找，因此使用NSDictionary存储临时要冻结的对象, 并且自己处理线程安全的问题.
@property (nonatomic, strong) NSMutableDictionary *frozenRequestDic;

// 上次恢复请求的时间.
@property (nonatomic, strong) NSDate *lastRestoreTime;

// 一次性最多恢复的请求个数.
@property (nonatomic, assign) NSInteger maxRestoreRequestCount;

@property (nonatomic, assign, readwrite) BOOL isMonitoring;

@end

@implementation HTFreezeManager

#pragma mark - Life Cycle

+ (void)setupWithDelegate:(id<HTFreezeManagerProtocol>)delegate isStartMonitoring:(BOOL)isStartMonitoring {
    [HTFreezeManager sharedInstance].delegate = delegate;
    
    if (isStartMonitoring) {
        [[HTFreezeManager sharedInstance] startMonitoring];
    }
}

+ (instancetype)sharedInstance {
    static HTFreezeManager *manager = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        manager = [[HTFreezeManager alloc] init];
    });
    
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _maxRestoreRequestCount = kMaxRestoreRequestCount;
        _frozenRequestDic = [[NSMutableDictionary alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityDidChanged:) name:AFNetworkingReachabilityDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceiveMemoryWarning:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
        
        [self initPersistedCache];
    }
    
    return self;
}

- (void)startMonitoring {
    // 开始监控网络状态.
    if (!_isMonitoring) {
        _isMonitoring = YES;
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Notifications

- (void)onReceiveMemoryWarning:(NSNotification *)notify {
    [self clearAllFreezedRequestsInMemory];
}

- (void)reachabilityDidChanged:(NSNotification *)notify {
    if (nil == notify) {
        return;
    }
    
    AFNetworkReachabilityStatus status = (AFNetworkReachabilityStatus)[[notify.userInfo objectForKey:AFNetworkingReachabilityNotificationStatusItem] integerValue];
    NSDate *curDate = [[HTHTTPDate sharedInstance] now];
    BOOL canRestoreRequest = (nil == _lastRestoreTime || [curDate timeIntervalSinceDate:_lastRestoreTime] > kMinRestoreInterval);
    switch (status) {
        case AFNetworkReachabilityStatusNotReachable:
            _lastRestoreTime = nil;
            [self checkAndFrozenRequests];
            break;
            
        case AFNetworkReachabilityStatusReachableViaWWAN:
            if (_enableWWANMode && canRestoreRequest) {
                _lastRestoreTime = curDate;
                [self checkAndRestoreFrozenRequests];
            }
            break;
            
        case AFNetworkReachabilityStatusReachableViaWiFi:
            if (canRestoreRequest) {
                _lastRestoreTime = curDate;
                [self checkAndRestoreFrozenRequests];
            }
            break;
            
        default:
            break;
    }
}

#pragma mark -

- (void)freeze:(NSURLRequest *)request {
    dispatch_async(freeze_manager_queue(), ^{
        HTFrozenRequest *htRequest = [self freezeRequestWith:request];
        if (nil == htRequest) {
            return;
        }
        
        @synchronized(self) {
            [_frozenRequestDic setObject:htRequest forKey:request.ht_freezeId];
        }
        
        [self persistStoreRequest:request];
    });
}

- (void)remove:(NSString *)freezeId {
    dispatch_async(freeze_manager_queue(), ^{
        [self doRemove:freezeId];
    });
}

- (HTFrozenRequest *)queryByFreezeId:(NSString *)freezeId {
    HTFrozenRequest *request = nil;
    @synchronized(self) {
        // 从内存中查询.
        request = [_frozenRequestDic objectForKey:freezeId];
    }

    if (nil == request) {
        // 从持久化存储中查询.
        request = [self queryStoreByFreezeId:freezeId];
    }

    return request;
}

- (NSArray *)allFreezedRequests {
    NSMutableArray *array = [NSMutableArray array];
    
    @synchronized(self) {
        NSArray *requestsInMemory = [_frozenRequestDic allValues];
        [array addObjectsFromArray:requestsInMemory];
    }
    
    NSArray *requestsInPersist = [self allFreezedRequestsFromStore];
    for (HTFrozenRequest *htRequest in requestsInPersist) {
        if (![array containsObject:htRequest]) {
            [array addObject:htRequest];
        }
    }
    
    return array;
}

- (void)clearAllFreezedRequests {
    dispatch_async(freeze_manager_io_queue(), ^{
        [self doClearAllFreezedRequestsInMemory];
        [self removeAllPersistedRequests];
    });
}

- (void)clearAllFreezedRequestsOnCompletion:(HTFreezeCompletionBlock)completion {
    dispatch_async(freeze_manager_io_queue(), ^{
        [self doClearAllFreezedRequestsInMemory];
        [self removeAllPersistedRequests];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completion();
        });
    });
}

- (void)clearAllFreezedRequestsInMemory {
    dispatch_async(freeze_manager_queue(), ^{
        [self doClearAllFreezedRequestsInMemory];
    });
}

#pragma mark - Operations Without Thread Control

- (void)checkAndRestoreFrozenRequests {
    dispatch_async(freeze_manager_queue(), ^{
        NSArray *allFreezedRequests = [self allFreezedRequests];
        NSArray *sortedFreezedRequests = [allFreezedRequests sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            if (![obj1 isKindOfClass:[HTFrozenRequest class]] || ![obj2 isKindOfClass:[HTFrozenRequest class]]) {
                return NSOrderedSame;
            }
            
            NSDate *createDate1 = [(HTFrozenRequest *)obj1 createDate];
            NSDate *createDate2 = [(HTFrozenRequest *)obj2 createDate];
            // 按createDate降序排列.
            return [createDate2 compare:createDate1];
        }];
        
        NSInteger restoreCount = 0;
        for (HTFrozenRequest *htRequest in sortedFreezedRequests) {
            if ([htRequest isKindOfClass:[HTFrozenRequest class]]) {
                continue;
            }
            
            if (kRequestVersion != htRequest.version) {
                // 冻结请求功能无需兼容过去的版本.
                [self doRemove:htRequest.requestKey];
                continue;
            }
            
            if (restoreCount > _maxRestoreRequestCount && _maxRestoreRequestCount != 0) {
                [self doRemove:htRequest.requestKey];
                continue;
            }
            
            Class<HTFreezePolicyProtocol> freeze = [[HTFreezePolicyMananger sharedInstance] freezePolicyClassForRequest:htRequest];
            BOOL canSend = [freeze canSend:htRequest];
            BOOL canDelete = [freeze canDelete:htRequest];
            if (canSend) {
                restoreCount ++;
                [self restoreRequest:htRequest.request];
                [self doRemove:htRequest.requestKey];
            } else if (canDelete) {
                [self doRemove:htRequest.requestKey];
            }
        }
        
        // 在还原所有的请求后，检查大小，如果大小超过某个设定值则做一次清理.
        if ([sortedFreezedRequests count] > 0) {
            [self clearDatabaseIfNecessary];
        }
    });
}

// 三个策略：
// 1 HTFreezeManager不主动检测哪些需要被冻结.
// 2 请求被调度前检查网络状况.  (Note: RKObjectManager需要加一个是否检查网络状况的选项以提高性能)
// 3 请求失败后检查是否因为无网络而失败，如果是，那么冻结.
- (void)checkAndFrozenRequests {
    // Note: 根据上面的注释，HTFreezeManager并不主动检测哪些请求需要冻结.
}

- (void)clearDatabaseIfNecessary {
    dispatch_async(freeze_manager_io_queue(), ^{
        NSUInteger cacheFileSize = [self calculateCacheFileSize];
        if (cacheFileSize > kMaxDataSize) {
           [self removeAllPersistedRequests];
        }
    });
}

- (NSUInteger)calculateCacheFileSize {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *cacheFile = [HTFreezeDBHelper defaultDBFilePath];
    NSDictionary *attrDic = [fileManager attributesOfItemAtPath:cacheFile error:nil];
    NSNumber *fileSize = [attrDic objectForKey:NSFileSize];
    return fileSize.unsignedIntegerValue;
}

- (void)doRemove:(NSString *)freezeId {
    if (nil == freezeId) {
        return;
    }
    
    @synchronized(self) {
        [_frozenRequestDic removeObjectForKey:freezeId];
    }
    
    [self removePersistedRequestWithKey:freezeId];
}

- (void)doClearAllFreezedRequestsInMemory {
    @synchronized(self) {
        [_frozenRequestDic removeAllObjects];
    }
}

#pragma mark - Transform Requests

- (HTFrozenRequest *)freezeRequestWith:(NSURLRequest *)request {
    HTFrozenRequest *htRequest = [[HTFrozenRequest alloc] init];
    htRequest.requestKey = request.ht_freezeId;
    htRequest.request = request;
    htRequest.version = kRequestVersion;
    htRequest.createDate = [[HTHTTPDate sharedInstance] now];
    NSTimeInterval expireInterval = request.ht_freezeExpireTimeInterval;
    if (0 == expireInterval) {
        expireInterval = KDefaultExpireInterval;
    }
    htRequest.expireDate = [NSDate dateWithTimeInterval:expireInterval sinceDate:htRequest.createDate];
    
    return htRequest;
}

#pragma mark - Persisted Requests

- (void)initPersistedCache {
    dispatch_sync(freeze_manager_io_queue(), ^{
        [HTFreezeDBHelper setupDB];
    });
}

- (HTFrozenRequest *)htFreezeRequestFromCursor:(FMResultSet *)result {
    HTFrozenRequest *htRequest = [[HTFrozenRequest alloc] init];
    [htRequest updateFromCursor:result];
    
    return htRequest;
}

- (HTFrozenRequest *)queryStoreByFreezeId:(NSString *)freezeId {
    if (0 == [freezeId length]) {
        return nil;
    }
    
    __block HTFrozenRequest *htRequest = nil;
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ where %@ = '%@'", HTFreezeTable, HTFreezeColumnRequestKey, freezeId];
    dispatch_sync(freeze_manager_io_queue(), ^{
        [HT_HTTP_FREEZE_DB executeQuery:sql result:^(FMResultSet *rs, BOOL *end) {
            htRequest = [self htFreezeRequestFromCursor:rs];
        }];
    });
    
    return htRequest;
}

- (void)persistStoreRequest:(NSURLRequest *)request {
    NSString *requestKey = [request ht_freezeId];
    if (0 == [requestKey length]) {
        return;
    }
    
    HTFrozenRequest *htRequest = [self freezeRequestWith:request];
    dispatch_async(freeze_manager_io_queue(), ^{
        // 由于不可能断网期间累积过多被冻结请求，故冻结请求时不考虑存储数据的大小.
        [htRequest save];
    });
}

- (void)removePersistedRequestWithKey:(NSString *)requestKey {
    if (0 == [requestKey length]) {
        return;
    }
    
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ where %@ = '%@'", HTFreezeTable, HTFreezeColumnRequestKey, requestKey];
    dispatch_async(freeze_manager_io_queue(), ^{
        [HT_HTTP_FREEZE_DB executeUpdate:sql];
    });
}

- (void)removeAllPersistedRequests {
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@", HTFreezeTable];
    [HT_HTTP_FREEZE_DB executeUpdate:sql];
    [self releaseDiskCacheCapacity];
}

- (void)releaseDiskCacheCapacity {
    HTLogHTTPDebug(@"ReleaseDiskCacheCapacity for frozen requests");
    [HT_HTTP_FREEZE_DB executeUpdate:@"VACUUM"];
}

- (NSArray *)allFreezedRequestsFromStore {
    NSMutableArray *htRequestList = [NSMutableArray array];
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@", HTFreezeTable];
    dispatch_sync(freeze_manager_io_queue(), ^{
        [HT_HTTP_FREEZE_DB executeQuery:sql result:^(FMResultSet *rs, BOOL *end) {
            HTFrozenRequest *htRequest = [self htFreezeRequestFromCursor:rs];
            if (nil != htRequest) {
                [htRequestList addObject:htRequest];
            }
        }];
    });
    
    return htRequestList;
}

#pragma mark - Helper Methods

- (void)restoreRequest:(NSURLRequest *)request {
    RKObjectManager *mananger = [self correspondingManagerForRequest:request];
    // 无论成功或者失败，都通过通知中心去发送通知.
    RKObjectRequestOperation *operation = [mananger objectRequestOperationWithRequest:request success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        HTLogHTTPDebug(@"Frozen request %@ is restored successfully", request);
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        if (nil != operation) {
            [userInfo setObject:operation forKey:kHTResendFrozenNotificationOperationItem];
        }
        
        if (nil != mappingResult) {
            [userInfo setObject:mappingResult forKey:kHTResendFrozenNotificationResultItem];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kHTResendFrozenRequestSuccessfulNotification object:nil userInfo:userInfo];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        HTLogHTTPDebug(@"Frozen request %@ is failed to restored, error information: %@", request, error);
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        if (nil != operation) {
            [userInfo setObject:operation forKey:kHTResendFrozenNotificationOperationItem];
        }
        
        if (nil != error) {
            [userInfo setObject:error forKey:kHTResendFrozenNotificationErrorItem];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kHTResendFrozenRequestFailureNotification object:nil userInfo:userInfo];
    }];
    
    [mananger enqueueObjectRequestOperation:operation];
}

- (RKObjectManager *)correspondingManagerForRequest:(NSURLRequest *)request {
    RKObjectManager *manager = [_delegate respondsToSelector:@selector(objectManagerForRequest:)] ? [_delegate objectManagerForRequest:request] : nil;
    if (nil == manager) {
        // 如果外部不提供，那么使用默认的RKObjectManager.
        manager = [RKObjectManager sharedManager];
    }
    
    return manager;
}

@end
