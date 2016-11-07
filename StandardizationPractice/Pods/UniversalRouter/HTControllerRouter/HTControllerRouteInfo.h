//
//  HTControllerRouteInfo.h
//  HTUIDemo
//
//  Created by zp on 15/8/28.
//  Copyright (c) 2015年 HT. All rights reserved.
//

#import <UIKit/UIKit.h>

#warning zhushi
//如何加载vc
typedef NS_ENUM(NSInteger, HTControllerLaunchMode){
    HTControllerLaunchModeDefault,
    HTControllerLaunchModeNOAction,
    HTControllerLaunchModePush,
    HTControllerLaunchModePresent,
    HTControllerLaunchModePushNavigation,
    HTControllerLaunchModePresentNavigation,
};

//vc的实例如何构造
typedef NS_ENUM(NSInteger, HTControllerInstanceMode){
    HTControllerInstanceModeDefault,
    HTControllerInstanceModeNormal,
    HTControllerInstanceModeWrapContainer,
    HTControllerInstanceModeSingleInstance,
    HTControllerInstanceModeSingleTask, //当present vc tree上存在一个实例时，使用这个实例
};

//单实例vc如何显示
typedef NS_ENUM(NSInteger, HTControllerInstanceShowMode){
    HTControllerInstanceShowModeDefault,
    HTControllerInstanceShowModeNOAction,
    HTControllerInstanceShowModeMoveToTop,
    HTControllerInstanceShowModeClearToTop,
};

NSString *HTControllerLaunchModeToString(HTControllerLaunchMode mode);
NSString *HTControllerInstanceModeToString(HTControllerInstanceMode mode);
NSString *HTControllerInstanceShowModeToString(HTControllerInstanceShowMode mode);

#define HT_EXPORT() __attribute__((used, section("__DATA,HTExport" \
))) static const char *__ht_export_entry__[] = { __func__}

@interface HTControllerRouterConfig : NSObject

- (instancetype)initWithUrlPath:(NSString*)url;
- (instancetype)initWithControllerClass:(Class)viewControllerClass;

@property (nonatomic, assign) HTControllerLaunchMode launchMode;
@property (nonatomic, assign) HTControllerInstanceMode instanceMode;
@property (nonatomic, assign) HTControllerInstanceShowMode singleInstanceShowMode;
@property (nonatomic, strong) Protocol *delegateProtocol;

@property (nonatomic, strong) Class viewControllerClass;

- (void)addUrlPath:(NSString*)url;

- (NSArray*)urlMatchers;

- (NSArray*)urls;
@end

@interface HTControllerRouteParam : NSObject
@property (nonatomic, strong) UIViewController *fromViewController;
@property (nonatomic, strong) Class controllerClass;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, strong) NSDictionary *urlParams;
@property (nonatomic, strong) id params;
@property (nonatomic, strong) id delegate;
@property (nonatomic, assign) HTControllerLaunchMode launchMode;
@property (nonatomic, assign) HTControllerInstanceMode instanceMode;
@property (nonatomic, assign) HTControllerInstanceShowMode singleInstanceShowMode;
@property (nonatomic, assign) BOOL bAnimate;

- (instancetype)initWithURL:(NSString*)url launchMode:(HTControllerLaunchMode)launchMode;

@end
