//
//  UIViewController+HTRouterUtils.h
//  HTUIDemo
//
//  Created by zp on 15/8/28.
//  Copyright (c) 2015年 HT. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  包含HT内部使用的接口，和HT业务相关的功能
 */
@interface UIViewController (HTRouterUtils)

/*!
 *  单例vc的实例通过这个接口保存。保存为一个弱引用。
 *
 *  @param vc 单例对象
 */
+ (void)ht_setSingleInstance:(UIViewController*)vc;

/*!
 *  获取单例vc实例
 *
 *  @return 单例，可能为nil
 */
+ (UIViewController*)ht_getSingleInstance;

/*!
 *  相对于自身而言，childViewController是否可见。（有可能自身不可见，但是一旦自身可见，这个ChildViewController也可见，我们还是认为这个ChildViewController相对于self而言，可见）
 *
 *  @param childViewController
 *
 *  @return YES:相对于自身可见，否则不可见
 */
- (BOOL)ht_isChileViewControllerVisible:(UIViewController*)childViewController;

/*!
 *  判断能否让childViewController可见，当是UIViewController的时候，只能处理一种情况：只有一个child，且等于childViewController
 *
 *  "可见"：往往是指让childViewController处于Stack的顶部，或者处于selected状态
 *
 *  @param childViewController
 *
 *  @return YES:可以让这个child变成可见
 */
- (BOOL)ht_canMakeViewControllerVisible:(UIViewController*)childViewController;

/*!
 *  将childViewController变成可见
 *
 *  @param childViewController
 *  @param banimaed是否使用动画
 */
- (void)ht_makeViewControllerVisible:(UIViewController*)childViewController animated:(BOOL)animated;

/*!
 *  返回当前active Child view controller。active相对这个当前controller而言。
 *
 *  @return child view controller中处于相对active的child controller
 */
- (UIViewController*)ht_currentChildViewController;

/*!
 *  获取最active child 链上最末端的navigation controller。继承类不需要重写这个接口
 *
 *  @param bHidden 这个navigation controller的bar是否是隐藏的
 *
 *  @return navigation controller
 */
- (UINavigationController*)ht_innerMostNavigationControllerWithNavigationBarHidden:(BOOL)bHidden;

/*!
 *  获取最active child 链上最末端的navigation controller。继承类不需要重写这个接口
 *
 *  @return navigation controller
 */
- (UINavigationController*)ht_innerMostNavigationController;

/*!
 *  使用了HTContainerViewController或者HTControllerRouter的ViewController可以使用ht_back来实现后退页面的统一功能
 */
- (void)ht_back;
@end
