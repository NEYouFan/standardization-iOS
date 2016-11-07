//
//  HTNavigationTransitionAnimator.m
//  Pods
//
//  Created by 志强 on 16/3/14.
//
//

#import "HTNavigationTransitionAnimator.h"
#import "HTControllerRouterLogger.h"

const CGFloat kHTToViewControllerTranstionOffset = 40;

@implementation HTNavigationTransitionAnimator

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return 0.25;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController* toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController* fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    [[transitionContext containerView] addSubview:toViewController.view];
    [[transitionContext containerView] addSubview:fromViewController.view];
    
    CGFloat screenWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
    
    fromViewController.view.layer.shadowOpacity = 0.3f;
    fromViewController.view.layer.cornerRadius = 4.0f;
    fromViewController.view.layer.shadowOffset = CGSizeZero;
    fromViewController.view.layer.shadowRadius = 4.0f;
    fromViewController.view.layer.shadowPath = [UIBezierPath bezierPathWithRect:fromViewController.view.bounds].CGPath;
    
    fromViewController.view.transform = CGAffineTransformIdentity;
    toViewController.view.transform = CGAffineTransformMakeTranslation(-kHTToViewControllerTranstionOffset, 0);
    
    HTControllerRouterLogDebug(@"animateTransition start");
    
    /*
     * !注意，Cancel情况下，根据当前的移动百分比，取消动画的时间也是要算上百分比，所以感觉时间会非常短。这也是我们为什么取消的移动距离比较小的原因。
     */
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        fromViewController.view.transform = CGAffineTransformMakeTranslation(screenWidth, 0);
        toViewController.view.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        HTControllerRouterLogDebug(@"animateTransition complete :%d", finished);
        toViewController.view.transform = CGAffineTransformIdentity;
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}

@end