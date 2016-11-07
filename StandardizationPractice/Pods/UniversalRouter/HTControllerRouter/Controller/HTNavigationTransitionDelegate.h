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
 *  全屏返回手势；自定义的页面transition：交互transition，和系统原生效果类似，但是只有渐变没有滑动 HTPercentDrivenInteractiveTransition 和 非交互transition，和系统原生效果一致 HTNavigationTransitionAnimator；在scroll view上右划的返回功能；
 */
@interface HTNavigationTransitionDelegate : NSObject<UINavigationControllerDelegate, HTNavigationDelegateInitProtocol>

- (instancetype)initWithParentViewController:(UINavigationController*)navigationController;

- (void)registeUIViewControllerAnimatedTransitioningClass:(Class)cls;

@end

