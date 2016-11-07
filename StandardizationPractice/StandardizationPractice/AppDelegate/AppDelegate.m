//
//  AppDelegate.m
//  StandardizationPractice
//
//  Created by Baitianyu on 18/10/2016.
//  Copyright © 2016 Netease. All rights reserved.
//

#import "AppDelegate.h"
#import "SPLaunchPageController.h"
#import "SPTabBarController.h"
#import "SPLoginController.h"
#import "HTNavigationController.h"
#import "SDWebImageDownloader.h"
#import "SPNetworking.h"
#import "IQKeyboardManager.h"

@interface AppDelegate () <SPLaunchPageControllerDelegate>

@property (nonatomic, strong) SPLoginController *loginController;
@property (nonatomic, strong) SPTabBarController *tabBarController;
@property (nonatomic, strong) SPLaunchPageController *launchPageController;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // 初始化网络配置.
    [SPNetworking SPNetworkInit];

    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    
    // SDWebImage 图片加载方式 LIFO (为了优化显示效果，后入队的先加载)
    [[SDWebImageDownloader sharedDownloader] setExecutionOrder:SDWebImageDownloaderLIFOExecutionOrder];
    
    // 全局键盘
    IQKeyboardManager *keyboardManager = [IQKeyboardManager sharedManager];
    keyboardManager.enable = YES;
    keyboardManager.shouldResignOnTouchOutside = YES;
    keyboardManager.shouldToolbarUsesTextFieldTintColor = YES;
    keyboardManager.enableAutoToolbar = NO;
    
    _launchPageController = [[SPLaunchPageController alloc] init];
    _launchPageController.delegate = self;
    self.window.rootViewController = _launchPageController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


#pragma mark - ZSLaunchPageControllerDelegate.

- (void)launchPageControllerDidDisappear:(SPLaunchPageController *)launchPageController {
    if (_launchPageController != launchPageController) {
        return;
    }
    UIViewController *rootController = [self getRootController];
    self.window.rootViewController = rootController;
    
    // 页面转场过渡
    [rootController.view addSubview:launchPageController.view];
    [UIView animateWithDuration:.25
                     animations:^{
                         launchPageController.view.alpha = 0;
                     } completion:^(BOOL finished) {
                         [launchPageController.view removeFromSuperview];
                     }];
    
}

- (UIViewController *)getRootController {
    // TODO：是否已经登录，如果已经登录则显示 tabbar，否则显示登录页面
    if (!_loginController) {
        _tabBarController = [[SPTabBarController alloc] init];
        
        HTNavigationController *rootNaviController = [[HTNavigationController alloc] initWithRootViewController:_tabBarController];
        [rootNaviController setNavigationBarHidden:YES animated:NO];
        _rootNavigationController = rootNaviController;
        return rootNaviController;
    } else {
        _loginController = [[SPLoginController alloc] init];
        return _loginController;
    }
}

@end
