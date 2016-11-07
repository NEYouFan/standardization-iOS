//
//  UINavigationController+HTRouterUtils.m
//  HTUIDemo
//
//  Created by zp on 15/9/1.
//  Copyright (c) 2015年 HT. All rights reserved.
//

#import "UINavigationController+HTRouterUtils.h"

@implementation UINavigationController (HTRouter)

- (BOOL)ht_isChileViewControllerVisible:(UIViewController*)childViewController
{
    return self.viewControllers.lastObject == childViewController;
}

- (BOOL)ht_canMakeViewControllerVisible:(UIViewController*)childViewController
{
    return [self.viewControllers indexOfObject:childViewController] != NSNotFound;
}

- (void)ht_makeViewControllerVisible:(UIViewController*)childViewController animated:(BOOL)animated
{
    NSAssert1([self.viewControllers indexOfObject:childViewController] != NSNotFound, @"UINavigationController ht_canMakeViewControllerVisible %@ is not one of childViewController", childViewController);
    
    if (self.viewControllers.lastObject == childViewController)
        return;
    
    NSMutableArray *children = [self.viewControllers mutableCopy];
    while (children.lastObject != childViewController) {
        [children removeLastObject];
    }

    [self setViewControllers:children animated:animated];
}

- (UIViewController*)ht_currentChildViewController
{
    return self.viewControllers.lastObject;
}
@end
