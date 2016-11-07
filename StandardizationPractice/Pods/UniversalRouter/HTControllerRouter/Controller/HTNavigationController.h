//
//  HTNavigationController.h
//  HTUIDemo
//
//  Created by zp on 15/8/31.
//  Copyright (c) 2015年 HT. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HTNavigationCustomTransitionDelegate;
@protocol HTNavigationDelegateInitProtocol;

/*!
 *  可以持有 delegate 的 NavigationController
 */
@interface HTNavigationController : UINavigationController

@property (nonatomic, strong) id <UINavigationControllerDelegate, HTNavigationDelegateInitProtocol> navigationDelegate;

/**
 *  构造方法，根据delegate类型调用delegate的构造方法
 *
 *  @param delegateClass 实现HTNavigationTransitionDelegate
 */
- (instancetype)initWithRootViewController:(UIViewController *)rootViewController delegateClass:(Class)delegateClass;


@end
