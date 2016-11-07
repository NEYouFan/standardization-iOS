//
//  UIViewController+HTRouter.m
//  Pods
//
//  Created by 志强 on 16/3/19.
//
//

#import "UIViewController+HTRouter.h"

#import "HTControllerRouter.h"
@implementation UIViewController (HTRouter)

- (UIViewController*)pushViewControllerWithURL:(NSString*)url
{
    HTControllerRouteParam * param = [[HTControllerRouteParam alloc] initWithURL:url launchMode:HTControllerLaunchModePush];
    return [[HTControllerRouter sharedRouter] route:param];
}

- (UIViewController*)pushViewControllerWithURL:(NSString*)url params:(id)params
{
    HTControllerRouteParam * theParam = [[HTControllerRouteParam alloc] initWithURL:url launchMode:HTControllerLaunchModePush];
    theParam.params = params;
    return [[HTControllerRouter sharedRouter] route:theParam];
}

- (UIViewController*)presentViewControllerWithURL:(NSString*)url
{
    HTControllerRouteParam * param = [[HTControllerRouteParam alloc] initWithURL:url launchMode:HTControllerLaunchModePresent];
    return [[HTControllerRouter sharedRouter] route:param];
}

- (UIViewController*)presentViewControllerWithURL:(NSString*)url params:(id)params
{
    HTControllerRouteParam * theParam = [[HTControllerRouteParam alloc] initWithURL:url launchMode:HTControllerLaunchModePresent];
    theParam.params = params;
    return [[HTControllerRouter sharedRouter] route:theParam];
}
@end
