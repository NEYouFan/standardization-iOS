//
//  HTNavigationGestureHandlerDelegate.h
//  Pods
//
//  Created by 志强 on 16/3/10.
//
//

#import <Foundation/Foundation.h>

@protocol HTNavigationGestureHandlerDelegate <NSObject>

@optional
- (void)navigationController:(UINavigationController*)navigationController
           panGestureChanged:(UIPanGestureRecognizer*)gestureRecognizer;

- (void)navigationController:(UINavigationController*)navigationController
             panGestureBegin:(UIPanGestureRecognizer*)gestureRecognizer;

- (void)navigationController:(UINavigationController*)navigationController
             panGestureEnded:(UIPanGestureRecognizer*)gestureRecognizer
                  isCanceled:(BOOL)isCancel;

@end
