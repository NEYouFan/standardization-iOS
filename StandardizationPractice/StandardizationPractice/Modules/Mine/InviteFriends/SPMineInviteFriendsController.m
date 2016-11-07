//
//  SPMineInviteFriendsController.m
//  StandardizationPractice
//
//  Created by Baitianyu on 20/10/2016.
//  Copyright © 2016 Netease. All rights reserved.
//

#import "SPMineInviteFriendsController.h"
#import "HTControllerRouteInfo.h"
#import "HTControllerRouter.h"
#import "HTContainerViewController.h"
#import "UINavigationBar+HT.h"
#import "HTNavigationPanProtocol.h"
#import "UIViewController+HTRouter.h"
#import "UIViewController+SPNavigationBar.h"
#import "UIView+SPLoading.h"

@interface SPMineInviteFriendsController () <HTRouteTargetProtocol,
                                             HTContainerViewControllerProtocol,
                                             HTNavigationBackPanGestureProtocol>

@end

@implementation SPMineInviteFriendsController
@synthesize containerController;

#pragma mark - Router

+ (HTControllerRouterConfig*)configureRouter {
    HT_EXPORT();
    HTControllerRouterConfig *config = [[HTControllerRouterConfig alloc] initWithUrlPath:[self urlPath]];
    return config;
}

+ (NSString*)urlPath {
    return @"standardization://mine/invitefriends";
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
    @SPWeakSelf(self);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf.view sp_showLoadingError:^{
            [weakSelf.view sp_showLoading];
            usleep(2);
            [weakSelf.view sp_showLoadingEmpty];
        }];
    });
}

@end
