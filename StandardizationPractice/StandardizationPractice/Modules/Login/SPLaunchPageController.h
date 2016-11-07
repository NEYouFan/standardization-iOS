//
//  SPLaunchPageController.h
//  StandardizationPractice
//
//  Created by Baitianyu on 18/10/2016.
//  Copyright © 2016 Netease. All rights reserved.
//

#import "SPBaseViewController.h"

@class SPLaunchPageController;

@protocol SPLaunchPageControllerDelegate <NSObject>

@required
- (void)launchPageControllerDidDisappear:(SPLaunchPageController *)launchPageController;

@end

/**
 自动页面
 */
@interface SPLaunchPageController : SPBaseViewController

@property (nonatomic, weak) id<SPLaunchPageControllerDelegate> delegate;

@end
