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
 *  多种情况navigation的转场动画的设置：
 *  1.push Transition
 *  2.点击引起的Hit Pop
 *  3.手势拖拽引起的Interaction Pop
 *  
 *  可以直接设置InteractiveTransition
 */
@interface HTNavigationSystemTransitionDelegate : NSObject<UINavigationControllerDelegate, HTNavigationDelegateInitProtocol>

/**
 *  支持设置点击pop Transition
 *  default nil
 *  可选值：HTNavigationTransitionAnimator及实现协议UIViewControllerAnimatedTransitioning的类
 */
@property (nonatomic, strong) Class popHitTransitionClass;

/**
 *  设置交互pop Transition
 *  default nil
 *  可选值：HTNavigationTransitionAnimator及实现协议UIViewControllerAnimatedTransitioning的类
 */
@property (nonatomic, strong) Class popInteractiveTransitionClass;

/**
 *  设置push动画类，default nil，使用系统动画
 *  可选值：HTNavigationTransitionAnimator及实现协议UIViewControllerAnimatedTransitioning的类
 */
@property (nonatomic, strong) Class pushTransitionClass;

/**
 *  支持设置交互动画，默认为nil
 *  可选值：UIPercentDrivenInteractiveTransition；HTPercentDrivenInteractiveTransition，模仿系统的手势后退效果；及UIPercentDrivenInteractiveTransition的子类
 *
 */
@property (nonatomic, strong) Class interactiveTransitionClass;

/**
 *  设置全局手势识别的判定区域
 */
@property (nonatomic, assign) float maxAllowedSlideDistanceToLeftEdge;

/**
 *  构造方法
 */
- (instancetype)initWithParentViewController:(UINavigationController*)navigationController;

/**
 *  设置全局点击Pop Transition
 *  default nil
 */
+ (void)setPopHitTransitionClass:(Class)cls;
/**
 *  设置全局交互Pop Transition
 *  default nil
 *  可选值：HTNavigationTransitionAnimator及实现协议UIViewControllerAnimatedTransitioning的类
 *
 */
+ (void)setPopInteractiveTransitionClass:(Class)cls;
/**
 *  设置全局Push Transition
 *  default nil
 *  可选值：HTNavigationTransitionAnimator及实现协议UIViewControllerAnimatedTransitioning的类
 */
+ (void)setPushTransitionClass:(Class)cls;
/**
 *  设置全局InteractiveTransition
 *  default nil
 *  可选值：UIPercentDrivenInteractiveTransition；HTPercentDrivenInteractiveTransition，模仿系统的手势后退效果；及UIPercentDrivenInteractiveTransition的子类
 */
+ (void)setInteractiveTransitionClass:(Class)cls;

+ (Class)popHitTransitionClass;

+ (Class)popInteractiveTransitionClass;

+ (Class)pushTransitionClass;

+ (Class)interactiveTransitionClass;
@end

