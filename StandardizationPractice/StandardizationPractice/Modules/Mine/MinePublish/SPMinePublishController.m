//
//  SPMinePublishController.m
//  StandardizationPractice
//
//  Created by Baitianyu on 20/10/2016.
//  Copyright © 2016 Netease. All rights reserved.
//

#import "SPMinePublishController.h"
#import "HTControllerRouteInfo.h"
#import "HTControllerRouter.h"
#import "HTContainerViewController.h"
#import "UINavigationBar+HT.h"
#import "HTNavigationPanProtocol.h"
#import "UIViewController+HTRouter.h"
#import "UIViewController+SPNavigationBar.h"
#import "UIView+SPLoading.h"

@interface SPMinePublishController () <HTRouteTargetProtocol,
                                       HTContainerViewControllerProtocol,
                                       HTNavigationBackPanGestureProtocol>

@end

@implementation SPMinePublishController
@synthesize containerController;

#pragma mark - Router

+ (HTControllerRouterConfig*)configureRouter {
    HT_EXPORT();
    HTControllerRouterConfig *config = [[HTControllerRouterConfig alloc] initWithUrlPath:[self urlPath]];
    return config;
}

+ (NSString*)urlPath {
    return @"standardization://mine/publish";
}

- (void)receiveRoute:(HTControllerRouteParam*)param {
    
}


#pragma mark - Life cycle.

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [SPThemeColors backgroundColor];
    [self sp_applyDefaultNavigationBarStyle];
    [self sp_addNavigationLeftBackItem];
    
    [self.view sp_showLoading];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.view sp_showLoadingEmpty];
    });
}

@end
