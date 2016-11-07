//
//  HTTopLeftRefreshView.h
//  HTUI
//
//  Created by Bai_tianyu on 9/10/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "HTRefreshView.h"
#import "UIScrollView+MSControllerAssociation.h"

@protocol MSPullToRefreshDelegate;

/*!
 @class HTTopLeftRefreshView
 @superclass Superclass:HTRefreshView
 
 @brief HTTopLeftRefreshView provide top and
 本类提供 ScrollView 顶部刷新和左侧刷新功能。该类仅支持 下拉/左拉 改变刷新状态；
        该类可被继承，子类可自定义 RefreshView；此外，处理某事件只需重写相应的方法即可。
 */
#warning HTTopLeftRefreshView 的 位置大小信息是如何指定的？应该在何时设置？结论：bounds需要设置.
@interface HTTopLeftRefreshView : HTRefreshView

@end