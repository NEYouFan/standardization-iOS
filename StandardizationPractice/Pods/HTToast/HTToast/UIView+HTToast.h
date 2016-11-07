/***************************************************************************
 
UIView+HTToast.h
Toast

Copyright (c) 2014 Charles Scalesse.
 
Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:
 
The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.
 
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
***************************************************************************/

#import <UIKit/UIKit.h>
typedef void(^animationBlock)(UIView *view,UIView *toast);

extern NSString * const HTToastPositionTop;
extern NSString * const HTToastPositionCenter;
extern NSString * const HTToastPositionBottom;

@interface UIView (HTToast)

// each makeToast method creates a view and displays it as toast
/**
 *  自动生成toast的接口
 *
 *  @param message  文字的展示内容
 */
- (void)makeToast:(NSString *)message;

/**
 *  自动生成toast的接口
 *
 *  @param message  文字的展示内容
 *  @param interval 间隔，展现动画的时间。即默认的消失动画开始时间
 *  @param position 位置
 */
- (void)makeToast:(NSString *)message duration:(NSTimeInterval)interval position:(id)position;

/**
 *  自动生成toast的接口
 *
 *  @param message  文字的展示内容
 *  @param interval 间隔，展现动画的时间。即默认的消失动画开始时间
 *  @param position 位置
 *  @param image    图片
 */
- (void)makeToast:(NSString *)message duration:(NSTimeInterval)interval position:(id)position image:(UIImage *)image;

/**
 *  自动生成toast的接口
 *
 *  @param message  文字的展示内容
 *  @param interval 间隔，展现动画的时间。即默认的消失动画开始时间
 *  @param position 位置
 *  @param title    标题
 */
- (void)makeToast:(NSString *)message duration:(NSTimeInterval)interval position:(id)position title:(NSString *)title;

/**
 *  自动生成toast的接口
 *
 *  @param message  文字的展示内容
 *  @param interval 间隔，展现动画的时间。即默认的消失动画开始时间
 *  @param position 位置
 *  @param title    标题
 *  @param image    图片
 */
- (void)makeToast:(NSString *)message duration:(NSTimeInterval)interval position:(id)position title:(NSString *)title image:(UIImage *)image;

/**
 *  自动生成toast的接口
 *
 *  @param message            文字的展示内容
 *  @param position           位置信息
 *  @param showAnimationBlock 展示动画传入showToast方法中
 *  @param hideAnimationBlock 消失动画传入showToast方法中
 */
- (void)makeToast:(NSString *)message
showWithAnimationBlock:(animationBlock)showAnimationBlock
hideWithAnimationBlock:(animationBlock)hideAnimationBlock;

/**
 *  自动生成toast的接口
 *
 *  @param message            文字的展示内容
 *  @param position           位置信息
 *  @param showAnimationBlock 展示动画传入showToast方法中
 *  @param hideAnimationBlock 消失动画传入showToast方法中
 */
- (void)makeToast:(NSString *)message position:(id)position
showWithAnimationBlock:(animationBlock)showAnimationBlock
hideWithAnimationBlock:(animationBlock)hideAnimationBlock;

/**
 *  自动生成toast的接口
 *
 *  @param message            文字的展示内容
 *  @param position           位置信息
 *  @param title              标题
 *  @param showAnimationBlock 展示动画传入showToast方法中
 *  @param hideAnimationBlock 消失动画传入showToast方法中
 */
- (void)makeToast:(NSString *)message position:(id)position title:(NSString *)title
showWithAnimationBlock:(animationBlock)showAnimationBlock
hideWithAnimationBlock:(animationBlock)hideAnimationBlock;

/**
 *  自动生成toast的接口
 *
 *  @param message            文字的展示内容
 *  @param position           位置信息
 *  @param image              图片
 *  @param showAnimationBlock 展示动画传入showToast方法中
 *  @param hideAnimationBlock 消失动画传入showToast方法中
 */
- (void)makeToast:(NSString *)message position:(id)position image:(UIImage *)image
showWithAnimationBlock:(animationBlock)showAnimationBlock
hideWithAnimationBlock:(animationBlock)hideAnimationBlock;

/**
 *  自动生成toast的接口
 *
 *  @param message            文字的展示内容
 *  @param position           位置信息
 *  @param image              图片
 *  @param title              标题
 *  @param showAnimationBlock 展示动画传入showToast方法中
 *  @param hideAnimationBlock 消失动画传入showToast方法中
 */
- (void)makeToast:(NSString *)message position:(id)position image:(UIImage *)image title:(NSString *)title
showWithAnimationBlock:(animationBlock)showAnimationBlock
hideWithAnimationBlock:(animationBlock)hideAnimationBlock;

/**
 *  纯ActivityIndictor的接口，居中显示
 */
- (void)makeToastActivity;

/**
 *  显示一个ActivityIndictor和message的toast（默认左边ActivityIndictor右边message）
 *
 *  @param message 文字的展示内容
 */
- (void)makeToastActivityWithMessage:(NSString *)message;

/**
 *  显示一个ActivityIndictor和message的toast（默认左边ActivityIndictor右边message）
 *
 *  @param message  文字的展示内容
 *  @param position 位置信息
 */
- (void)makeToastActivityWithMessage:(NSString *)message position:(id)position;
- (void)hideToastActivity;

// the showToast methods display any view as toast
- (void)showToast:(UIView *)toast;
- (void)showToast:(UIView *)toast duration:(NSTimeInterval)interval position:(id)position;
- (void)showToast:(UIView *)toast duration:(NSTimeInterval)interval position:(id)position
      tapCallback:(void(^)(void))tapCallback;

/**
 *  show动画接口
 *
 *  @param toast          需要显示的toast
 *  @param showAnimationBlock  toast显示的动画block,用户通过block自定义展示动画效果
 *  @param hideAnimationBlock  toast隐藏的动画block，注意！在hideAnimationBlock动画完成后需要将toast removeFromSuperView
 */
- (void)showToast:(UIView *)toast
showWithAnimationBlock:(animationBlock)showAnimationBlock
hideWithAnimationBlock:(animationBlock)hideAnimationBlock;

/**
 *  toast展示的接口
 *
 *  @param toast              需要显示的toast
 *  @param position           自定义位置信息（CGPoint需要转换为NSValue传递） 默认为HTToastPositionBottom
 *  @param showAnimationBlock toast显示的动画block
 *  @param hideAnimationBlock toast隐藏的动画block
 */
- (void)showToast:(UIView *)toast
         position:(id)position
showWithAnimationBlock:(animationBlock)showAnimationBlock
hideWithAnimationBlock:(animationBlock)hideAnimationBlock;

/**
 *  toast消失的接口
 *
 *  @param toast 需要消失的toast
 */
- (void)hideToast:(UIView *)toast;

@end
