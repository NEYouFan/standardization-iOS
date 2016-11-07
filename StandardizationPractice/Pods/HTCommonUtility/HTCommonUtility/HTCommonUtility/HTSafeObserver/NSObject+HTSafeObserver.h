//
//  NSObject+HTSafeObserver.h
//  Pods
//
//  Created by Bai_ty on 12/28/15.
//
//

#import <Foundation/Foundation.h>

/*!
 是否允许多次为同一个 NSObject 对象注册完全相同的 observer。
 系统是允许多次注册完全相同的 observer；
 如果不希望多次注册完全相同的 observer，可以将该宏设为 0。
 */
#define HT_SAFE_OBSERVER_ALLOW_MULTIPLE_REGISTRATIONS 1

/*!
 该类别提供安全的 KVO 观察者机制，当使用本类别中方法注册 observer 时，无需关心 observer 的删除，
 HTSafeObserver 会在被观察者释放时自动删除已添加的 observer，当然本类提供方法手动释放 observer 方法。
 
 注意一定不能将本类中的方法与系统的注册删除 observer 的方法混合使用。
 此外，注意本类提供的安全 KVO 机制目前尚未支持多线程安全，即观察者和被观察者在不同的线程进行释放。
 */
@interface NSObject (HTSafeObserver)

/*!
 注册 observer 为观察者，当 self 的 keyPath 指定的值变化时接收 KVO 通知。
 
 @param observer 观察者，必须实现 observeValueForKeyPath:ofObject:change:context:
 @param keyPath  被观察的属性相对于被观察者的键路径，不能为 nil
 @param options  @see NSKeyValueObservingOptions
 @param context  注册时传递给 observer 的 observeValueForKeyPath:ofObject:change:context:方法的上下文
 */
- (void)ht_addObserver:(NSObject *)observer
            forKeyPath:(NSString *)keyPath
               options:(NSKeyValueObservingOptions)options
               context:(void *)context;

/*!
 停止 observer 对 self 的 keyPath 属性变化的观察
 
 @param observer 观察者，必须实现 observeValueForKeyPath:ofObject:change:context:
 @param keyPath  被观察的属性相对于被观察者的键路径，不能为 nil
 @param context  注册时传递给 observer 的 observeValueForKeyPath:ofObject:change:context:方法的上下文
 */
- (void)ht_removeObserver:(NSObject *)observer
               forKeyPath:(NSString *)keyPath
                  context:(void *)context;

@end
