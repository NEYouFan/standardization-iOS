//
//  UIViewController+HTRouter.h
//  Pods
//
//  Created by 志强 on 16/3/19.
//
//

#import <UIKit/UIKit.h>
#import "HTControllerRouteInfo.h"
@interface UIViewController (HTRouter)

/**
 *  使用push方式弹出页面
 */
- (UIViewController*)pushViewControllerWithURL:(NSString*)url;

/**
 *  使用push方式弹出页面，使用params传递更多的参数
 */
- (UIViewController*)pushViewControllerWithURL:(NSString*)url params:(id)params;

/**
 *  使用present方式弹出页面
 */
- (UIViewController*)presentViewControllerWithURL:(NSString*)url;

/**
 *  使用present方式弹出页面，使用params传递更多的参数
 */
- (UIViewController*)presentViewControllerWithURL:(NSString*)url params:(id)params;

@end
