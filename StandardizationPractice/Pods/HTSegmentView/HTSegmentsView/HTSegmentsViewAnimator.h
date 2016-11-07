//
//  HTSegmentsViewAnimator.h
//  HTUIDemo
//
//  Created by zp on 15/9/6.
//  Copyright (c) 2015年 HT. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HTSegmentsView;

/*!
 *  HTSegmentsView选中状态切换的时候，有一些全局动画，他不方便在Cell上描述，所以提供一个Animator
 */
@interface HTSegmentsViewAnimator : NSObject

/*!
 *  Animator作用于segmentsView
 */
@property (nonatomic, weak, readonly) HTSegmentsView *segmentsView;

/*!
 *  构造函数
 *
 *  @param segmentsView
 *
 *  @return 实例对象
 */
- (instancetype)initWithSegmentsView:(HTSegmentsView*)segmentsView;

/*!
 *  从某个index移动到另外一个index，使用percent表示移动的百分比
 *
 *  @param fromIndex 开始的index
 *  @param to        目标的index
 *  @param percent   移动百分比
 *  @param animated  是否使用动画
 */
- (void)moveSegmentFrom:(NSUInteger)fromIndex to:(NSUInteger)to percent:(CGFloat)percent animated:(BOOL)animated;

/*!
 *  从当前状态移动到index处的Cell
 *
 *  @param index    移动的目标
 *  @param animated 是否使用动画
 */
- (void)moveToIndex:(NSUInteger)index animated:(BOOL)animated;

/*!
 *  隐藏动画控件
 */
- (void)hide;

/*!
 *  显示动画控件
 */
- (void)show;

@end

/*!
 *  支持下划线，背景的Animator
 */
@interface HTSublineSegmentViewAnimator : HTSegmentsViewAnimator

/*!
 *  线的高度
 */
@property (nonatomic, readonly) CGFloat lineHeight;

/*!
 *  线的宽度是否跟cell的内容匹配，否则跟Cell的宽度一致，默认为NO
 */
@property (nonatomic, assign) BOOL lineWidthEqualToCellContent;

/*!
 *  线的宽度在cellcontent宽度左右各加一个padding
 */
@property (nonatomic, assign) CGFloat cellContentPadding;

/*!
 *  下划线的颜色
 */
@property (nonatomic, strong, readonly) UIColor *lineColor;

/*!
 *  背景色
 */
@property (nonatomic, strong, readonly) UIColor *backgroundColor;

/*!
 *  动画持续时间
 */
@property (nonatomic, assign) NSTimeInterval animationDuration;

- (instancetype)initWithSegmentsView:(HTSegmentsView*)segmentsView
                     backgroundColor:(UIColor*)backgroundColor
                           lineColor:(UIColor*)lineColor
                          lineHeight:(CGFloat)lineHeight;

/*!
 *  HTSublineSegmentViewAnimator使用layer来显示，地步下划线使用lineLayer来表示
 *
 *  @return 下划线layer
 */
- (CALayer*)lineLayer;

/*!
 *  HTSublineSegmentViewAnimator使用backgroundLayer来表示背景色
 *
 *  @return 背景色layer
 */
- (CALayer*)backgroundLayer;

@end
