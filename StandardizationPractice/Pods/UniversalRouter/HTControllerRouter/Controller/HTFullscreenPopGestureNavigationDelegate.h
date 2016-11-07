//
//  HTNavigationTransitionDelegate.h
//  HTUIDemo
//
//  Created by zp on 15/8/12.
//  Copyright (c) 2015年 HT. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HTControllerRouter.h"
/*!
 *  全屏返回手势；系统原生的页面transition效果；在scroll view上右划的返回功能；
 */
@interface HTFullscreenPopGestureNavigationDelegate : NSObject<UINavigationControllerDelegate, HTNavigationDelegateInitProtocol>

- (instancetype)initWithParentViewController:(UINavigationController*)navigationController;

@end
