//
//  UITabBarController+HTRouterUtils.m
//  HTUIDemo
//
//  Created by zp on 15/9/1.
//  Copyright (c) 2015年 HT. All rights reserved.
//

#import "UITabBarController+HTRouterUtils.h"

@implementation UITabBarController (HTRouter)

- (BOOL)ht_isChileViewControllerVisible:(UIViewController*)childViewController
{
    NSUInteger index = [self.childViewControllers indexOfObject:childViewController];
    if (self.selectedIndex == index)
        return YES;
    
    return NO;
}

- (BOOL)ht_canMakeViewControllerVisible:(UIViewController*)childViewController
{
    return [self.childViewControllers indexOfObject:childViewController] != NSNotFound;
}

- (void)ht_makeViewControllerVisible:(UIViewController*)childViewController animated:(BOOL)animated
{
    NSAssert([self ht_canMakeViewControllerVisible:childViewController], @"UITabbarController cannot make %@ clear to top", childViewController);
    
    NSUInteger index = [self.childViewControllers indexOfObject:childViewController];
    self.selectedIndex = index;
}

- (UIViewController*)ht_currentChildViewController
{
    return self.selectedViewController;
}
@end
