//
//  UIView+SPLoading.h
//  StandardizationPractice
//
//  Created by Baitianyu on 21/10/2016.
//  Copyright © 2016 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SPLoadingErrorView.h"

typedef void (^SPRetryLoadingBlock)();
typedef void (^SPCompleteBlock)();

@interface UIView (SPLoading) <SPLoadingErrorDelegate>

/**
 显示 loading 状态，默认背景色为白色
 */
- (void)sp_showLoading;
- (void)sp_showLoadingWithBackgroundColor:(UIColor *)backgroundColor;
- (void)sp_hideLoading;
- (void)sp_hideLoading:(SPCompleteBlock)complete;

/**
 显示 loading empty 状态，默认背景色为白色
 */
- (void)sp_showLoadingEmpty;
- (void)sp_showLoadingEmptyWithBackgroundColor:(UIColor *)backgroundColor;
- (void)sp_hideLoadingEmpty;
- (void)sp_hideLoadingEmpty:(SPCompleteBlock)complete;

/**
 显示 loading error 状态，默认背景色为白色
 */
- (void)sp_showLoadingError:(SPRetryLoadingBlock)retry;
- (void)sp_showLoadingErrorWithBackgroundColor:(UIColor *)backgroundColor retryBlock:(SPRetryLoadingBlock)retry;
- (void)sp_hideLoadingError;
- (void)sp_hideLoadingError:(SPCompleteBlock)complete;

@end
