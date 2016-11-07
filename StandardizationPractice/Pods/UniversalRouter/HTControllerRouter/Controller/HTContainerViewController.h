//
//  HTContainerViewController.h
//  TestInnerNavigationController
//
//  Created by zp on 15/7/7.
//  Copyright (c) 2015年 zp. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HTContainerViewController;

@protocol HTContainerViewControllerProtocol <NSObject>

@property (nonatomic, weak) HTContainerViewController *containerController;

@end

/*!
 *  包裹了一个Navigation Controller的Container Controller。
 */
@interface HTContainerViewController : UIViewController

/*!
 *  包裹的NavigationController
 */
@property (nonatomic, strong) UINavigationController *rootNavigationController;


/*!
 *  HTContainerViewController(self) --> HTNavigationController --root view controller --> vc
 *
 *  @param vc 被包裹的view controller实例
 *
 *  @return 实例对象
 */
- (id)initWithRootViewController:(UIViewController*)vc;

/*!
 *  跟上个函数功能类似，只是包裹的NavigationController 的 delegate类型可以被配置
 *
 *  @param vc  被包裹的view controller实例
 *  @param cls 被包裹的Navigation Controller class 的 delegate 类型，
 *  当使用HTNavigationTransitionAnimator时，提供自定义转场动画的配置。
 *
 *  @return 实例对象
 */
- (id)initWithRootViewController:(UIViewController *)vc navigationDelegateClass:(Class)cls;
@end
