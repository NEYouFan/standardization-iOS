//
//  HTControllerRouteInfo.m
//  HTUIDemo
//
//  Created by zp on 15/8/28.
//  Copyright (c) 2015年 HT. All rights reserved.
//

#import "HTControllerRouteInfo.h"
#import "HTControllerRouter.h"

NSString *HTControllerLaunchModeToString(HTControllerLaunchMode mode)
{
    switch (mode) {
        case HTControllerLaunchModeDefault:
            return @"HTControllerLaunchModeDefault";
            
        case HTControllerLaunchModeNOAction:
            return @"HTControllerLaunchModeNOAction";
        
        case HTControllerLaunchModePush:
            return @"HTControllerLaunchModePush";
            
        case HTControllerLaunchModePresent:
            return @"HTControllerLaunchModePresent";
            
        case HTControllerLaunchModePushNavigation:
            return @"HTControllerLaunchModePushNavigation";
            
        case HTControllerLaunchModePresentNavigation:
            return @"HTControllerLaunchModePresentNavigation";
            
        default:
            break;
    }
}

NSString *HTControllerInstanceModeToString(HTControllerInstanceMode mode)
{
    switch (mode) {
        case HTControllerInstanceModeDefault:
            return @"HTControllerInstanceModeDefault";
            
        case HTControllerInstanceModeNormal:
            return @"HTControllerInstanceModeNormal";
            
        case HTControllerInstanceModeSingleInstance:
            return @"HTControllerInstanceModeSingleInstance";
            
        case HTControllerInstanceModeWrapContainer:
            return @"HTControllerInstanceModeWrapContainer";
            
        case HTControllerInstanceModeSingleTask:
            return @"HTControllerInstanceModeSingleTask";
        default:
            break;
    }
}

NSString *HTControllerInstanceShowModeToString(HTControllerInstanceShowMode mode)
{
    switch (mode) {
            
        case HTControllerInstanceShowModeDefault:
            return @"HTControllerInstanceShowModeDefault";
        
        case HTControllerInstanceShowModeNOAction:
            return @"HTControllerInstanceShowModeNOAction";
            
        case HTControllerInstanceShowModeMoveToTop:
            return @"HTControllerInstanceShowModeMoveToTop";
            
        case HTControllerInstanceShowModeClearToTop:
            return @"HTControllerInstanceShowModeClearToTop";
            
        default:
            break;
    }
}


@interface HTControllerRouterConfig()
@property (nonatomic, strong) NSMutableArray *urlMatchers;

@property (nonatomic, strong) NSMutableArray *urls;
@end

@implementation HTControllerRouterConfig

- (instancetype)initWithUrlPath:(NSString*)url
{
    self = [super init];
    if (self) {
        _urlMatchers = [NSMutableArray new];
        _urls = [NSMutableArray new];
        _launchMode = HTControllerLaunchModePush;
        _instanceMode = HTControllerInstanceModeNormal;
        _singleInstanceShowMode = HTControllerInstanceShowModeNOAction;
        
        if (url){
            [self addUrlPath:url];
        }
    }
    
    return self;
}

- (instancetype)initWithControllerClass:(Class)viewControllerClass
{
    self = [self initWithUrlPath:NSStringFromClass(viewControllerClass)];
    if (self){
        _viewControllerClass = viewControllerClass;
    }
    
    return self;
}

- (void)addUrlPath:(NSString*)url
{
    [_urls addObject:url];
}

- (NSArray*)urls
{
    return _urls;
}

@end

@implementation HTControllerRouteParam

- (instancetype)init
{
    self = [super init];
    if (self){
        [self doInit];
    }
    
    return self;
}

- (instancetype)initWithURL:(NSString*)url launchMode:(HTControllerLaunchMode)launchMode
{
    self = [super init];
    if (self){
        [self doInit];
        _url = url;
        _launchMode = launchMode;
    }
    
    return self;
}

- (void)doInit
{
    _launchMode = HTControllerLaunchModeDefault;
    _singleInstanceShowMode = HTControllerInstanceShowModeDefault;
    _bAnimate = YES;
}

- (id)copy
{
    HTControllerRouteParam *param = [HTControllerRouteParam new];
    param.fromViewController = self.fromViewController;
    param.controllerClass = self.controllerClass;
    param.url = self.url;
    param.urlParams = self.urlParams;
    param.params = self.params;
    param.delegate = self.delegate;
    param.launchMode = self.launchMode;
    param.instanceMode = self.instanceMode;
    param.singleInstanceShowMode = self.singleInstanceShowMode;
    param.bAnimate = self.bAnimate;
    
    return param;
}

- (NSString *)description
{
    NSMutableString *desc = [[NSMutableString alloc] initWithString:NSStringFromClass(self.class)];

    if (_url)
        [desc appendFormat:@" url:%@", _url];
    else if (_controllerClass)
        [desc appendFormat:@" url:%@", _controllerClass];
    
    if (_params){
        [desc appendFormat:@" param:%@", _params];
    }
    
    if (_fromViewController){
        [desc appendFormat:@" from controller:%@", _fromViewController];
    }
    
    [desc appendFormat:@" launchMode:%@", HTControllerLaunchModeToString(self.launchMode)];
    [desc appendFormat:@" singleInstanceShowMode:%@", HTControllerInstanceShowModeToString(self.singleInstanceShowMode)];
    [desc appendFormat:@" instanceMode:%@", HTControllerInstanceModeToString(self.instanceMode)];
    
    return desc;
}

@end
