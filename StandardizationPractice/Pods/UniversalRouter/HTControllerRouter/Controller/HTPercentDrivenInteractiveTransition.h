//
//  HTPercentDrivenInteractiveTransition.h
//  Pods
//
//  Created by zp on 15/10/21.
//
//

#import <UIKit/UIKit.h>

/**
 *  实现了页面随手指移动的交互动画效果。
 *  在navigation delegate返回动画时，
 *  使用UIPercentDrivenInteractiveTransition实现不了
 *  页面随手指移动的效果。
 */
@interface HTPercentDrivenInteractiveTransition : UIPercentDrivenInteractiveTransition

@end
