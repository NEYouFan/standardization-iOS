//
//  HTSegmentsView.h
//  HTUIDemo
//
//  Created by zp on 15/9/6.
//  Copyright (c) 2015年 HT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTSegmentsCellView.h"
#import "HTSegmentsViewAnimator.h"

#warning 分头文件
@class HTSegmentsView;

/*!
 *  HTSegmentsView可以用来做一集单选的控件，譬如tabbar，譬如 scroll tabbar，switch button等。
 *  他支持切换选中状态的自定义动画。支持自定义方式布局，默认提供水平和垂直方式布局。
 *  
 *  HTSegmentsView中的控件称之为HTSegmentsCellView，他负责自身显示，选中状态动画切换。
 *
 *  HTSegmentsViewDatasource用户告知HTSegmentsView内部Cell的个数，每个Cell的宽高。
 *
 *  当内部Cell点击的时候，回调HTSegmentsViewDelegate
 *
 *  选中状态切换的时候，往往存在需要在HTSegmentsView全局移动的动画，这个动画由HTSegmentsViewAnimator驱动。
 *
 *  @warning HTSegmentsView不提供对HTSegmentsCellView的缓存。
 */

/*!
 *  类似于UITableviewDataSource，他控制Cell个数，构造Cell，返回每个Cell的尺寸。
 */
@protocol HTSegmentsViewDatasource <NSObject>

/*!
 *  返回Cell个数，这些HTSegmentsCellView会一次性全部构造出来
 *
 *  @param segmentsView
 *
 *  @return Cell个数
 */
@required
- (NSUInteger)numberOfCellsInSegementsView:(HTSegmentsView*)segmentsView;


/*!
 *  返回index处的HTSegmentsCellView
 *
 *  @param segmentsView
 *  @param index
 *
 *  @return HTSegmentsCellView
 */
@required
- (HTSegmentsCellView*)segmentsView:(HTSegmentsView*)segmentsView cellForIndex:(NSUInteger)index;

/*!
 *  返回每个控件的尺寸。HTSegmentsView是基于UIScrollView实现，所以此接口返回的Size会影响HTSegmentsView的content size，如果需要禁用某个方向的滚动，建议此处返回合适的尺寸，例如使用HTHorizontalSegmentsView时，此接口返回的CGSize的height需要设置成与HTSegmentsView的高度相等；使用HTVerticalSegmentsView时，此接口返回的CGSize的width需要设置成与HTSegmentsView的宽度相等。
 *
 *  @param segmentsView
 *  @param index
 *
 *  @return Cell的尺寸
 */
@required
- (CGSize)segmentsView:(HTSegmentsView*)segmentsView cellSizeForIndex:(NSUInteger)index;

/*!
 *  返回每个控件内容的尺寸，控件内容尺寸一般小于控件尺寸
 *
 *  @param segmentsView
 *  @param index
 *
 *  @return Cell内容的尺寸
 */
@optional
- (CGRect)segmentsView:(HTSegmentsView*)segmentsView cellContentRectForIndex:(NSUInteger)index;

@end

/*!
 *  Selected cell切换的时候回调
 */
@protocol HTSegmentsViewDelegate <NSObject>

/*!
 *  用于判断SegmentsView中的某个Cell能不能相应点击
 *
 *  @param segmentsView
 *  @param index
 *
 *  @return YES:能点击，否则不能
 */
- (BOOL)segmentsView:(HTSegmentsView*)segmentsView shouldSelectedAtIndex:(NSUInteger)index;

/*!
 *  当由于用户交互行为导致的selected index发生变化，会触发这个回调。通过设置设置的selected index，不会触发这个回调。
 *
 *  @param segmentsView
 *  @param index
 */
- (void)segmentsView:(HTSegmentsView*)segmentsView didSelectedAtIndex:(NSUInteger)index;

@end




/*!
 *  HTSegmentsView基类，他不负责Cell的排版
 */
@interface HTSegmentsView : UIScrollView

/*!
 *  Cell的集合，在传入datasoure之后，调用reloadData，会得到最新的Cells
 */
@property (nonatomic, readonly, strong) NSArray *segmentCells;

/*!
 *  获取当前选中的cell的index，默认是-1
 */
@property (nonatomic, readonly, assign) NSInteger selectedIndex;

/*!
 *  自动居中当前选中的Cell
 */
@property (nonatomic, assign) BOOL needAdjustToCenter;

/*!
 *  dataSource
 */
@property (nonatomic, weak) id<HTSegmentsViewDatasource> segmentsDataSource;

/*!
 *  delegate
 */
@property (nonatomic, weak) id<HTSegmentsViewDelegate> segmentsDelegate;

/*!
 *  用于全局动画的Animator
 */
@property (nonatomic, strong) HTSegmentsViewAnimator *animator;


/*!
 *  带有默认选择状态的构造函数
 *  @param selectedIndex 默认的选中索引
 */
- (instancetype)initWithSelectedIndex:(NSInteger)selectedIndex;

/*!
 *  重新加载
 */
- (void)reloadData;

/*!
 *  调用switch动画，注意，不管percent是都少，他都不影响相关Cell的selected状态。
 *
 *  @param fromIndex   如果fromIndex大于或者segmentCells.count，则忽略这次调用
 *  @param toIndex 目标index
 *  @param percent 移动的百分比
 */
- (void)moveFrom:(NSUInteger)fromIndex to:(NSUInteger)toIndex percent:(CGFloat)percent;

/*!
 *  主动设置选中cell。
 *  @warning:通过程序主动设置的selected index，不会触发delegate回调
 *
 *  @param index    选中的index
 *  @param animated 切换到selected状态是否需要动画
 */
- (void)setSelectedIndex:(NSUInteger)index animated:(BOOL)animated;
@end

/*!
 *  水平布局内部的Cell
 */
@interface HTHorizontalSegmentsView : HTSegmentsView
@end

/*!
 *  垂直布局的Cell
 */
@interface HTVerticalSegmentsView : HTSegmentsView
@end;

typedef void (^labelConfiguration)(UILabel*);

/*!
 *  一个Helper工具类，他接收一个字符串数组，会生成相应Label作为Cell。修改HTStringToLabelDataSource的某些属性，譬如CellWidth，需要调用SegmentsView的reload函数。
 */
@interface HTStringToLabelDataSource : NSObject<HTSegmentsViewDatasource>

/*!
 *  每个Cell的宽度
 */
@property (nonatomic, assign) CGFloat cellWidth;

/*!
 *  每个Cell的高度
 */
@property (nonatomic, assign) CGFloat cellHeight;

/*!
 *  选中状态字体大小
 */
@property (nonatomic, assign) CGFloat selectedFontSize;

/*!
 *  未选中状态字体大小
 */
@property (nonatomic, assign) CGFloat fontSize;

/*!
 *  未选中状态文本颜色
 */
@property (nonatomic, strong) UIColor *textColor;

/*!
 *  高亮状态文本颜色
 */
@property (nonatomic, strong) UIColor *highlightedTextColor;

/*!
 *  选中状态文本颜色
 */
@property (nonatomic, strong) UIColor *selectedTextColor;

/*!
 *  构造函数
 *
 *  @param stringArray 字符串数组
 *  @param cls         Cell类，必须从HTStringSegmentsCell继承而来
 *
 *  @return 实例对象
 */
- (instancetype)initWithArray:(NSArray*)stringArray segmentCellClass:(Class)cls;

@end
