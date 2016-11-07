//
//  HTNavigationDefaultTransitionPanGestureHandler.m
//  Pods
//
//  Created by 志强 on 16/3/12.
//
//

#import "HTNavigationSystemPanGestureHandler.h"

@interface HTNavigationSystemPanGestureHandler ()

@property (nonatomic, strong) id systemTarget;
@property (nonatomic, assign) SEL systemSelector;

@end
@implementation HTNavigationSystemPanGestureHandler

-(instancetype)initWithNavigationController:(UINavigationController *)navigationController gestureHandlerDelegate:(id)gestureHandlerDelegate
{
    self = [super initWithNavigationController:navigationController gestureHandlerDelegate:gestureHandlerDelegate];
    if (self) {
        navigationController.interactivePopGestureRecognizer.enabled = NO;
        //为使用系统的转场动画，需要系统手势的target selector
        NSArray *internalTargets = [navigationController.interactivePopGestureRecognizer valueForKey:@"targets"];
        _systemTarget = [internalTargets.firstObject valueForKey:@"target"];
        _systemSelector = NSSelectorFromString(@"handleNavigationTransition:");
    }
    return self;
}
-(void)panGestureHandlerReceive:(UIPanGestureRecognizer *)gestureRecognizer
{
    UIGestureRecognizerState state = [gestureRecognizer state];
    
    switch (state) {
        case UIGestureRecognizerStateBegan:
            [self panGestureHandlerReceiveBegin:gestureRecognizer];
            break;
            
        case UIGestureRecognizerStateChanged:
            [self panGestureHandlerReceiveChanged:gestureRecognizer];
            break;
            
        case UIGestureRecognizerStateEnded:
            if ([self isCancelTransitionWhenGestureEnded:gestureRecognizer])
                [self panGestureHandlerReceiveEnded:gestureRecognizer isCanceled:YES];
            else
                [self panGestureHandlerReceiveEnded:gestureRecognizer isCanceled:NO];
            break;
            
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
            [self panGestureHandlerReceiveEnded:gestureRecognizer isCanceled:YES];
            
        default:
            break;
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [_systemTarget performSelector:_systemSelector withObject:gestureRecognizer];
#pragma clang diagnostic pop
}
@end
