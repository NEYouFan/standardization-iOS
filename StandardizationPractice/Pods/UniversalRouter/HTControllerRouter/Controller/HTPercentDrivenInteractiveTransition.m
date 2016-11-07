//
//  HTPercentDrivenInteractiveTransition.m
//  Pods
//
//  Created by zp on 15/10/21.
//
//

#import "HTPercentDrivenInteractiveTransition.h"

extern const CGFloat kHTToViewControllerTranstionOffset;

@interface HTPercentDrivenInteractiveTransition()

@property (nonatomic, weak) id<UIViewControllerContextTransitioning> transitionContext;

@property (nonatomic, assign) CGFloat percent;

@end

@implementation HTPercentDrivenInteractiveTransition

- (NSTimeInterval)animationDuration{
    return 0.25;
}

-(void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    self.transitionContext = transitionContext;
    _percent = 0;
    
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    [transitionContext.containerView addSubview:toViewController.view];
    [transitionContext.containerView addSubview:fromViewController.view];
    
    fromViewController.view.layer.shadowOpacity = 0.3f;
    fromViewController.view.layer.cornerRadius = 4.0f;
    fromViewController.view.layer.shadowOffset = CGSizeZero;
    fromViewController.view.layer.shadowRadius = 4.0f;
    fromViewController.view.layer.shadowPath = [UIBezierPath bezierPathWithRect:fromViewController.view.bounds].CGPath;
}

- (void)updateInteractiveTransition:(CGFloat)percentComplete {
    [super updateInteractiveTransition:percentComplete];
    
    id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;
    
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    CGFloat screenWidth = CGRectGetWidth([UIScreen mainScreen].bounds);

    toViewController.view.transform = CGAffineTransformMakeTranslation(-kHTToViewControllerTranstionOffset * (1 - percentComplete), 0);
    fromViewController.view.transform = CGAffineTransformMakeTranslation(screenWidth*percentComplete, 0);
    
    _percent = percentComplete;
}

- (void)finishInteractiveTransition {
    id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;
    
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    CGFloat screenWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
    
    [UIView animateWithDuration:(1-_percent)*[self animationDuration] delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        fromViewController.view.transform = CGAffineTransformMakeTranslation(screenWidth, 0);
        toViewController.view.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        fromViewController.view.transform = CGAffineTransformIdentity;
        [transitionContext.containerView addSubview:fromViewController.view];
        [transitionContext.containerView addSubview:toViewController.view];
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
    
    _transitionContext = nil;
    
    [super finishInteractiveTransition];
}

- (void)cancelInteractiveTransition {
    id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;
    
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    [UIView animateWithDuration:(1-_percent)*[self animationDuration] delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        fromViewController.view.transform = CGAffineTransformIdentity;
        toViewController.view.transform = CGAffineTransformMakeTranslation(-kHTToViewControllerTranstionOffset, 0);
    } completion:^(BOOL finished) {
        toViewController.view.transform = CGAffineTransformIdentity;
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
    
    _transitionContext = nil;
    
    [super cancelInteractiveTransition];
}
@end
