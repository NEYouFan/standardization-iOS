//
//  HTR3PathMatcher.h
//  Pods
//
//  Created by zp on 15/10/29.
//
//

#import <Foundation/Foundation.h>

@class HTControllerRouterConfig;

@interface HTR3PathMatcher : NSObject

- (instancetype)initWithControllerRouterConfigs:(NSArray<HTControllerRouterConfig*>*)configs;

- (void)addHTControllerRouterConfig:(HTControllerRouterConfig*)config;

- (HTControllerRouterConfig*)matchURL:(NSString*)url  matchedParams:(NSMutableDictionary*)params;

- (void)compile;
- (void)dump;
@end
