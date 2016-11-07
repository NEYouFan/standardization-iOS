//
//  HTModalWindow.h
//  Pods
//
//  Created by jw-mbp on 9/1/15.
//
//

#import <UIKit/UIKit.h>

typedef void (^CompleteBlock)(void);

@interface HTModalWindow : UIWindow

/**
 *  显示window
 */
- (void)show;

/**
 *  隐藏window
 */
- (void)hide;

/** 
 *  显示window之后回调函数，子类可以重写该方法以实现自身动画。
 *  @param completeBlock 动画播放完成回调函数，子类重写需要调用该方法。
 */
- (void)showAnimationWithCompletionBlock:(CompleteBlock)completeBlock;


/** 
 *  隐藏window之前回调函数，子类可以重写该方法以实现自身动画。
 *  @param completeBlock 动画播放完成回调函数，子类重写需要调用该方法。
 */
- (void)hideAnimationWithCompletionBlock:(CompleteBlock)completeBlock;
@end
