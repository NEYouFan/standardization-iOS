//
//  SPBaseViewController.h
//  StandardizationPractice
//
//  Created by Baitianyu on 18/10/2016.
//  Copyright © 2016 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 状态栏样式

 - SPStatusBarStyleInvalid:      无效
 - SPStatusBarStyleDefault:      默认样式：黑色
 - SPStatusBarStyleLightContent: 白色
 */
typedef NS_ENUM(NSInteger, SPStatusBarStyle) {
    SPStatusBarStyleInvalid = 0,
    SPStatusBarStyleDefault,
    SPStatusBarStyleLightContent,
};

@class HTBaseRequest;

@interface SPBaseViewController : UIViewController

@property (nonatomic, assign) SPStatusBarStyle statusBarStyle;

- (void)cancelRequestWhenControllerDealloc:(HTBaseRequest *)request;

- (void)clearRequests;

@end
