//
//  AppDelegate.h
//  StandardizationPractice
//
//  Created by Baitianyu on 18/10/2016.
//  Copyright © 2016 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

#define SPAPPDELEGATE() ((AppDelegate *)[[UIApplication sharedApplication] delegate])

@class HTNavigationController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) HTNavigationController *rootNavigationController;

@end

