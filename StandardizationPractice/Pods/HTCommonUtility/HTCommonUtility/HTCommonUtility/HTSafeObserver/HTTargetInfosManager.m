//
//  HTTargetInfosManager.m
//  Pods
//
//  Created by sky on 12/29/15.
//
//

#import <objc/runtime.h>
#import "HTTargetInfosManager.h"
#import "HTObserverInformation.h"
#import "NSObject+HTSafeObserver.h"
#import "HTObserverInfosManager.h"

@interface HTTargetInfosManager ()

@property (nonatomic, assign) NSObject *observer;
@property (nonatomic, strong) NSMutableArray<HTObserverInformation *> *infos;

@end

extern const char *kObserverInfosManagerKey;

@implementation HTTargetInfosManager

#pragma mark - Life Cycle.

- (instancetype)init {
    if (self = [super init]) {
        _infos = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc {
    for (HTObserverInformation *info in _infos) {
        HTObserverInfosManager *observerInfosManager = objc_getAssociatedObject(info.target, kObserverInfosManagerKey);
        [observerInfosManager removeInformation:info];
    }
    _infos = nil;
    _observer = nil;
}


#pragma mark - Public Methods.

- (BOOL)addInformationWithTarget:(NSObject *)target
                            observer:(NSObject *)observer
                           keyPath:(NSString *)keyPath
                           options:(NSKeyValueObservingOptions)options
                           context:(void *)context {
    if ((_observer && (_observer != observer)) || !observer) {
        NSLog(@"Parameter observer is wrong!");
        return NO;
    }
    
    _observer = observer;
    HTObserverInformation *info = [[HTObserverInformation alloc] init];
    info.observer = observer;
    info.target = target;
    info.keyPath = keyPath;
    info.options = options;
    info.context = context;
    
#if HT_SAFE_OBSERVER_ALLOW_MULTIPLE_REGISTRATIONS
    [_infos addObject:info];
    return YES;
#else
    return [self canAddNewInformation:info];
#endif
}

- (BOOL)removeInformationWithTarget:(NSObject *)target
                           observer:(NSObject *)observer
                              keyPath:(NSString *)keyPath
                              context:(void *)context {
    if (!_observer || (_observer && (_observer != observer)) || !observer) {
        NSLog(@"Parameter observer is wrong!");
        return NO;
    }
    
    HTObserverInformation *info = [[HTObserverInformation alloc] init];
    info.observer = observer;
    info.target = target;
    info.keyPath = keyPath;
    info.options = 0;
    info.context = context;
    
    for (NSInteger i = 0; i < _infos.count; i++) {
        HTObserverInformation *obseleteInfo = _infos[i];
        if ([obseleteInfo isEqualWithoutOptions:info]) {
            [_infos removeObjectAtIndex:i];
            return YES;
        }
    }
    
    NSLog(@"Warning: Observer is not register for the keyPath of target<%lx>", (long)target);
    return NO;
}

- (BOOL)removeInformation:(HTObserverInformation *)info {
    for (NSInteger i = 0; i < _infos.count; i++) {
        HTObserverInformation *obseleteInfo = _infos[i];
        if ([obseleteInfo isEqual:info]) {
            [obseleteInfo.target removeObserver:obseleteInfo.observer
                                     forKeyPath:obseleteInfo.keyPath
                                        context:obseleteInfo.context];
            [_infos removeObjectAtIndex:i];
            return YES;
        }
    }
    
    NSLog(@"Warning: Observer is not register for the keyPath of target<%lx>", (long)info.target);
    return NO;
}


#pragma mark - Private Methods.

/*!
 当不允许重复为被观察者注册完全相同的 observer 时，需调用该方法添加 observer 信息以保证 _infos 中无重复信息
 
 @param info observer 信息
 
 @return YES，如果添加 observer 信息成功；NO，如果已有该 target 信息，则添加 target 信息失败；
 */
- (BOOL)canAddNewInformation:(HTObserverInformation *)newInfo {
    for (HTObserverInformation *info in _infos) {
        if ([newInfo isEqual:info]) {
            NSLog(@"Warning: Already has a same observe Information, you cannot register again");
            return NO;
        }
    }
    [_infos addObject:newInfo];
    return YES;
}

@end
