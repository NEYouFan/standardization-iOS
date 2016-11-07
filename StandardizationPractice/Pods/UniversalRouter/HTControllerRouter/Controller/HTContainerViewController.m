//
//  HTContainerViewController.m
//  TestInnerNavigationController
//
//  Created by zp on 15/7/7.
//  Copyright (c) 2015年 zp. All rights reserved.
//

#import "HTContainerViewController.h"
#import "HTNavigationController.h"

@interface HTContainerViewController ()
@end

@implementation HTContainerViewController

- (id)initWithRootViewController:(UIViewController*)vc
{
    return [self initWithRootViewController:vc navigationDelegateClass:nil];
}

- (id)initWithRootViewController:(UIViewController *)vc navigationDelegateClass:(Class)cls
{
    if (self = [super init]){
        HTNavigationController *naviVC = [[HTNavigationController alloc] initWithRootViewController:vc delegateClass:cls];
        
        [self addChildViewController:naviVC];
        
        if ([vc conformsToProtocol:@protocol(HTContainerViewControllerProtocol)]){
            [(id<HTContainerViewControllerProtocol>)vc setContainerController:self];
        }
        
        _rootNavigationController = naviVC;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
   
    [self.view addSubview:self.rootNavigationController.view];
}

@end
