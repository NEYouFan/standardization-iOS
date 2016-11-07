//
//  HTBottomRightRefreshView.h
//  HTUI
//
//  Created by Bai_tianyu on 9/10/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTRefreshView.h"
#import "UIScrollView+MSControllerAssociation.h"

/*!
 @class HTBottomRightRefreshView
 @superclass Superclass:HTRefreshView
 
 @brief 本类提供 ScrollView 底部和右部加载更多功能。
 该类可被继承，子类可自定义 RefreshView；此外，处理某事件只需重写相应的方法即可。
 */
@interface HTBottomRightRefreshView : HTRefreshView

/*!
 当前是否正在刷新
 */
@property (nonatomic, assign) BOOL isRefreshing;

/*!
 显示加载更多提示信息的 View 的高度或宽度。
 当滑动到 ScrollView 的底部或右侧边缘时，如还可以加载更多信息，会有提示信息提示用户有更多信息可被加载，
 当你不需要显示提示信息时，将其设置为0即可。
 
 @warning 如果不进行设置并且子类未实现 promptingInset 方法，则采用默认值:

 HTRefreshDirectionTop:    不适用，使用0值
 
 HTRefreshDirectionLeft:   不适用，使用0值
 
 HTRefreshDirectionBottom: 默认 HTRefreshView 的高度
 
 HTRefreshDirectionRight:  默认 HTRefreshView 的宽度
 */
@property (nonatomic, assign) CGFloat promptingInset;

/*!
 触发加载更多操作的模式
 本控件提供三种操作模式.
 @see HTTriggerLoadMoreMode
 */
@property (nonatomic, assign) HTTriggerLoadMoreMode triggerLoadMoreMode;

/*!
 是否始终显示 RefreshView
 
 若 ScrollView 的 contentSize 小于当前可显示区域(由 originalContentInset 计算可得)，
 则默认自动隐藏 RefreshView，此属性可设置始终显示 RefreshView.
 */
@property (nonatomic, assign) BOOL alwaysShowRefreshView;

/*!
 是否隐藏 RefreshView

 HTBottomRightRefreshView 为用户管理 conentSize 小于 scrollView.size 时 RefreshView 是否显示。
 当用户需隐藏 RefreshView 时，需将该选项设为 YES，而不是直接设置 hidden 属性
 */
@property (nonatomic, assign) BOOL hiddenRefresh;


@end