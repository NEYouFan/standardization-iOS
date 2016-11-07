//
//  HTNavigationPanGestureHandler.h
//  Pods
//
//  Created by 志强 on 16/3/10.
//
//

#import "HTNavigationPanGestureHandler.h"
#import <UIKit/UIKit.h>
@protocol HTNavigationGestureHandlerDelegate;

/**
 *  自定义的navigation交互手势
 *  全屏返回手势；在scroll view上右划可以返回；
 */
@interface HTNavigationPanGestureHandler : NSObject

@property (nonatomic, readonly) BOOL bPanning;

@property (nonatomic, assign) float maxAllowedSlideDistanceToLeftEdge;

@property (nonatomic, weak) UINavigationController *navigationViewController;

@property (nonatomic, weak) id <HTNavigationGestureHandlerDelegate> gestureHandlerDelegate;

- (instancetype)initWithNavigationController:(UINavigationController *)navigationController
                      gestureHandlerDelegate:(id<HTNavigationGestureHandlerDelegate>)gestureHandlerDelegate;

- (void)panGestureHandlerReceive:(UIPanGestureRecognizer*)gestureRecognizer;

- (void)panGestureHandlerReceiveBegin:(UIPanGestureRecognizer*)gestureRecognizer;

- (void)panGestureHandlerReceiveChanged:(UIPanGestureRecognizer*)gestureRecognizer;

//for inherit
- (BOOL)isCancelTransitionWhenGestureEnded:(UIPanGestureRecognizer*)gestureRecognizer;

- (void)panGestureHandlerReceiveEnded:(UIPanGestureRecognizer*)gestureRecognizer isCanceled:(BOOL)isCanceled;

@end
