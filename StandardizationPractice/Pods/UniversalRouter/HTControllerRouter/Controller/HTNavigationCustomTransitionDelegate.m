//
//  HTNavigationTransitionDelegate.m
//  HTUIDemo
//
//  Created by zp on 15/8/12.
//  Copyright (c) 2015年 HT. All rights reserved.
//

#import "HTNavigationCustomTransitionDelegate.h"
#import "HTNavigationPanProtocol.h"
#import "UIViewController+HTUtils.h"
#import "UIViewController+HTRouterUtils.h"
#import "HTControllerRouterLogger.h"
#import "HTNavigationTransitionAnimator.h"
#import "HTNavigationPanGestureHandler.h"
#import "HTNavigationGestureHandlerDelegate.h"
#import "HTNavigationSystemPanGestureHandler.h"
#import "HTPercentDrivenInteractiveTransition.h"
@interface HTNavigationCustomTransitionDelegate()<UIGestureRecognizerDelegate, HTNavigationGestureHandlerDelegate>

@property (nonatomic, weak) UINavigationController *navigationViewController;

/**
 *  实现navigation的手势，可以全屏返回，scroll view上滑动返回，支持设置返回响应区域。
 *  navigation初始化时根据handlerClass构造
 */
@property (nonatomic, strong) HTNavigationPanGestureHandler * gestureHandler;

@property (nonatomic, strong) UIPercentDrivenInteractiveTransition* interactionController;

@property (nonatomic, strong) id<UIViewControllerAnimatedTransitioning> hitPopAnimator;

@property (nonatomic, strong) id<UIViewControllerAnimatedTransitioning> interactionPopAnimator;

@property (nonatomic, strong) id<UIViewControllerAnimatedTransitioning> pushAnimator;
@end

@implementation HTNavigationCustomTransitionDelegate
static Class globalTransitionClassPopHit = nil;
static Class globalTransitionClassPopInteraction = nil;
static Class globalTransitionClassPush = nil;
static Class globalInteractionControllerClass = nil;
- (instancetype)initWithParentViewController:(UINavigationController*)navigationController
{
    self = [super init];
    if (self){
        _navigationViewController = navigationController;
        
        _popHitTransitionClass = nil;
        _popInteractiveTransitionClass = HTNavigationTransitionAnimator.class;
        _pushTransitionClass = nil;
        _interactiveTransitionClass = HTPercentDrivenInteractiveTransition.class;
        
        _gestureHandler = [[HTNavigationPanGestureHandler alloc] initWithNavigationController:navigationController gestureHandlerDelegate:self];
    }
    
    return self;
}

+ (void)setPopHitTransitionClass:(Class)cls
{
    NSAssert1(cls == nil || [cls conformsToProtocol:@protocol(UIViewControllerAnimatedTransitioning)], @"input class: %@ must conform protocol UIViewControllerAnimatedTransitioning", cls);
    globalTransitionClassPopHit = cls;
}

+ (void)setPopInteractiveTransitionClass:(Class)cls
{
    NSAssert1(cls == nil || [cls conformsToProtocol:@protocol(UIViewControllerAnimatedTransitioning)], @"input class: %@ must conform protocol UIViewControllerAnimatedTransitioning", cls);
    globalTransitionClassPopInteraction = cls;
}

+ (void)setPushTransitionClass:(Class)cls
{
    NSAssert1(cls == nil || [cls conformsToProtocol:@protocol(UIViewControllerAnimatedTransitioning)], @"input class: %@ must conform protocol UIViewControllerAnimatedTransitioning", cls);
    globalTransitionClassPush = cls;
}

+ (void)setInteractiveTransitionClass:(Class)cls
{
    NSAssert1(cls == nil || [cls isSubclassOfClass:UIPercentDrivenInteractiveTransition.class], @"input class: %@ must be sub class for UIPercentDrivenInteractiveTransition", cls);
    globalInteractionControllerClass = cls;
}

+ (Class)popHitTransitionClass{return globalTransitionClassPopHit;}

+ (Class)popInteractiveTransitionClass{return globalTransitionClassPopInteraction;}

+ (Class)pushTransitionClass{return globalTransitionClassPush;}

+ (Class)interactiveTransitionClass{return globalInteractionControllerClass;}

- (void)setPopHitTransitionClass:(Class)cls
{
    NSAssert1(cls == nil || [cls conformsToProtocol:@protocol(UIViewControllerAnimatedTransitioning)], @"input class: %@ must conform protocol UIViewControllerAnimatedTransitioning", cls);
    _popHitTransitionClass = cls;
    _hitPopAnimator = nil;
}

- (void)setPopInteractiveTransitionClass:(Class)cls
{
    NSAssert1(cls == nil || [cls conformsToProtocol:@protocol(UIViewControllerAnimatedTransitioning)], @"input class: %@ must conform protocol UIViewControllerAnimatedTransitioning", cls);
    _popInteractiveTransitionClass = cls;
    _interactionPopAnimator = nil;
}

- (void)setPushTransitionClass:(Class)cls
{
    NSAssert1(cls == nil || [cls conformsToProtocol:@protocol(UIViewControllerAnimatedTransitioning)], @"input class: %@ must conform protocol UIViewControllerAnimatedTransitioning", cls);
    _pushTransitionClass = cls;
    _pushAnimator = nil;
}

- (void)setInteractiveTransitionClass:(Class)cls
{
    NSAssert1(cls == nil || [cls isSubclassOfClass:UIPercentDrivenInteractiveTransition.class], @"input class: %@ must be sub class for UIPercentDrivenInteractiveTransition", cls);
    _interactiveTransitionClass = cls;
    _interactionController = nil;
}

- (void)setMaxAllowedSlideDistanceToLeftEdge:(float)maxAllowedSlideDistanceToLeftEdge
{
    _gestureHandler.maxAllowedSlideDistanceToLeftEdge = maxAllowedSlideDistanceToLeftEdge;
}

- (float)maxAllowedSlideDistanceToLeftEdge
{
    return _gestureHandler.maxAllowedSlideDistanceToLeftEdge;
}

#pragma mark - HTNavigationGestureHandlerDelegate

- (void)navigationController:(UINavigationController*)navigationController
           panGestureChanged:(UIPanGestureRecognizer*)gestureRecognizer
{
    CGFloat screenWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
    CGPoint translation = [gestureRecognizer translationInView:_navigationViewController.view];
    
    CGFloat percent = translation.x/screenWidth;
    percent = percent < 0 ? 0 : percent;
    percent = percent > 1 ? 1 : percent;
    
    [_interactionController updateInteractiveTransition:percent];
}

- (void)navigationController:(UINavigationController*)navigationController
             panGestureBegin:(UIPanGestureRecognizer*)gestureRecognizer
{
    if (_interactionController == nil) {
        Class usedCls = globalInteractionControllerClass ? : _interactiveTransitionClass;
        _interactionController = usedCls ? [[usedCls alloc] init] : nil;
    }
    /**
     *  Note：自定义手势需要手动pop
     */
    [_navigationViewController popViewControllerAnimated:YES];
}

- (void)navigationController:(UINavigationController*)navigationController
             panGestureEnded:(UIPanGestureRecognizer*)gestureRecognizer
                  isCanceled:(BOOL)isCancel
{
    if (isCancel)
        [_interactionController cancelInteractiveTransition];
    else{
        [_interactionController finishInteractiveTransition];
    }
    
    _interactionController = nil;
}

#pragma mark - UINavigationControllerDelegate

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
{
    if (operation == UINavigationControllerOperationPop) {
        if (_gestureHandler.bPanning) {
            Class popIntClass = globalTransitionClassPopInteraction ? : _popInteractiveTransitionClass;
            if (!_interactionPopAnimator || (_interactionPopAnimator && ![_interactionPopAnimator isKindOfClass:popIntClass]))
            {
                _interactionPopAnimator = [popIntClass new];
            }
            return _interactionPopAnimator;
        } else {
            Class popClass = globalTransitionClassPopHit ? : _popHitTransitionClass;
            if (!_hitPopAnimator || (_hitPopAnimator && ![_hitPopAnimator isKindOfClass:popClass]))
            {
                _hitPopAnimator = [popClass new];
            }
            return _hitPopAnimator;
        }
    }
    if (operation == UINavigationControllerOperationPush) {
        
        Class pushClass = globalTransitionClassPush ? : _pushTransitionClass;
        if (!_pushAnimator || (_pushAnimator && ![_pushAnimator isKindOfClass:pushClass]))
        {
            _pushAnimator = [pushClass new];
        }
        return _pushAnimator;
    }
    return nil;
}

- (id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController
{
    return _interactionController;
}

@end
