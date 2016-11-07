//
//  HTPageControllerView.h
//  HTUIDemo
//
//  Created by zp on 15/10/11.
//  Copyright © 2015年 HT. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HTPageControllerView;

/*!
 *  提供HTPageControllerView中Controller信息
 */
@protocol HTPageControllerViewDataSource<NSObject>

@required
- (NSUInteger)numberOfControllersInPageControllerView;

/*!
 *  返回index处的Controller
 *
 *  @param pageControllerView pageControllerView
 *  @param index              page index
 *
 *  @return controller实例
 */
@required
- (UIViewController*)pageControllerView:(HTPageControllerView*)pageControllerView viewControllerForIndex:(NSUInteger)index;

/*!
 *  预加载的Controller的个数，这些Controller的view都会加到scrollview中。默认3个
 *
 *  @return 预加载的Controller的个数
 */
@optional
- (NSUInteger)preloadControllerCountInPageControllerView:(HTPageControllerView*)pageControllerView;

/*!
 *  内存中最大持有的Controller的个数。默认6个
 *
 *  @return 内存中最大持有的Controller的个数
 */
- (NSUInteger)maxCachedControllerCountInpageControllerView:(HTPageControllerView*)pageControllerView;;

/*!
 *  HTPageControllerView不会在一开始就加载所有的ViewController，此时先使用placeHolder占位。
 *
 *  @param pageControllerView
 *  @param index
 *
 *  @return placeHolderView
 */
@optional
- (UIView*)pageControllerView:(HTPageControllerView*)pageControllerView placeHolderViewForIndex:(NSUInteger)index;
@end

@protocol HTPageControllerViewDelegate<NSObject>
@optional
- (void)pageControllerViewDidScroll:(HTPageControllerView *)pageControllerView;

/*!
 *  当由于用户交互导致selected变化，会触发这个回调。如果是程序控制的selected index的变化，不会触发这个回调。
 *
 *  @param index 当前显示的index
 */
- (void)pageControllerViewDidSelectedIndex:(NSUInteger)index;
@end

/*!
 * page ScrollView包装多个ViewController控件,使用initWithFrame创建实例，以此来传入宽度，保证首次进入可以滚动到指定index的pageview
 */
@interface HTPageControllerView : UIScrollView

@property (nonatomic, weak) id<HTPageControllerViewDataSource> pageDataSource;
@property (nonatomic, weak) id<HTPageControllerViewDelegate> pageDelegate;

/*!
 *  当前处于第几个page
 */
@property (nonatomic, readonly, assign) NSInteger currentPageIndex;

/*!
 *  返回index处的controller，如果index处Controller还没有创建，或者已经销毁，那么返回nil
 *
 *  @param index
 *
 *  @return 
 */
- (UIViewController*)pageControllerView:(NSUInteger)index;

/*!
 *  移动到第一个page
 *
 *  @param index 
 *  @param animated
 */
- (void)scrollToPageIndex:(NSUInteger)index animated:(BOOL)animated;

/*!
 *  使用HTPageControllerView的ViewController需要将自身的appear/disappear事件传递出来，方便HTPageControllerView做一些优化
 *
 *  @param animated
 */
- (void)viewWillAppear:(BOOL)animated;

/*!
 *  使用HTPageControllerView的ViewController需要将自身的appear/disappear事件传递出来，方便HTPageControllerView做一些优化
 *
 *  @param animated
 */
- (void)viewDidAppear:(BOOL)animated;

/*!
 *  使用HTPageControllerView的ViewController需要将自身的appear/disappear事件传递出来，方便HTPageControllerView做一些优化
 *
 *  @param animated
 */
- (void)viewWillDisappear:(BOOL)animated;

/*!
 *  使用HTPageControllerView的ViewController需要将自身的appear/disappear事件传递出来，方便HTPageControllerView做一些优化
 *
 *  @param animated
 */
- (void)viewDidDisappear:(BOOL)animated;

@end
