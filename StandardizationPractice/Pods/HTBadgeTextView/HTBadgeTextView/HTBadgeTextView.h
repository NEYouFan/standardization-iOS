//
//  HTBadgeTextView.h
//  RedPoint
//
//  Created by cxq on 15/9/9.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  HTBadgeTextView用法：
 *  1. 因为导入了UIView+Frame.h，可以通过self.height, width, x, y等一系列的方法来获取和设置参数
 *     而不需要像以前一样self.bounds.size.width。 适用于所有继承UIView的子类
 *  2. innerImageView位于outerImageView上层。
 *  3. 文本、innerImageView、outerImageView、自动处理居中
 */
@interface HTBadgeTextView : UIView

- (instancetype)initWithInnerSize:(CGSize)innerSize outerSize:(CGSize)outerSize isRound:(BOOL)isRound;

/**
 *  外层图片，主要用来设置阴影，覆盖整个控件
 */
@property (strong, nonatomic, readonly) UIImageView *outerBackground;

/*!
 *  外层图片
 */
@property (strong, nonatomic) UIImage *outerImage;

/**
 *  内层图片，主要用来设置背景色，默认覆盖整个控件
 */
@property (strong, nonatomic, readonly) UIImageView *innerBackground;

/*!
 *  内层图片
 */
@property (strong, nonatomic) UIImage *innerImage;

/**
 *  显示的文本控件，文字大小默认12，颜色white，居中显示，背景色 clearColor
 */
@property (strong, readonly, nonatomic) UILabel *textLabel;

/**
 *  文本内容设置
 */
@property (strong, nonatomic) NSString *text;

/**
 *  设置text的字体大小
 *
 *  @param fontSize 字体大小
 */
@property (nonatomic, assign) CGFloat textFontSize;

/*!
 *  是否需要自动增长文本宽度，会根据文本自适应，如果YES则incrementWidth是无效的，
 */
@property (assign, nonatomic) BOOL needWidthAutoIncrement;

/*!
 *  文本与innerBackground的两边padding
 */
@property (assign, nonatomic) CGFloat padding;

/*!
 *  outerBackground与innerBackground两边的padding
 */
@property (assign, nonatomic) CGFloat innerOuterPadding;

/*!
 *  innerBackground的初始化size大小。textLabel.text.length = 1时候的大小
 */
@property (assign, nonatomic) CGSize innerSize;

/*!
 *  outerBackground的初始化size大小。textLabel.text.length = 1时候的大小
 */
@property (assign, nonatomic) CGSize outerSize;

/*!
 *  是否需要圆形显示。即innerBackground.layer.cornerRadius = innerSize.height/2
 *  outerBackground.layer.cornerRadius = outerSize.height/2
 */
@property (nonatomic, assign) BOOL isRound;

@end
