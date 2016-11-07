//
//  HTControllerRouter.h
//  HTUIDemo
//
//  Created by zp on 15/8/28.
//  Copyright (c) 2015年 HT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTControllerRouteInfo.h"
NS_ASSUME_NONNULL_BEGIN
/*!
 *  每个希望被route的controller，需要实现该接口，告知router系统，自身的url等route信息。
 */
@protocol HTRouteTargetProtocol <NSObject>

/*!
 *  在应用加载的时候，所有实现了该接口的类，会注册到ControllerRouter系统中。
 */
@required
+ (HTControllerRouterConfig*)configureRouter;

@optional
@property (nonatomic, weak) id routerDelegate;

/*!
 *  当该页面被route的时候，会回调到这里来，通知route的参数
 *
 *  @param param route的参数
 */
- (void)receiveRoute:(HTControllerRouteParam*)param;

@end

/**
 *  支持全屏右划手势的协议。
 *  HT的navigation delegate都遵守此协议。
 */
#warning 位置换一下
@protocol HTNavigationDelegateInitProtocol <NSObject>

- (instancetype)initWithParentViewController:(UINavigationController*)navigationController;

@end

typedef  UIViewController * _Nonnull (^HTRouterViewControllerSetUpBlock)(_Nullable Class findVCClass, _Nullable id findVC, HTControllerRouteParam * _Nullable usedParam);

@interface HTControllerRouter : NSObject

/*!
 *  应用应该使用该单实例controller对象
 *
 *  @return
 */
+ (instancetype)sharedRouter;

/*!
 *  使用param来调度，如果得到要调度的vc，则会返回该vc的句柄
 *
 *  @param param Route的参数
 *
 *  @return 调用的vc
 */
- (UIViewController*)route:(HTControllerRouteParam*)param;

/**
 *  使用block构造和配置页面
 *
 *  @param param   router需要的传入参数
 *  @param handler findVCClass：根据url查找到的页面类
 *  @param handler findVC：页面实例化规则固定的情况(single instance, single task)，返回构造好的实例；其他情况为nil
 *  @param handler usedParam：传递给页面的参数
 *
 *  @return 被route的页面
 */
- (UIViewController*)route:(HTControllerRouteParam*)param
                   handler:(_Nullable HTRouterViewControllerSetUpBlock)handler;


/*!
 *  注册HTNavigationController的delegate class，可用于自定义返回手势和transtion动画
 *  参照HTFullscreenPopGestureNavigationDelegate 和 HTNavigationTransitionDelegate
 *  cls需要遵守协议 HTNavigationDelegateInitProtocol
 *
 *  @param NavigationController delegate 类
 */
- (void)registeNavigationDelegateClass:(Class)cls;

/*!
 *  打印所有的Router url信息
 */
- (void)dumpRouter;

@end
NS_ASSUME_NONNULL_END
