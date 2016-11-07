//
//  NSObject+HTSafeObserver.m
//  Pods
//
//  Created by Bai_ty on 12/28/15.
//
//

#import <objc/runtime.h>
#import "NSObject+HTSafeObserver.h"
#import "HTObserverInfosManager.h"
#import "HTTargetInfosManager.h"

const char *kObserverInfosManagerKey = "kObserverInfosManagerKey";
const char *kTargetInfosManagerKey = "kTargetInfosManagerKey";

@implementation NSObject (HTSafeObserver)

- (void)ht_addObserver:(NSObject *)observer
            forKeyPath:(NSString *)keyPath
               options:(NSKeyValueObservingOptions)options
               context:(void *)context {

    if (!observer || !keyPath) {
        NSLog(@"Observer or keyPath can not be nil");
        return;
    }
    
    HTObserverInfosManager *observerInfosManager = objc_getAssociatedObject(self, kObserverInfosManagerKey);
    if (!observerInfosManager) {
        observerInfosManager = [[HTObserverInfosManager alloc] init];
        objc_setAssociatedObject(self, kObserverInfosManagerKey, observerInfosManager, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    HTTargetInfosManager *targetInfosManager = objc_getAssociatedObject(observer, kTargetInfosManagerKey);
    if (!targetInfosManager) {
        targetInfosManager = [[HTTargetInfosManager alloc] init];
        objc_setAssociatedObject(observer, kTargetInfosManagerKey, targetInfosManager, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    if ([observerInfosManager addInformationWithObserver:observer
                                                  target:self
                                                 keyPath:keyPath
                                                 options:options
                                                 context:context] &&
        [targetInfosManager addInformationWithTarget:self
                                            observer:observer
                                             keyPath:keyPath
                                             options:options
                                             context:context]) {
        [self addObserver:observer forKeyPath:keyPath options:options context:context];
    }
}

- (void)ht_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(void *)context {
    HTObserverInfosManager *observerInfosManager = objc_getAssociatedObject(self, kObserverInfosManagerKey);
    HTTargetInfosManager *targetInfosManager = objc_getAssociatedObject(observer, kTargetInfosManagerKey);
    if (!observerInfosManager || !targetInfosManager) {
        return;
    }
    
    if ([observerInfosManager removeInformationWithObserver:observer
                                                     target:self
                                                    keyPath:keyPath
                                                    context:context] &&
        [targetInfosManager removeInformationWithTarget:self
                                               observer:observer
                                                keyPath:keyPath
                                                context:context]) {
        [self removeObserver:observer forKeyPath:keyPath context:context];
    }
}

@end
