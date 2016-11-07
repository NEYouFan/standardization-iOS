//
//  HTToast.h
//  Pods
//
//  Created by cxq on 15/9/1.
//
//

#import <Foundation/Foundation.h>
#import "UIView+HTToast.h"
/**
 *  使用任何ToastView时只需导入此头文件,
 *  通用接口，直接调用，显示在UIWindow上，不提供自定义动画
 */
@interface HTToast : NSObject

/**
 *  显示默认toast在默认的window上面
 *
 *  @param message toast的文字信息
 */
+ (void)showToastWithMessage:(NSString *)message;

/**
 *  显示自定义toast在默认的window上面
 *
 *  @param view 自定义的toast
 */
+ (void)showToastWithView:(UIView *)view;

/**
 *  显示默认toast在默认的window上面
 *
 *  @param message  toast的文字信息
 *  @param interval toast的显示时间
 */
+ (void)showToastWithMessage:(NSString *)message duration:(NSTimeInterval)interval;

/**
 *  显示自定义toast在默认的window上面
 *
 *  @param view     自定义的toast
 *  @param interval toast的显示时间
 */
+ (void)showToastWithView:(UIView *)view duration:(NSTimeInterval)interval;

/**
 *  显示默认toast在默认的window上面
 *
 *  @param message  toast的文字信息
 *  @param interval toast的显示时间
 *  @param position toast的位置信息,默认为Center
 */
+ (void)showToastWithMessage:(NSString *)message duration:(NSTimeInterval)interval position:(id)position;

/**
 *  显示自定义toast在默认的window上面
 *
 *  @param view     自定义的toast
 *  @param interval toast的显示时间
 *  @param position toast的位置信息,默认为Center
 */
+ (void)showToastWithView:(UIView *)view duration:(NSTimeInterval)interval position:(id)position;

@end
