//
//  HTControllerRouter.m
//  HTUIDemo
//
//  Created by zp on 15/8/28.
//  Copyright (c) 2015年 HT. All rights reserved.
//

#import "HTControllerRouter.h"
#import "HTRouterCollection.h"
#import "HTControllerRouteInfo.h"
#import "UIViewController+HTRouterUtils.h"
#import "HTContainerViewController.h"
#import "UIViewController+HTUtils.h"
#import "HTNavigationController.h"
#import "HTControllerRouterLogger.h"
#import "HTR3PathMatcher.h"

///Todo:clear to top的支持
///Todo:router需要分级，根据优先级来决定谁先route，谁后route
///Todo:性能测试，加入有1000个需要pattern match的url
///Todo:跟webview，AppDelegate结合起来

@interface HTControllerRouter()

@property (nonatomic, strong) NSMutableArray *routeControllerClasses;

//HTControllerRouteConfigs
@property (nonatomic, strong) NSMutableDictionary *routeControllerInfos;

@property (nonatomic, strong) Class navigationDelegateClass;

@property (nonatomic, strong) HTR3PathMatcher *r3URLMatcher;

@end

@implementation HTControllerRouter

+ (instancetype)sharedRouter
{
    static HTControllerRouter *router;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        router = [[HTControllerRouter alloc] init];
    });
    
    return router;
}

- (instancetype)init
{
    self = [super init];
    if (self){
        [self loadAllRouterInfos];
    }
    
    return self;
}

- (void)loadAllRouterInfos
{
    _routeControllerInfos = [NSMutableDictionary new];
    
    NSArray *classes = HTExportedMethodsByModuleID();
    if (classes)
        _routeControllerClasses = [NSMutableArray arrayWithArray:classes];
    else
        _routeControllerClasses = [NSMutableArray new];
    
    _r3URLMatcher = [HTR3PathMatcher new];
    
    for (Class cls in _routeControllerClasses) {
        NSAssert([cls conformsToProtocol:@protocol(HTRouteTargetProtocol)], @"HTRouterConfig class:%@ not conform to protocol:%@", cls, @protocol(HTRouteTargetProtocol));
        
        HTControllerRouterConfig *config = (HTControllerRouterConfig*)[cls configureRouter];
        NSAssert([config isMemberOfClass:HTControllerRouterConfig.class], @"HTRouterConfig type error");
        
        config.viewControllerClass = cls;
        [_routeControllerInfos setObject:config forKey:NSStringFromClass(cls)];

        [_r3URLMatcher addHTControllerRouterConfig:config];
    }

    [_r3URLMatcher compile];
}

- (void)dumpRouter
{
    [_r3URLMatcher dump];
}

- (void)registeNavigationDelegateClass:(Class)cls
{
    NSAssert1(cls == nil || [cls conformsToProtocol:@protocol(HTNavigationDelegateInitProtocol)], @"%@ Cann't conform protocol HTNavigationDelegateInitProtocol:", cls);
    
    _navigationDelegateClass = cls;
}

//router interface
- (UIViewController*)findControllerWithURL:(NSString*)url
{
    HTControllerRouteParam * param =
    [[HTControllerRouteParam alloc] initWithURL:url launchMode:HTControllerLaunchModeDefault];
    return [self routeControllerWithParam:param
                                 outParam:nil
                                  handler:nil];
}

//user use
- (UIViewController*)route:(HTControllerRouteParam*)param
{
    return [self route:param handler:nil];
}

//user use
- (UIViewController*)route:(HTControllerRouteParam*)param
                   handler:(HTRouterViewControllerSetUpBlock)handler
{
    HTControllerRouteParam * foundParam;
    UIViewController * foundVC = [self routeControllerWithParam:param
                                                       outParam:&foundParam
                                                        handler:handler];
    return [self showController:foundVC param:foundParam];
}

- (UIViewController*)routeControllerWithParam:(HTControllerRouteParam*)param
                                     outParam:(HTControllerRouteParam**)outParam
                                      handler:(HTRouterViewControllerSetUpBlock)handler
{
    NSAssert(param.url.length > 0 || param.controllerClass, @"route url param error");
#warning assert需要处理一下，路口处
    HTControllerRouterConfig *foundRouterConfig;
    NSDictionary *urlParams;
    
    if (param.controllerClass){
        foundRouterConfig = [_routeControllerInfos objectForKey:NSStringFromClass(param.controllerClass)];
        if (!foundRouterConfig){
            foundRouterConfig = [[HTControllerRouterConfig alloc] initWithControllerClass:param.controllerClass];
            [_routeControllerInfos setObject:foundRouterConfig forKey:NSStringFromClass(param.controllerClass)];
        }
    }
    
    NSTimeInterval starTime = CACurrentMediaTime();
    if (param.url){
        NSMutableDictionary *params = [NSMutableDictionary new];
        foundRouterConfig = [_r3URLMatcher matchURL:param.url matchedParams:params];
        if (params.count > 0)
            urlParams = params;
    }
    HTControllerRouterLogVerbose(@"route url spend:%f", CACurrentMediaTime() - starTime);
    
    if (foundRouterConfig == nil) {
        HTControllerRouterLogWarn(@"Cannot find route config to param:%@", param);
        if (handler) {
            handler(nil, nil, nil);
        }
        if (outParam!=NULL) {
            *outParam = NULL;
        }
        return nil;
    }
    
    HTControllerRouteParam *routeParam = [param copy];
    routeParam.urlParams = urlParams;
    
    NSAssert(!param.delegate || !foundRouterConfig.delegateProtocol ||
             [param.delegate conformsToProtocol:foundRouterConfig.delegateProtocol],
             @"HTControllerRouteParam delegate :%@ must conform to protocol:%@", param.delegate, foundRouterConfig.delegateProtocol);
    HTControllerLaunchMode launchMode = param.launchMode == HTControllerLaunchModeDefault ? foundRouterConfig.launchMode : param.launchMode;
    HTControllerInstanceShowMode singleInstanceShowMode = param.singleInstanceShowMode == HTControllerInstanceShowModeDefault ? foundRouterConfig.singleInstanceShowMode : param.singleInstanceShowMode;
    HTControllerInstanceMode instanceMode = param.instanceMode != HTControllerInstanceModeDefault ? param.instanceMode : foundRouterConfig.instanceMode;
    
    routeParam.launchMode = launchMode;
    routeParam.singleInstanceShowMode = singleInstanceShowMode;
    routeParam.instanceMode = instanceMode;
    
    if (outParam!=NULL) {
        *outParam = routeParam;
    }
    return [self controllerInstanceWithConfig:foundRouterConfig
                                        param:routeParam
                                      handler:handler];
}

- (UIViewController *)showController:(UIViewController*)vc param:(HTControllerRouteParam *)param
{
    if (!vc){
        HTControllerRouterLogWarn(@"Cannot find route config to param:%@", param);
        return nil;
    }
    HTControllerRouterLogDebug(@"route:%@", param);
    
    if (param.delegate && [vc respondsToSelector:@selector(setRouterDelegate:)]){
        [(id<HTRouteTargetProtocol>)vc setRouterDelegate:param.delegate];
    }
    
    [self launchController:vc param:param];
    
    if ([vc respondsToSelector:@selector(receiveRoute:)]){
        [(id<HTRouteTargetProtocol>)vc receiveRoute:param];
    }
    
    //显示类似tab controller的页面，通知所有子页面
    for (UIViewController * childController in vc.childViewControllers) {
        if ([childController isKindOfClass:[UINavigationController class]]) {
            //显示navigation controller时最多有一个页面
            UIViewController * innerController = [(UINavigationController*)childController viewControllers].firstObject;
            if ([innerController respondsToSelector:@selector(receiveRoute:)]){
                [(id<HTRouteTargetProtocol>)innerController receiveRoute:param];
            }
        }
    }

    return vc;
}

#pragma mark - 获取vc实例
- (UIViewController*)controllerInstanceWithConfig:(HTControllerRouterConfig*)config
                                            param:(HTControllerRouteParam*)param
                                          handler:(HTRouterViewControllerSetUpBlock)handler
{
    HTControllerInstanceMode instanceMode = param.instanceMode;
    Class viewClass = config.viewControllerClass;
    if (instanceMode == HTControllerInstanceModeNormal){
        if (handler) {
            return handler(viewClass, nil, param);
        } else {
            return [config.viewControllerClass new];
        }
    }
    else if (instanceMode == HTControllerInstanceModeWrapContainer){
        UIViewController *vc;
        if (handler) {
            vc = handler(viewClass, nil, param);
        } else {
            vc = [config.viewControllerClass new];
        }
        HTContainerViewController *container = [[HTContainerViewController alloc] initWithRootViewController:vc navigationDelegateClass:_navigationDelegateClass];
        return container;
    }
    else if (instanceMode == HTControllerInstanceModeSingleInstance){
        UIViewController *instance = [config.viewControllerClass ht_getSingleInstance];
        if (instance == nil) {
            instance = [config.viewControllerClass new];
            [config.viewControllerClass ht_setSingleInstance:instance];
        }
        
        if (handler) {
            return handler(viewClass, instance, param);
        } else {
            return instance;
        }
    }
    else if (instanceMode == HTControllerInstanceModeSingleTask){
        Class vcClass = config.viewControllerClass;
        NSAssert(vcClass, @"Single task need set controllerClass at HTControllerRouteParam");
        UIViewController *instance = [vcClass ht_findInstanceInPresentedControllerTree];
        if (instance == nil) {
            instance = [vcClass new];
        }
        if (handler) {
            return handler(viewClass, instance, param);
        } else {
            return instance;
        }
    }
    else if (instanceMode == HTControllerInstanceModeSingleTask){
        Class vcClass = config.viewControllerClass;
        NSAssert(vcClass, @"Single task need set controllerClass at HTControllerRouteParam");
        UIViewController *instance = [vcClass ht_findInstanceInPresentedControllerTree];
        if (instance == nil) {
            instance = [vcClass new];
        }
        return instance;
    }
    else{
        NSAssert(NO, @"HTControllerRouterConfig instance mode error");
    }
    
    if (handler) {
        handler(nil, nil, nil);
    }
    return nil;
}

#pragma mark - launch instance
- (void)launchController:(UIViewController*)viewController param:(HTControllerRouteParam*)param
{
    HTControllerInstanceMode instanceMode = param.instanceMode;
    BOOL bNormalLaunch = YES;
    if (instanceMode == HTControllerInstanceModeSingleInstance){
        //单实例对象，如果不在vc tree中，还是当做普通vc进行launch
        if (viewController.parentViewController != nil){
            bNormalLaunch = NO;
        }
    }
    
    if (instanceMode == HTControllerInstanceModeSingleTask) {
        if (viewController.presentingViewController
            || viewController.parentViewController
            || viewController.navigationController)
        {
            [self moveControllerToTop:viewController param:param];
        }
        else
        {
            [self launchNormalController:viewController param:param];
        }
    }
    else if (bNormalLaunch){
        if (param.launchMode != HTControllerLaunchModeDefault &&
            param.launchMode != HTControllerLaunchModeNOAction){
            [self launchNormalController:viewController param:param];
        }
        else{
            HTControllerRouterLogWarn(@"do not need do normal launch");
        }
    }
    else{
        if (param.singleInstanceShowMode == HTControllerInstanceShowModeMoveToTop ||
            param.singleInstanceShowMode == HTControllerInstanceShowModeClearToTop)
            [self launchSingleInstanceController:viewController param:param];
        else{
            HTControllerRouterLogWarn(@"do not need do single instance launch");
        }
    }
}

- (void)launchNormalController:(UIViewController*)viewController param:(HTControllerRouteParam*)param
{
    NSAssert(param.launchMode == HTControllerLaunchModePush ||
             param.launchMode == HTControllerLaunchModePresent ||
             param.launchMode == HTControllerLaunchModePushNavigation ||
             param.launchMode == HTControllerLaunchModePresentNavigation, @"Params Error");
    
    UIViewController *fromViewController = param.fromViewController;
    
    switch (param.launchMode) {
        case HTControllerLaunchModePush:
            HTControllerRouterLogDebug(@"launch normal push");
            
            if (!fromViewController){
                UIViewController *topmostViewController = [UIViewController ht_topMostController];
                fromViewController = [topmostViewController ht_innerMostNavigationController];
                if (!fromViewController){
                    HTControllerRouterLogWarn(@"cannot auto find from view controller");
                    return;
                }
            }
            
            if ([fromViewController isKindOfClass:UINavigationController.class]){
                [(UINavigationController*)fromViewController pushViewController:viewController animated:param.bAnimate];
            }
            else{
                [fromViewController.navigationController pushViewController:viewController animated:param.bAnimate];
            }
            break;
            
        case HTControllerLaunchModePresent:
            HTControllerRouterLogDebug(@"launch normal present");
            
            if (!fromViewController){
                fromViewController = [UIViewController ht_topMostController];
            }
            
            [fromViewController presentViewController:viewController animated:param.bAnimate completion:^{
            }];
            break;
            
        case HTControllerLaunchModePushNavigation:
            HTControllerRouterLogDebug(@"launch push navigation");
            
            [self pushNavigationWrappedController:viewController param:param];
            break;
            
        case HTControllerLaunchModePresentNavigation:
            HTControllerRouterLogDebug(@"launch present navigation");
            
            [self presentNavigationWrappedController:viewController param:param];
            break;
            
        default:
            break;
    }
}

- (void)pushNavigationWrappedController:(UIViewController*)viewController param:(HTControllerRouteParam*)param
{
    UIViewController *fromViewController = param.fromViewController;
    if (!fromViewController){
        UIViewController *topmostViewController = [UIViewController ht_topMostController];
        fromViewController = [topmostViewController ht_innerMostNavigationControllerWithNavigationBarHidden:YES];
        if (!fromViewController){
            HTControllerRouterLogWarn(@"cannot auto find from view controller");
            return;
        }
    }
    
    HTContainerViewController *container = [[HTContainerViewController alloc] initWithRootViewController:viewController navigationDelegateClass:_navigationDelegateClass];
    if ([fromViewController isKindOfClass:UINavigationController.class]){
        UINavigationController *navigationController = (UINavigationController*)fromViewController;
        [navigationController pushViewController:container animated:param.bAnimate];
    }
    else{
        [fromViewController.navigationController pushViewController:container animated:param.bAnimate];
    }
}

- (void)presentNavigationWrappedController:(UIViewController*)viewController param:(HTControllerRouteParam*)param
{
    UIViewController *fromViewController = param.fromViewController;
    if (!fromViewController){
        fromViewController = [UIViewController ht_topMostController];
    }
    HTContainerViewController *container = [[HTContainerViewController alloc] initWithRootViewController:viewController navigationDelegateClass:_navigationDelegateClass];
    HTNavigationController *rootNavigationController = [[HTNavigationController alloc] initWithRootViewController:container delegateClass:_navigationDelegateClass];
    
    [rootNavigationController setNavigationBarHidden:YES animated:NO];
    [fromViewController presentViewController:rootNavigationController animated:param.bAnimate completion:^{
        
    }];
    
}

- (void)launchSingleInstanceController:(UIViewController*)viewController param:(HTControllerRouteParam*)param
{
    //只处理单实例对象，且该单实例对象已经在vc的tree中了
    NSAssert(viewController.parentViewController, @"launchSingleInstanceController viewcontroller should launch with normal mode");
    NSAssert(param.singleInstanceShowMode == HTControllerInstanceShowModeMoveToTop ||
             param.singleInstanceShowMode == HTControllerInstanceShowModeClearToTop, @"launchSingleInstanceController param singleInstanceShowMode error");
    
    if (param.singleInstanceShowMode == HTControllerInstanceShowModeMoveToTop){
        HTControllerRouterLogDebug(@"launch single instance move to top");
        
        [self moveControllerToTop:viewController param:param];
    }
    else if (param.singleInstanceShowMode == HTControllerInstanceShowModeClearToTop){
        HTControllerRouterLogDebug(@"launch single instance clear to visible");
        
        [viewController ht_clearToTop:param.bAnimate];
    }
    else{
        NSAssert(NO, @"launchSingleInstanceController no action");
    }
}

- (void)moveControllerToTop:(UIViewController*)viewController param:(HTControllerRouteParam*)param
{
    if ([viewController ht_isInControllerTreeVisiblePath]){
        HTControllerRouterLogDebug(@"single instance is at visible path,do not need move to top");
        return;
    }
    
    [viewController ht_removeFromControllerTree:^(BOOL bRemoved) {
        if (!bRemoved){
            HTControllerRouterLogDebug(@"single instance canot remove from controller tree");
            return;
        }
        
        if (viewController.parentViewController){
            if ([viewController conformsToProtocol:@protocol(HTContainerViewControllerProtocol)] && [(id<HTContainerViewControllerProtocol>)viewController containerController]){
                [viewController ht_removeFromNavigationController];
                HTControllerRouterLogDebug(@"single instance after remove from controller tree, call normal launch");
                [self launchNormalController:viewController param:param];
            }
            else{
                NSAssert(NO, @"");
            }
        }
        else{
            HTControllerRouterLogDebug(@"single instance after remove from controller tree, call normal launch");
            [self launchNormalController:viewController param:param];
        }
    }];
}
@end
