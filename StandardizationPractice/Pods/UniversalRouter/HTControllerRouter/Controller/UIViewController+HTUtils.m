//
//  UIViewController+HTUtils.m
//  HTUIDemo
//
//  Created by zp on 15/8/29.
//  Copyright (c) 2015年 HT. All rights reserved.
//

#import "UIViewController+HTUtils.h"
#import "UIViewController+HTRouterUtils.h"
#import "HTContainerViewController.h"

@implementation UIViewController (HTUtils)

+ (UIViewController*)ht_applicationRootViewController
{
    return [UIApplication sharedApplication].windows[0].rootViewController;
}

+ (UIViewController*) ht_topMostController
{
    UIViewController *topController = [self ht_applicationRootViewController];
    
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    return topController;
}

- (BOOL)ht_isControllerInPresentedControllerChain
{
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topController) {
        if (self == topController)
            return YES;
        
        topController = topController.presentedViewController;
    }
    
    return NO;
}

+ (UIViewController *)ht_findInstanceInPresentedControllerTree
{
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topController) {
        UIViewController * findResult = [topController ht_findInstanceAtChildrenByClass:self];
        if (findResult) {
            return findResult;
        }
        
        topController = topController.presentedViewController;
    }
    return nil;
}

/**
 *  从下一代中递归寻找class类型为cls的VC
 *
 *  @param cls 目标clas
 *
 *  @return 查找结果
 */
- (UIViewController *)ht_findInstanceAtChildrenByClass:(Class)cls
{
    if ([self isKindOfClass:cls]) {
        return self;
    }
    if ([self isKindOfClass:[UINavigationController class]]) {
        UINavigationController * navVC = (UINavigationController *)self;
        for (UIViewController * vcItem in [navVC viewControllers]) {
            UIViewController * findResult = [vcItem ht_findInstanceAtChildrenByClass:cls];
            if (findResult) {
                return findResult;
            }
        }
    } else {
        for (UIViewController * childVC in self.childViewControllers) {
            UIViewController * findResult = [childVC ht_findInstanceAtChildrenByClass:cls];
            if (findResult) {
                return findResult;
            }
        }
    }
    return nil;
}
- (BOOL)ht_isInControllerTreeVisiblePath
{
    UIViewController *topmostViewController = [UIViewController ht_topMostController];
    
    UIViewController *currentViewController = topmostViewController;
    while (currentViewController) {
        if (currentViewController == self)
            return YES;
        
        if ([currentViewController isKindOfClass:UINavigationController.class]){
            currentViewController = (UIViewController*)((UINavigationController*)currentViewController).viewControllers.lastObject;
        }
        else if ([currentViewController isKindOfClass:UITabBarController.class]){
            currentViewController = ((UITabBarController*)currentViewController).selectedViewController;
        }
        else{
            currentViewController = currentViewController.childViewControllers.lastObject;
        }
    }
    
    return NO;
}

- (void)ht_removeFromPresentedControllerChain:(RemoveControllerFromTreeCallback)cb
{
    UIViewController *presentingController = self.presentingViewController;
    UIViewController *presentedController = self.presentedViewController;
    if (presentingController == nil){
        [self dismissViewControllerAnimated:NO completion:^{
            cb(YES);
        }];
        return;
    }
    
    if (self.presentedViewController){
        [self dismissViewControllerAnimated:NO completion:^{
            [presentingController dismissViewControllerAnimated:NO completion:^{
                if (presentedController)
                    [presentingController presentViewController:presentedController animated:NO completion:^{
                        cb(YES);
                    }];
            }];
        }];
    }
    else{
        [presentingController dismissViewControllerAnimated:NO completion:^{
            if (presentedController)
                [presentingController presentViewController:presentedController animated:NO completion:^{
                    cb(YES);
                }];
        }];
    }
}

- (void)ht_removeFromNavigationController
{
    NSAssert([self.navigationController.viewControllers indexOfObject:self] != NSNotFound, @"controller is not in navigationcontroller");
    
    UINavigationController *navigationController = self.navigationController;
    NSMutableArray *vcs = [[navigationController viewControllers] mutableCopy];
    [vcs removeObject:self];
    [navigationController setViewControllers:vcs animated:NO];
}

/*
 ==========================================================
 关于问题：将一个ViewController显示出来，先从原来的tree中删除，然后放在当前显示的tree上！
 
 当ViewController由container包裹，
 1. 如果container的innerNavigationController的childViewController个数等于1，那么等价于删除ContainerViewController
 2. 如果container的innerNavigationController的childViewController个数大于1，无法处理，直接报错
 
 ---------------
 
 1. 当viewcontroller在另外一个navigation controller中：
    1. 如果navigation controller的child view controller个数大于1， 那么直接删除view controller
    2. 如果navigation controller的child view controller个数等于1
        当navigation controller在presented 链上，那么从链上删除这个vc
        否则报错
 
 2. 如果viewcontroller在presented 链上，那么直接从链上删除（如果是根，dismiss其他vc）
 
 3. 其他所有情况均无法删除
 */
- (void)ht_removeFromControllerTree:(RemoveControllerFromTreeCallback)cb
{
    HTContainerViewController *containerViewController;
    if ([self conformsToProtocol:@protocol(HTContainerViewControllerProtocol)]){
        containerViewController = [(id<HTContainerViewControllerProtocol>)self containerController];
    }
    
    if (containerViewController){
        if (containerViewController.rootNavigationController.viewControllers.count == 1){
            return [containerViewController ht_removeFromControllerTree:cb];
        }
        else{
            return cb(NO);
        }
    }
    
    if ([self ht_isControllerInPresentedControllerChain]){
        return [self ht_removeFromPresentedControllerChain:cb];
    }
    
    if ([self.parentViewController isKindOfClass:UINavigationController.class]){
        UINavigationController *parentNavigationController = (UINavigationController*)self.parentViewController;
        if (parentNavigationController.childViewControllers.count > 1){
            [self ht_removeFromNavigationController];
            return cb(YES);
        }
        else if (parentNavigationController.childViewControllers.count == 1 &&
                 [parentNavigationController ht_isControllerInPresentedControllerChain]){
            return [parentNavigationController ht_removeFromPresentedControllerChain:cb];
        }
        
        return cb(NO);
    }
    
    return cb(NO);
}

- (BOOL)ht_canClearToTopUseAnimation
{
    //当需要执行controller切换动作大于1次，就认为不能使用动画
    NSUInteger clearActionCount = 0;
    if (self.presentedViewController){
        clearActionCount ++;
    }
    
    UIViewController *viewController = self;
    while (viewController.parentViewController) {
        if (![viewController.parentViewController ht_isChileViewControllerVisible:viewController])
            clearActionCount ++;
        viewController = viewController.parentViewController;
    }
    
    return clearActionCount == 1;
}

- (BOOL)ht_clearToTop:(BOOL)animated
{
    animated = animated && [self ht_canClearToTopUseAnimation];
    
    if (self.presentedViewController){
        [self dismissViewControllerAnimated:animated completion:nil];
    }
    
    //自身，以及所有的ancestor，如果包裹在navigation controller中，必须确保self以及所有ancestor在navigation stack中最后一个。
    //自身，如果所有ancestor，任意一个是另外一个child view controllers，且不是最后一个，那么只有两种情况，我们知道如何clear to top
    //1. navigation 2. tabbar(需要切换selected index） 3. 其他均报错！
    //考虑让UIViewController继承类自己去决定怎么让一个孩子cleartotop..
    
    UIViewController *viewController = self;
    BOOL bCanClearToTop = YES;
    
    ///warning:这里需要注意：有些VC组织，并没有使用parentViewController进行tree结构的组织，此时clearToTop就会出问题！
    while (viewController.parentViewController) {
        if (![viewController.parentViewController ht_canMakeViewControllerVisible:viewController]){
            bCanClearToTop = NO;
            break;
        }
        
        viewController = viewController.parentViewController;
    }
    
    if (!bCanClearToTop)
        return NO;
    
    viewController = self;
    while (viewController.parentViewController) {
        [viewController.parentViewController ht_makeViewControllerVisible:viewController animated:animated];
        viewController = viewController.parentViewController;
    }
    
    return YES;
}

#if 0
- (BOOL)_ht_traverseViewController:(UIViewController*)currentViewController operation:(ControllerTreeTraverseOperation)operation
{
    if (!operation(currentViewController))
        return NO;
    
    NSArray *childViewController = currentViewController.childViewControllers;
    for (UIViewController *vc in childViewController) {
        if (![self _ht_traverseViewController:vc operation:operation])
            return NO;
    }
    
    if (self.presentedViewController){
        if (![self _ht_traverseViewController:self.presentedViewController operation:operation])
            return NO;
    }
    
    return YES;
}

- (void)ht_traverseControllerTree:(ControllerTreeTraverseOperation)operation
{
    [self _ht_traverseViewController:self operation:operation];
}

#endif


- (UIViewController*)ht_rootViewController
{
    UIViewController *currentViewController = self;
    while (currentViewController) {
        if (currentViewController.parentViewController == nil)
            return currentViewController;
        
        currentViewController = currentViewController.parentViewController;
    }
    
    return nil;
}
@end
