//
//  HTRefreshView.h
//  HTUI
//
//  Created by Bai_tianyu on 9/14/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MSPullToRefreshController;
@class HTRefreshView;


#ifndef __DEBUG
#define __DEBUG
#endif

/*!
 @typedef HTRefreshDirection
 @brief Simple enum that specifies the refresh direction related to HTRefreshView.
 
 @constant HTRefreshDirectionTop    Top direction.
 @constant HTRefreshDirectionLeft   Left direction.
 @constant HTRefreshDirectionBottom Bottom direction.
 @constant HTRefreshDirectionRight  Right direction.
 */
typedef NS_ENUM(NSInteger, HTRefreshDirection) {
    /// Top direction.
    HTRefreshDirectionTop = 0,
    /// Left direction.
    HTRefreshDirectionLeft,
    /// Bottom direction.
    HTRefreshDirectionBottom,
    /// Right direction.
    HTRefreshDirectionRight,
};

/*!
 @typedef HTTriggerLoadMoreMode
 @brief 触发刷新操作的模式
 
 @constant HTTriggerLoadMoreModeAutoTrigger     ScrollView 的可滚动区域滚动到边缘后自动触发刷新操作
 @constant HTTriggerLoadMoreModeDoNotTrigger    ScrollView 的可滚动区域滚动到边缘后无需 HTRefreshView 触发刷新操作，
                                     例如由用户点击某Button 触发刷新
 @constant HTTriggerLoadMoreModeDraggingTrigger ScrollView 的可滚动区域滚动到边缘后，需要拖拽才能触发刷新操作
 */
typedef NS_ENUM(NSInteger, HTTriggerLoadMoreMode) {
    /// ScrollView 的可滚动区域滚动到边缘后自动触发刷新
    HTTriggerLoadMoreModeAutoTrigger = 0,
    /// ScrollView 的可滚动区域滚动到边缘后无需 HTRefreshView 触发刷新操作，例如刷新由用户点击某 Button 触发
    HTTriggerLoadMoreModeDoNotTrigger,
    /// ScrollView 的可滚动区域滚动到边缘后，需要拖拽才能触发刷新操作
    HTTriggerLoadMoreModeDraggingTrigger
};

/*!
 @typedef HTRefreshState
 @brief Different states of the refresh cycle
 
 @constant HTRefreshStateCanEngageRefresh    Lifting your finger will trigger a refresh
 @constant HTRefreshStateDidDisengageRefresh Lifting your finger will NOT trigger a refresh because you drag
                                 the scrollview back to the refreshable inset
 @constant HTRefreshStateWillEndRefresh      Refresh sequence will be ended.
 @constant HTRefreshStateDidEngageRefresh    Refresh sequence has been started
 */
typedef NS_ENUM(NSInteger, HTRefreshState) {
    /// Lifting your finger will trigger a refresh
    HTRefreshStateCanEngageRefresh,
    /*!
     Lifting your finger will NOT trigger a refresh because you drag
     the scrollview back to the refreshable inset
     */
    HTRefreshStateDidDisengageRefresh,
    /// Refresh sequence has been started
    HTRefreshStateDidEngageRefresh,
    /// Refresh will end.
    HTRefreshStateWillEndRefresh,
    /// Refresh is end
    HTRefreshStateDidEndRefresh
};


/*!
 刷新时的回调代码块类型
 
 @param view 执行代码块的 HTRefreshView
 */
typedef void (^refreshHandler)(HTRefreshView *view);



@protocol HTRefreshViewDelegate <NSObject>

@optional

/*!
 当 ScrollView 可滚动区域滚动到边缘后，继续拖拽 ScrollView 的位移改变通知。
 
 @param percent   当前拖拽的位移与 refreshableInset 的比例。
 @param offset    当前拖拽的位移的实际值。
 @param direction 发生事件的刷新位置。
 */
- (void)refreshPercentChanged:(CGFloat)percent
                       offset:(CGFloat)offset
                    direction:(HTRefreshDirection)direction;

/*!
 Callbacks for RefreshView when refresh state changed.
 
 @param state 当前刷新状态。
 */
- (void)refreshStateChanged:(HTRefreshState)state;

/*!
 获取触发刷新的 Inset 门限。
 当 ScrollView 可滚动区域滚动到边缘后，只有拖拽 ScrollView 的距离超过此 Inset 门限时才可触发刷新。

 @warning 如果子类不重写该方法，将会采用默认值。
          HTRefreshDirectionTop:    默认 HTRefreshView 的高度
          HTRefreshDirectionLeft:   默认 HTRefreshView 的宽度
          HTRefreshDirectionBottom: 默认 ScrollView 的高度
          HTRefreshDirectionRight:  默认 ScrollView 的宽度
 
 @return 触发刷新的 Inset 门限
 */
- (CGFloat)refreshableInset;

/*!
 刷新时 ScrollView 应该退回到此 Inset，
 相对于 HTRefreshView 设置 contentInset 之前的 ScrollView's contentInset。
 
 @warning 如果子类不重写该方法，将会采用默认值。
 
 HTRefreshDirectionTop:    默认 HTRefreshView 的高度
 
 HTRefreshDirectionLeft:   默认 HTRefreshView 的宽度
 
 HTRefreshDirectionBottom: 默认 0
 
 HTRefreshDirectionRight:  默认 0
 
 @return 刷新时 ScrollView 应退回的位置
 */
- (CGFloat)refreshingInset;

/*!
 显示加载更多提示信息的 View 的高度或宽度。
 当滑动到 ScrollView 的底部或右侧边缘时，如还可以加载更多信息，会有提示信息提示用户有更多信息可被加载，
 当你不需要显示提示信息时，将其设置为0即可。
 
 @warning 若子类未实现该方法，则初始化 RefreshView 时设置为默认值:
 
 HTRefreshDirectionTop:    不适用，使用0值
 
 HTRefreshDirectionLeft:   不适用，使用0值
 
 HTRefreshDirectionBottom: 默认 HTRefreshView 的高度
 
 HTRefreshDirectionRight:  默认 HTRefreshView 的宽度
 
 @return 提示信息的 View 高度/宽度
 */
- (CGFloat)promptingInfoInset;

@end



/*!
 @class HTRefreshView
 @brief Base class of HTTopLeftRefreshView and HTBottomRightRefreshView；
        本类遵循 UIScrollViewDelegate 和 HTRefreshViewDelegate 协议，子类可选择的实现部分方法。
 
 @superclass SuperClass:UIView
 */
#warning HTRefreshView似乎并没有设置为scrollView的Delegate.
#warning HTRefreshView为什么没有设置成为MSPullToRefreshDelegate
#warning HTRefreshViewDelegate -> HTRefreshViewProtocol
@interface HTRefreshView : UIView <UIScrollViewDelegate, HTRefreshViewDelegate>

/*!
 标明为哪个 UIScrollView 提供刷新功能
 
 @warning: RefreshView will be added to subViews' Tree of scrollView, so scrollView will 
           strongly reference RefreshView. As a consequence, we use weak referenct to scrollView
           here.
 */
#warning 不可更改的建议设置为readonly. 去掉基类后修正.
@property (nonatomic, weak) UIScrollView *scrollView;

/*!
 启用/禁用刷新功能
 YES：如果启用刷新功能(默认值)；
 NO：如果禁用刷新功能(若需禁止需自己设置)；
 */
@property (nonatomic, assign) BOOL refreshEnabled;

/*!
 刷新时回调的代码块
 */
@property (nonatomic, copy) refreshHandler refreshingHandler;

/*!
 HTRefreshView 的刷新方向.
 */
@property (nonatomic, assign) HTRefreshDirection refreshDirection;

/*!
 MSPullToRefreshController Object
 */
#warning 不太分得清哪些是外部需要关心的接口. msRefreshController似乎外部和自己重写RefreshView都不需要关心. 去掉基类后修正.
@property (nonatomic, strong) MSPullToRefreshController *msRefreshController;

/*!
 表示 HTRefreshView 是否需要跟随 ScrollView 滚动
 */
@property (nonatomic, assign) BOOL followScrollView;

/*!
 若 followScrollView 为 YES，该值表示 HTRefreshView 与 ScrollView 边缘的距离；默认值为 0
 若 followScrollView 为 NO，该值无意义。
 */
//#warning 子类需要重写以满足动态调整 followDistance
@property (nonatomic, assign) CGFloat followDistance;

/*!
 用户设置的与所有刷新功能无关的 ScrollView 的 contentInset，
 例如导航栏、标签栏、工具栏等固定控件占用的 Inset；
 用户需要清楚自己设置的 Inset(与刷新无关的 Inset)，
 用户通过 ScrollView 的 setOriginalContentInset 方法设置该值。
 
 @warning 如果不进行任何设置，则使用默认值 {0,0,0,0}。
 */
@property (nonatomic, assign) UIEdgeInsets originalContentInset;

/*!
 是否设置了 originalContentInset
 */
@property (nonatomic, assign) BOOL originalContentInsetSetted;


/*!
 初始化
 
 @param scrollView 标明添加刷新功能到哪个 UIScrollView。
 @param direction  RefreshView 的位置，HTRefreshView 有上侧和左侧两种，其他不合法。
 @param follow     RefreshView 是否需要跟随着 ScrollView 一起滚动。
 YES:需要一起滚动；
 NO:不需要一起滚动。
 
 @warning 如果设置 follow 为 NO，需要自己控制 HTRefreshView 的 frame。
 */
- (id)initWithScrollView:(UIScrollView *)scrollView
               direction:(HTRefreshDirection)direction
        followScrollView:(BOOL)follow;

/*!
 初始化
 
 @param scrollView 标明添加刷新功能到哪个 UIScrollView。
 @param direction  RefreshView 的位置，HTRefreshView 有底部和右部两种，其他不合法。
 @param follow     RefreshView 是否需要跟随着 ScrollView 一起滚动。
 YES:需要一起滚动；
 NO:不需要一起滚动。
 @param distance   若 follow 为 YES，该值表示 HTRefreshView 与 ScrollView 边缘的距离；默认值为 0
 若 follow 为 NO，该值无意义。
 
 @warning 如果设置 follow 为 NO，需要自己控制 HTRefreshView 的 frame。
 */
- (id)initWithScrollView:(UIScrollView *)scrollView
               direction:(HTRefreshDirection)direction
        followScrollView:(BOOL)follow
          followDistance:(CGFloat)distance;

/*!
 添加子View到 HTRefreshView。
 默认 HTRefreshView 默认为空白View，如需自定义 HTRefreshView 请在子类中重写此方法，
 并在此方法中添加 HTRefreshView 的子View，即可实现自定义的 HTRefreshView。
 */
- (void)loadSubViews;

/*!
 添加刷新时的回调代码块
 
 @param block 刷新时回调的代码块
 */
- (void)addRefreshingHandler:(refreshHandler)block;

/*!
 主动触发刷新
 
 @param animated 是否采用动画开始刷新
 */
#warning 使用场景？程序自动刷新，一般这类交互比较少.
- (void)startRefresh:(BOOL)animated;

/*!
 结束刷新
 
 @param animated 是否采用动画结束刷新
 */
- (void)endRefresh:(BOOL)animated;

@end