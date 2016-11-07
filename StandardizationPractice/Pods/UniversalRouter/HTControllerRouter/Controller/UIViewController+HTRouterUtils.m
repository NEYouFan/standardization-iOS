//
//  UIViewController+HTRouterUtils.m
//  HTUIDemo
//
//  Created by zp on 15/8/28.
//  Copyright (c) 2015年 HT. All rights reserved.
//

#import "UIViewController+HTRouterUtils.h"
#import "HTContainerViewController.h"
#import <objc/runtime.h>

static const char *kSingleInstance = "__HT_SINGLEINSTANCE_VIEWCONTROLLER";

@implementation UIViewController (HTRouterUtils)

+ (void)ht_setSingleInstance:(UIViewController*)vc
{
    objc_setAssociatedObject(self, kSingleInstance, vc, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (UIViewController*)ht_getSingleInstance
{
    return objc_getAssociatedObject(self, kSingleInstance);;
}

- (BOOL)ht_isChileViewControllerVisible:(UIViewController*)childViewController
{
    if (self.childViewControllers.count == 1 && self.childViewControllers.lastObject == childViewController)
        return YES;
    
    return NO;
}

- (BOOL)ht_canMakeViewControllerVisible:(UIViewController*)childViewController
{
    if (self.childViewControllers.count == 1 && self.childViewControllers.lastObject == childViewController)
        return YES;
    
    return NO;
}

- (void)ht_makeViewControllerVisible:(UIViewController*)childViewController animated:(BOOL)animated
{
    NSAssert([self ht_canMakeViewControllerVisible:childViewController], @"ht_makeViewControllerVisible cannot be here");
}

- (UIViewController*)ht_currentChildViewController
{
    return self.childViewControllers.lastObject;
}

- (UINavigationController*)ht_innerMostNavigationControllerWithNavigationBarHidden:(BOOL)bHidden
{
    UINavigationController *foudController = [self isKindOfClass:UINavigationController.class] ? (UINavigationController*)self : nil;
    
    UIViewController *currentViewController = self;
    while (currentViewController) {
        UIViewController *childViewController = [currentViewController ht_currentChildViewController];
        if ([childViewController isKindOfClass:UINavigationController.class] &&
            [(UINavigationController*)childViewController isNavigationBarHidden] == bHidden){
            foudController = (UINavigationController*)childViewController;
        }
        
        currentViewController = childViewController;
    }
    
    return foudController;
}

- (UINavigationController*)ht_innerMostNavigationController
{
    UINavigationController *foudController = [self isKindOfClass:UINavigationController.class] ? (UINavigationController*)self : nil;
    
    UIViewController *currentViewController = self;
    while (currentViewController) {
        UIViewController *childViewController = [currentViewController ht_currentChildViewController];
        if ([childViewController isKindOfClass:UINavigationController.class]){
            foudController = (UINavigationController*)childViewController;
        }
        
        currentViewController = childViewController;
    }
    
    return foudController;

}

- (void)ht_back
{
    if (self.navigationController.viewControllers.count > 1){
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    if ([self conformsToProtocol:@protocol(HTContainerViewControllerProtocol)]){
        UINavigationController *containerNavigationController = [(id<HTContainerViewControllerProtocol>)self containerController].navigationController;
        if (containerNavigationController.viewControllers.count > 1){
            [containerNavigationController popViewControllerAnimated:YES];
            return;
        }
    }
    
    if (self.presentingViewController){
        [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
            
        }];
        return;
    }
}
@end
