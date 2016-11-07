//
//  UIViewController+SPNavigationBar.h
//  StandardizationPractice
//
//  Created by Baitianyu on 19/10/2016.
//  Copyright © 2016 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SPBaseViewController.h"

@interface SPBaseViewController (SPNavigationBar)

/**
 默认导航栏样式
 */
- (void)sp_applyDefaultNavigationBarStyle;

/**
 透明导航栏样式，白色状态栏
 */
- (void)sp_applyTransparentNavigationBarStyle;

/**
 透明导航栏，黑色状态栏
 */
- (void)sp_applyTransparentNavigationBarDarkStatus;

/**
 添加左侧返回键
 */
- (void)sp_addNavigationLeftBackItem;

/**
 添加设置按钮

 @return 设置 button
 */
- (UIButton *)sp_addNavigationRightSettingItem;

/**
 添加搜索框

 @return 搜索框
 */
- (UISearchBar *)sp_addNavigationSearchItem;


/**
 添加title左右还需要加一个view的情况

 @param title title
 @param image image

 @return 自定义的view
 */
- (UIView *)sp_addNavigationMidViewWithTitle:(NSString *)title image:(UIImage *)image;

/**
 添加右上角叉号
 */
- (UIButton *)sp_addNavigationRightCloseItem;

@end
