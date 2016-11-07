//
//  HTHTTPDate.h
//  Pods
//
//  Created by Wangliping on 15/12/1.
//
//

#import <Foundation/Foundation.h>

@protocol HTHTTPDateDelegate <NSObject>

@optional

// 获取当前时间. 外部可以提供一个时间作为当前时间，例如从网络上取一个服务器时间作为当前时间.
- (NSDate *)htGetCurrentTime;

@end

@interface HTHTTPDate : NSObject

+ (instancetype)sharedInstance;

/**
 *  代理. 应用可以自定义当前时间的获取方式，例如从网络上获取时间等等.
 */
@property (nonatomic, weak) id<HTHTTPDateDelegate> delegate;

/**
 *  获取当前时间
 *
 *  @return 获取当前时间
 */
- (NSDate *)now;

@end
