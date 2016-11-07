//
//  UITabBarController+HTRouterUtils.h
//  HTUIDemo
//
//  Created by zp on 15/9/1.
//  Copyright (c) 2015年 HT. All rights reserved.
//

#import <UIKit/UIKit.h>
/**
 *  包含HT内部使用的接口
 */
@interface UITabBarController (HTRouter)
- (BOOL)ht_isChileViewControllerVisible:(UIViewController*)childViewController;
- (BOOL)ht_canMakeViewControllerVisible:(UIViewController*)childViewController;
- (void)ht_makeViewControllerVisible:(UIViewController*)childViewController animated:(BOOL)animated;
- (UIViewController*)ht_currentChildViewController;
@end
