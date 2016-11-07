//
//  UIScrollView+MSControllerAssociation.h
//  HTUI
//
//  Created by Bai_tianyu on 9/11/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSPullToRefreshController.h"

/*!
 @category UIScrollView (MSControllerAssociation)
 
 @brief An UIScrollView Catogory to associate a MSPullToRefreshController to the UIScrollView.
 */
@interface UIScrollView (MSControllerAssociation)

/*!
 将一个 MSPullToRefreshController 关联到该 UIScrollView.
 
 @param controller 被关联的 MSPullToRefreshController.
 */
- (void)ht_setMSPullToRefreshController:(MSPullToRefreshController *)controller;

/*!
 获取与 UIScrollView 相关联的 MSPullToRefreshController.
 
 @return 与 UIScrollView 相关联的 MSPullToRefreshController；
         如果没有 MSPullToRefreshController 与该 UIScrollView 关联，返回 nil。
 */
- (id)ht_getMSPullToRefreshController;

/*!
 用户设置的与所有刷新功能无关的 ScrollView 的 contentInset，
 例如导航栏、标签栏、工具栏等固定控件占用的 Inset；
 用户需要清楚自己设置的 Inset(与刷新无关的 Inset)，
 并在管理 ScrollView 的 controller viewDidLoad: 方法中设置该值。
 
 @param originalContentInset the value to be set
 
 @warning 如果不进行任何设置，则使用默认值 {0,0,0,0}。
 为了避免系统默认导航栏和标签栏的影响，请自行设置
 */
- (void)ht_setOriginalContentInset:(UIEdgeInsets)originalContentInset;

@end