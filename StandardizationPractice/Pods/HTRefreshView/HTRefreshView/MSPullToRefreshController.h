//
//  MSPullToRefreshController.h
//
//  Created by John Wu on 3/5/12.
//  Modified by (Netease)Bai_tianyu on 9/15/15.
//  Copyright (c) 2012 TFM. All rights reserved.
//

/**************************||||-ABSTRACT-||||**********************************
 *
 *  This is the a generic pull-to-refresh library.
 *
 *  This library attempts to abstract away the core pull-
 *  to-refresh logic, and allow the users to implement custom
 *  views on top and update them at key points in the refresh cycle.
 *
 *  Hence, this class is NOT meant to be used directly. You
 *  are meant to write a wrapper which uses this class to implement
 *  your own pull-to-refresh solutions.
 *  
 *  Instead of overriding the delegate like most PTF libraries,
 *  we merely observe the contentOffset property of the scrollview
 *  using KVO.
 *
 *  This library allows refreshing in any direction and/or any combination
 *  of directions.
 *
 *  It is up to the user to inform the library when to end a refresh sequence
 *  for each direction.
 *
 *  Do NOT use a scrollview with a contentSize that is smaller than the frame.
 *
 *
 ******************************************************************************/

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "HTRefreshView.h"

/*!
 @typedef MSRefreshableDirections
 @brief Flags that determine the directions that can be engaged now.
 
 @constant MSRefreshableDirectionNone   No direction is refreshable.
 @constant MSRefreshableDirectionTop    Top is refreshable.
 @constant MSRefreshableDirectionLeft   Left is refreshable.
 @constant MSRefreshableDirectionBottom Bottom is refreshable.
 @constant MSRefreshableDirectionRight  Right is refreshable.
 */
typedef NS_ENUM(NSInteger, MSRefreshableDirections){
    /// No direction is refreshable.
    MSRefreshableDirectionNone   = 0,
    /// Top is refreshable.
    MSRefreshableDirectionTop    = 1 << 0,
    /// Left is refreshable.
    MSRefreshableDirectionLeft   = 1 << 1,
    /// Bottom is refreshable.
    MSRefreshableDirectionBottom = 1 << 2,
    /// Right is refreshable.
    MSRefreshableDirectionRight  = 1 << 3
};

/*!
 @typedef MSRefreshingDirections
 @brief Flags that determine the directions that are currently refreshing.
 
 @constant MSRefreshingDirectionNone   No direction is currently refreshing.
 @constant MSRefreshingDirectionTop    Top is currently refreshing.
 @constant MSRefreshingDirectionLeft   Left is currently refreshing.
 @constant MSRefreshingDirectionBottom Bottom is currently refreshing.
 @constant MSRefreshingDirectionRight  Right is currently refreshing.
 */
typedef NS_ENUM(NSInteger, MSRefreshingDirections) {
    /// No direction is currently refreshing.
    MSRefreshingDirectionNone   = 0,
    /// Top is currently refreshing.
    MSRefreshingDirectionTop    = 1 << 0,
    /// Left is currently refreshing.
    MSRefreshingDirectionLeft   = 1 << 1,
    /// Bottom is currently refreshing.
    MSRefreshingDirectionBottom = 1 << 2,
    /// Right is currently refreshing.
    MSRefreshingDirectionRight  = 1 << 3
};

/*!
 @typedef MSRefreshDirection
 @brief Simple enum that specifies the direction.
        This direction is related to delegates'.
 
 @constant MSRefreshDirectionTop    Top direction.
 @constant MSRefreshDirectionLeft   Left direction.
 @constant MSRefreshDirectionBottom Bottom direction.
 @constant MSRefreshDirectionRight  Right direction.
 */
typedef NS_ENUM(NSInteger, MSRefreshDirection) {
    /// Top direction.
    MSRefreshDirectionTop = 0,
    /// Left direction.
    MSRefreshDirectionLeft,
    /// Bottom direction.
    MSRefreshDirectionBottom,
    /// Right direction.
    MSRefreshDirectionRight
};

/*!
 @typedef MSRefreshMode
 @brief 触发刷新操作的模式(此处所述的刷新仅指设置 refreshingInset 动作，非业务刷新，下同)
 
 @constant MSDoNotTriggerRefresh    content 滚动到边缘后无需触发任何刷新操作
 @constant MSDraggingTriggerRefresh content 滚动到边缘后，需要拖拽才能触发刷新操作
 */
typedef NS_ENUM(NSInteger, MSRefreshMode) {
    /// ScrollView's content 滚动到边缘后无需触发任何刷新操作
    MSDoNotTriggerRefresh = 0,
    /// ScrollView's content 滚动到边缘后，需要拖拽才能触发刷新操作
    MSDraggingTriggerRefresh
};


@protocol MSPullToRefreshDelegate;

/*!
 @class MSPullToRefreshController
 @superclass Superclass:NSObject

 @brief The main Class of MSPullToRefresh
 */
#warning 如果MSPullToRefreshController与UIScrollView不是一对一而是多对一的话，是否会好一点？仅个人看法.
@interface MSPullToRefreshController : NSObject

/// The ScrollView to be observed.
//TODO： 强引用，因为需要监听 ScrollView 的 contentOffset
#warning ???? 引用关系是怎样的？从现在代码看，HTRefreshView持有MSController, MSController弱引用ScrollView, ScrollView有可能持有HTRefreshView; HTRefreshView是有UIScrollView的弱引用. 这里是weak可能是因为ScrollView有可能持有HTRefreshView作为子控件.
#warning 核心关系: MSController监控UIScrollView的变化，然后通知到自己的delegate也就是HTRefreshView. 
#warning HTRefreshView有两层作用， 1 作为MSController的Delegate，给予配置信息并接收回调; 2 作为展示的View（也可以添加到UIScrollView视图层级中）
@property (nonatomic, weak) UIScrollView *scrollView;

/*!
 Flags to indicate where we are in the refresh sequence.
 Further more, directions that are currently refreshable.
 */
@property (nonatomic, assign) MSRefreshableDirections refreshableDirections;

/// Delegates to receive callbacks on different stages of a refresh cycle.
//@property (nonatomic, strong) NSMapTable *delegates;

/*!
 Flags to indicate where we are in the refresh sequence.
 Further more, directions that are currently refreshing.
 */
@property (nonatomic, assign) MSRefreshingDirections refreshingDirections;

/*!
 触发刷新的模式(主要用于底部和右侧)，当底部和右侧不采用拖拽刷新时，
 无需在 MSPullToRefreshController 中设置 contentInset。
 有两种触发刷新的模式，@see MSRefreshMode
 */
#warning 尽量避免参数传递用数组
@property (nonatomic, strong) NSMutableArray *refreshMode;

/*!
 The only constructor you should use, pass in the scrollview to be observed 
 and the delegate to receive call backs.
 
 @param scrollView The ScrollView to be observed.
 @param delegate   Delegate to receive callbacks on different stages of the refresh cycle.
 @param direction  Direction that delegate expect to enable refresh.
 
 @return A new MSPullToRefreshController Object.
 */
- (id)initWithScrollView:(UIScrollView *)scrollView
                delegate:(id<MSPullToRefreshDelegate>)delegate
               direction:(MSRefreshDirection)direction;

/*!
 Add a delegate to enable the given direction's refresh.
 
 @param delegate  New delegate to be added to MSRefreshController.
 @param direction Direction that delegate expect to enable refresh.
 */
- (void)setDelegate:(id<MSPullToRefreshDelegate>)delegate withDirection:(MSRefreshDirection)direction;

/*!
 *  get delegate in direction
 *
 *  @param direction
 *
 *  @return delegate
 */
- (id<MSPullToRefreshDelegate>)delegateWithDirection:(MSRefreshDirection)direction;

/*!
 Call this function with a direction to end the refresh sequence in that direction.
 With or without animation, on your choice.
 
 @param direction The direction to end the refresh sequence.
 @param animated  End the refresh sequence with or without animation.
 */
- (void)finishRefreshingDirection:(MSRefreshDirection)direction animated:(BOOL)animated;

/*!
 Calls the above with animated = NO
 
 @param direction The direction to end the refresh sequence.
 */
- (void)finishRefreshingDirection:(MSRefreshDirection)direction;

/*!
 Programmatically start a refresh in the given direction, animated or not.
 
 @param direction The direction to start the refresh.
 @param animated  Start the refresh animated or not.
 @param delegate  Delegate to receive callbacks on different stages of the refresh cycle.
 */
- (void)startRefreshingDirection:(MSRefreshDirection)direction
                        delegate:(id<MSPullToRefreshDelegate>)delegate
                        animated:(BOOL)animated;

/*!
 Calls the above with animated = NO
 
 @param direction The direction to start the refresh.
 @param delegate  Delegate to receive callbacks on different stages of the refresh cycle.
 */
- (void)startRefreshingDirection:(MSRefreshDirection)direction
                        delegate:(id<MSPullToRefreshDelegate>)delegate;


/*!
 设置给定方向的 refreshMode
 
 @param loadMoreMode The refreshView's loadMore mode.
 @param direction    The specified direction.
 */
- (void)setRefreshMode:(HTTriggerLoadMoreMode)loadMoreMode
             direction:(HTRefreshDirection)direction;

@end // Interface MSPullToRefreshController



/*!
 @protocol MSPullToRefreshDelegate

 @brief Callbacks on different stages of the refresh cycle.
 */
@protocol MSPullToRefreshDelegate <NSObject>

@required

/*!
 Asks the delegate whether the give direction is refreshable.
 
 是否支持刷新.
 
 @param controller The MSPullToRefreshController Object who asks the delegate.
 @param direction  The direction to be asked if refreshable.
 
 @return YES if the direction is refreshable; 
         NO if the direction is not refreshable.
 */
- (BOOL)pullToRefreshController:(MSPullToRefreshController *)controller
          canRefreshInDirection:(MSRefreshDirection)direction;

/*!
 Inset threshold to engage refresh

 拉到何处开始刷新.
 
 @param controller The MSPullToRefreshController Object who asks the delegate.
 @param direction  The direction to be asked for the threshold.
 
 @return The threshold to engage refresh on the give direction.
 */
- (CGFloat)pullToRefreshController:(MSPullToRefreshController *)controller
      refreshableInsetForDirection:(MSRefreshDirection) direction;

/*!
 Inset that the direction retracts back to after refresh started
 
 真实刷新开始后，scrollView回到哪个位置.
 
 @param controller The MSPullToRefreshController Object who asks the delegate.
 @param direction  The direction to be asked for the retract back inset.
 
 @return Inset that the direction retracts back to after refresh started.
 */
- (CGFloat)pullToRefreshController:(MSPullToRefreshController *)controller
       refreshingInsetForDirection:(MSRefreshDirection)direction;

/*!
 针对底部和右侧的加载更多功能。
 
 当 ScrollView's content 滚动到底部或右侧边缘时，如还可以加载更多信息，
 一般会有提示信息提示用户有更多信息可被加载，此方法返回显示提示信息的 View 的高度，
 当然，对于右侧则为宽度。

 @param controller The MSPullToRefreshController object who asks the delegate
 @param direction  The direction to be asked for the prompting inset.
 
 @return 显示加载更多提示信息的 View 的高度或宽度。
 */
- (CGFloat)pullToRefreshController:(MSPullToRefreshController *)controller
        promptingInsetForDirection:(MSRefreshDirection)direction;

@optional

/*!
 Informs the delegate that lifting your finger will trigger a refresh
 in that direction. This is only called when you cross the refreshable
 offset defined in the respective MSInflectionOffsets.
 
 通知代理能够触发刷新.
 
 @param controller The MSPullToRefreshController Object who call this callback.
 @param direction  The direction whose refresh stage changed.
 */
- (void)pullToRefreshController:(MSPullToRefreshController *)controller
      canEngageRefreshDirection:(MSRefreshDirection)direction;

/*!
 Informs the delegate that lifting your finger will NOT trigger a refresh
 in that direction. This is only called when you cross the refreshable
 offset defined in the respective MSInflectionOffsets.
 
 @param controller The MSPullToRefreshController Object who call this callback.
 @param direction  The direction whose refresh stage changed.
 */

#warning 这个回调的意义在哪里？
- (void)pullToRefreshController:(MSPullToRefreshController *)controller
   didDisengageRefreshDirection:(MSRefreshDirection) direction;

/*!
 Informs the delegate that refresh sequence has been started by the user
 in the specified direction. A good place to start any async work.
 
 触发刷新.
 
 @param controller The MSPullToRefreshController Object who call this callback.
 @param direction  The direction whose refresh stage changed.
 */
- (void)pullToRefreshController:(MSPullToRefreshController *)controller
      didEngageRefreshDirection:(MSRefreshDirection)direction;

/*!
 Informs the delegate that refresh sequence will be finished by the user
 in the specified direction. A good place to recover the refresh view.
 
 将要结束刷新.
 
 @param controller The MSPullToRefreshController Object who call this callback.
 @param direction  The direction whose refresh stage changed.
 */
- (void)pullToRefreshController:(MSPullToRefreshController *)controller
        willEndRefreshDirection:(MSRefreshDirection)direction;

/*!
 Informs the delegate that refresh sequence has been finished by the user
 in the specified direction. A good place to recover the refresh view.
 This is not the same as upper method, perhaps it will end, but may not did end.
 For example,when you hold the screen, did end will not happen.
 
 已经结束刷新.
 
 @param controller The MSPullToRefreshController Object who call this callback.
 @param direction  The direction whose refresh stage changed.
 */
- (void)pullToRefreshController:(MSPullToRefreshController *)controller
         didEndRefreshDirection:(MSRefreshDirection)direction;

/*!
 Informs the delegate that the scrollView's loadmore prompt information
 is going to be displayed in the specified direction. Only for bottom 
 and right direction refresh now. Not applied to top and left refresh.
 
 LoadMore, 达到刷新边缘.
 
 @param controller The MSPullToRefreshController Object who call this callback.
 @param direction  The direction whose refresh stage changed.
 */
- (void)pullToRefreshController:(MSPullToRefreshController *)controller
          didReachEdgeDirection:(MSRefreshDirection)direction;

/*!
 当 ScrollView 可滚动区域滚动到边缘后，继续拖拽 ScrollView 的位移改变通知。
 
 @param percent   当前拖拽的位移与 refreshableInset 的比例。
 @param offset    当前拖拽的位移的实际值。
 @param direction The direction whose dragging percent changed.
 */
- (void)pullToRefreshController:(MSPullToRefreshController *)controller
          refreshPercentChanged:(CGFloat)percent
                         offset:(CGFloat)offset
                      direction:(MSRefreshDirection)direction;


@end // protocol MSPullToRefreshDelegate