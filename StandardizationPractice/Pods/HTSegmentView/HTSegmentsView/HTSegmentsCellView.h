//
//  HTSegmentsCellView.h
//  Pods
//
//  Created by jw on 3/28/16.
//
//

#import <UIKit/UIKit.h>

/*!
 *  HTSegmentsCellView，所有在HTSegmentsView中使用的Cell，必须从这个类继承出来。
 *  继承类需要处理selected，hilighted状态切换的时候的UI切换
 *  继承类需要处理排版
 *  继承类可以定义选中状态切换的动画
 */
@interface HTSegmentsCellView : UIView

/*!
 * 该Cell如果被选中，selected状态会被设置为YES，否则为NO
 */
@property (nonatomic, getter=isSelected)  BOOL selected;

/*!
 *  该Cell如果当前是touch状态，hilighted状态为YES，否则为NO
 */
@property (nonatomic, getter=isHilighted) BOOL hilighted;

/*!
 *  当存在切换过程，需要根据用户交互，逐渐更改显示效果，如果percent为1，他的表现应该跟完全选中（selected）状态一致，如果percent为0，他的表现应该跟selected状态为NO表现一致。
 *
 *  @param percent
 *  @param animated 是否需要使用动画
 */
- (void)updateBySwitchPercent:(CGFloat)percent animated:(BOOL)animated;

/*!
 *  有的时候，我们全局的滑动标识底部下划线长度不是Cell的宽度，而是其内部内容的宽度，通过这个接口告诉Animator。
 *
 *  @return 内容的frame，该frame相对于Cell为参考
 */
- (CGRect)contentFrame;
@end

/*!
 *  用于显示文本的Cell
 */
@interface HTStringSegmentsCell : HTSegmentsCellView

@property (nonatomic, strong, readonly) UILabel *label;

@property (nonatomic, assign) CGFloat selectedFontSize;
@property (nonatomic, assign) CGFloat fontSize;

@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIColor *highlightedColor;
@property (nonatomic, strong) UIColor *selectedTextColor;

@end

