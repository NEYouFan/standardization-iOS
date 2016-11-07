//
//  HTAssetAsyncImageManager.m
//  Pods
//
//  Created by jw on 5/10/16.
//
//


#import "HTAssetAsyncImageManager.h"

typedef void (^HTAssetImageManagerCacheRequestBlock)(void);

@interface HTAssetAsyncImageManager ()
@property (nonatomic,assign) NSUInteger currentRequestCount;
@property (nonatomic,strong) NSMutableArray<HTAssetImageManagerCacheRequestBlock>* cachedRequest;

@property (nonatomic,assign) PHImageRequestID requestID;

@end


@implementation HTAssetAsyncImageManager

+ (instancetype)sharedInstance
{
    static HTAssetAsyncImageManager* instance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [HTAssetAsyncImageManager new];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _maxConcurrentRequestCount = 10;
        _currentRequestCount = 0;
        _cachedRequest = [NSMutableArray new];
        _requestID = 0;
    }
    return self;
}

- (PHImageRequestID)requestImageForAsset:(PHAsset *)asset targetSize:(CGSize)targetSize contentMode:(PHImageContentMode)contentMode options:(PHImageRequestOptions *)options resultHandler:(void (^)(UIImage * _Nullable, NSDictionary * _Nullable))resultHandler
{
    if (options) {
        NSAssert(options.synchronous == NO, @"HTAssetImageManager does not support synchronious request.");
    }
    __weak HTAssetAsyncImageManager* weakSelf = self;
    PHImageRequestID requestID = _requestID++;
    HTAssetImageManagerCacheRequestBlock b = ^{
        [[HTAssetAsyncImageManager sharedInstance]increaseCount];
        [super requestImageForAsset:asset targetSize:targetSize contentMode:contentMode options:options resultHandler:^void(UIImage * _Nullable image, NSDictionary * _Nullable info){
            
            NSMutableDictionary* newInfo = info ? [info mutableCopy]: @{}.mutableCopy;
            [newInfo setObject:@(requestID) forKey:PHImageResultRequestIDKey];
            resultHandler(image,newInfo);
            
            if (info && [[info valueForKey:PHImageResultIsDegradedKey]boolValue] == NO) {
                [[HTAssetAsyncImageManager sharedInstance]decreaseCount];
                if (weakSelf.cachedRequest.count > 0) {
                    HTAssetImageManagerCacheRequestBlock execBlock = weakSelf.cachedRequest[0];
                    [weakSelf.cachedRequest removeObjectAtIndex:0];
                    execBlock();
                }
            }
        }];
    };

    //缓存请求
    if (_currentRequestCount >= _maxConcurrentRequestCount) {
        [_cachedRequest addObject:b];
//        NSLog(@"%@",@(self.cachedRequest.count));
    }else{
        b();
    }
    
    return requestID;
    
}

- (void)increaseCount
{
    _currentRequestCount++;
}

- (void)decreaseCount
{
    _currentRequestCount--;
}
@end
