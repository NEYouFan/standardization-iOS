//
//  HTObserverInformation.h
//  Pods
//
//  Created by Bai_ty on 12/28/15.
//
//

#import <Foundation/Foundation.h>

@interface HTObserverInformation : NSObject

/// 观察者，必须实现 observeValueForKeyPath:ofObject:change:context:
@property (nonatomic, assign) NSObject *observer;
/// 被观察者
@property (nonatomic, assign) NSObject *target;
/// 被观察的属性相对于被观察者的键路径，不能为 nil
@property (nonatomic, copy) NSString *keyPath;
/// @see NSKeyValueObservingOptions
@property (nonatomic, assign) NSKeyValueObservingOptions options;
/// 注册 observer 时传递给 observer 的 observeValueForKeyPath:ofObject:change:context:方法的上下文
@property (nonatomic, assign) void *context;

- (BOOL)isEqualWithoutOptions:(HTObserverInformation *)info;

@end
