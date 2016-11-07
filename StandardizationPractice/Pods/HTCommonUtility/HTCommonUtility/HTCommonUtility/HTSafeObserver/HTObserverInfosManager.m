//
//  HTObserverInfosManager.m
//  Pods
//
//  Created by Bai_ty on 12/28/15.
//
//

#import <objc/runtime.h>
#import "HTObserverInfosManager.h"
#import "HTObserverInformation.h"
#import "NSObject+HTSafeObserver.h"
#import "HTTargetInfosManager.h"

@interface HTObserverInfosManager ()

@property (nonatomic, assign) NSObject *target;
@property (nonatomic, strong) NSMutableArray<HTObserverInformation *> *infos;

@end

extern const char *kTargetInfosManagerKey;

@implementation HTObserverInfosManager

#pragma mark - Life Cycle.

- (instancetype)init {
    if (self = [super init]) {
        _infos = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc {
    for (HTObserverInformation *info in _infos) {
        HTTargetInfosManager *targetInfosManager = objc_getAssociatedObject(info.observer, kTargetInfosManagerKey);
        [targetInfosManager removeInformation:info];
    }
    _infos = nil;
    _target = nil;
}


#pragma mark - Public Methods.

- (BOOL)addInformationWithObserver:(NSObject *)observer
                            target:(NSObject *)target
                           keyPath:(NSString *)keyPath
                           options:(NSKeyValueObservingOptions)options
                           context:(void *)context {
    if ((_target && (_target != target)) || !target) {
        NSLog(@"Parameter target is wrong!");
        return NO;
    }
    
    _target = target;
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

- (BOOL)removeInformationWithObserver:(NSObject *)observer
                               target:(NSObject *)target
                              keyPath:(NSString *)keyPath
                              context:(void *)context {
    if (!_target || (_target && (_target != target)) || !target) {
        NSLog(@"Parameter target is wrong!");
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
 
 @return YES，如果添加 observer 信息成功；NO，如果已有该 observer 信息，则添加 observer 信息失败；
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
