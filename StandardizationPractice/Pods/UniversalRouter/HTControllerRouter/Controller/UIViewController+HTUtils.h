//
//  UIViewController+HTUtils.h
//  HTUIDemo
//
//  Created by zp on 15/8/29.
//  Copyright (c) 2015年 HT. All rights reserved.
//

#import <UIKit/UIKit.h>

/*!
 *  深度遍历UIViewController Tree结构。
 *  UINavigationController/UITabbarController/UIViewController直接遍历childViewController
 *  如果存在presented viewcontroller，当前parent-child遍历结束之后，需要开始遍历presented viewcontrolled
 *  @param UIViewController 当前遍历的节点
 *
 *  @return 返回NO，表示停止遍历，否则会继续遍历下去
 */
typedef BOOL (^ControllerTreeTraverseOperation)(UIViewController*);

/*!
 *  将Controller从tree中删除，因为dismissviewcontroller接口一定是异步的。。。所以没办法，必须提供一个异步回调接口！
 *  如果不是present controller从tree中删除，那么这个回调就同步调用
 *
 *  @param 这个Controller是否从Controller tree中删除
 */
typedef void (^RemoveControllerFromTreeCallback)(BOOL);

/**
 *  包含HT对外提供的接口
 */
@interface UIViewController (HTUtils)

/*!
 *  返回最顶上的Controller：presented 单链表尾部
 *
 *  @return presented 单链表尾部
 */
+ (UIViewController*) ht_topMostController;

/*!
 *  从当前所属的present链上，最顶部controller，依次判断parent view controller，如果parent view controller于self相等，则认为这个controller在visible path上。
 *
 *  @warning 容器Controller目前只考虑UINavigationController，UITabbarController。
 *
 *  @return 是否在可视链上
 */

- (BOOL)ht_isInControllerTreeVisiblePath;

/*!
 *  将self从Controller tree中删除
 *  因为dismiss view controller一定是异步，在dismiss没有complete之前同步在presente一个controller，会报错，所以通过RemoveControllerFromTreeCallback来返回结果。如果参数为YES，表示可以删除，否则无法删除。
 *  
 *  @warning：有些清楚无法删除，譬如：self是tabbarcontroller的一个child，此时cb回调参数为NO
 
 *  如果没有从Controller tree中删除，那么不会对原来Controller tree有任何影响
 * 
 *  @warning：考虑HTContainerViewController，有可能删除的是self被包裹的ContainerViewController
 *
 *
 *  @param cb 删除之后的回调
 */
- (void)ht_removeFromControllerTree:(RemoveControllerFromTreeCallback)cb;

/*!
 *  如果self在Controller tree上，将这个Controller露出来，变成可见。
 *
 *  @param 是否使用动画：注意：不是所有clearToTop都可以使用动画!
 *
 *  @return 可以露出来，返回YES，否则返回NO
 */
- (BOOL)ht_clearToTop:(BOOL)animated;

/*!
 *  从自身的NavigationController中删除，必须确保self在self.navigationController的viewControllers中。
 *  同步删除，没有动画
 */
- (void)ht_removeFromNavigationController;

///*!
// *  深度遍历所有的ViewController，如果存在presented viewcontroller，在遍历完所有的ChildViewController之后，会遍历presentedViewController
// *
// *  @param operation 遍历函数
// */
//- (void)ht_traverseControllerTree:(ControllerTreeTraverseOperation)operation;

/*!
 *  获取这个ViewController的根Controller，即是最根部的parent view controller
 */
- (UIViewController*)ht_rootViewController;

/**
 *  根据类名从present controller chain中查找
 *
 *  @return 查找指定类名的实例
 */
+ (UIViewController *)ht_findInstanceInPresentedControllerTree;
@end
