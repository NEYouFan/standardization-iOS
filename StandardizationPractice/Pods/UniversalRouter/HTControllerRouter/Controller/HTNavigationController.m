//
//  HTNavigationController.m
//  HTUIDemo
//
//  Created by zp on 15/8/31.
//  Copyright (c) 2015年 HT. All rights reserved.
//

#import "HTNavigationController.h"
#import "HTNavigationCustomTransitionDelegate.h"
#import "HTNavigationSystemTransitionDelegate.h"
@interface HTNavigationController()

@end

@implementation HTNavigationController

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController
{
    return [self initWithRootViewController:rootViewController delegateClass:nil];
}

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController
                             delegateClass:(Class)delegateClass
{
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        {
            Class usedDelegateClass = delegateClass ? : HTNavigationCustomTransitionDelegate.class;
            NSAssert1([usedDelegateClass conformsToProtocol:@protocol(UINavigationControllerDelegate)] || [usedDelegateClass conformsToProtocol:@protocol(HTNavigationDelegateInitProtocol)], @"input class: %@ must conform protocol UINavigationControllerDelegate and HTNavigationDelegateInitProtocol", usedDelegateClass);
            
            _navigationDelegate = [[usedDelegateClass alloc] initWithParentViewController:self];
        }
        self.delegate = _navigationDelegate;
    }
    return self;
}

- (void)setNavigationDelegate:(id<UINavigationControllerDelegate,HTNavigationDelegateInitProtocol>)navigationDelegate
{
    _navigationDelegate = navigationDelegate;
    self.delegate = navigationDelegate;
}
@end
