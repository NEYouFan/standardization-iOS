//
//  HTNavigationPanGestureHandler.m
//  Pods
//
//  Created by 志强 on 16/3/10.
//
//

#import "HTNavigationPanGestureHandler.h"
#import "HTNavigationPanProtocol.h"
#import "UIViewController+HTRouterUtils.h"
#import "HTNavigationGestureHandlerDelegate.h"

@interface HTNavigationPanGestureHandler () <UIGestureRecognizerDelegate, HTNavigationBackPanGestureProtocol>

@property (nonatomic, assign) CGPoint startPanPosition;

@property (nonatomic, weak) UIScrollView *simultaneouslyScrollView;

@property (nonatomic, assign) BOOL simultaneouslyScrollViewEnable;

@property (nonatomic, assign) BOOL bPanning;

@end

@implementation HTNavigationPanGestureHandler

- (instancetype)initWithNavigationController:(UINavigationController *)navigationController
                      gestureHandlerDelegate:(id<HTNavigationGestureHandlerDelegate>)gestureHandlerDelegate
{
    self = [super init];
    if (self){
        _navigationViewController = navigationController;
        _gestureHandlerDelegate = gestureHandlerDelegate;
        
        UIPanGestureRecognizer *gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureHandlerReceive:)];
        gesture.delegate = self;
        [_navigationViewController.view addGestureRecognizer:gesture];
        
    }
    
    return self;
}

/*!
 *  获取viewcontroller topmost viewcontroller，如果这个controller不支持HTNavigationBackPanGestureProtocol，则返回nil
 *
 *  @return viewcontroller
 */
- (id<HTNavigationBackPanGestureProtocol>)topmostConformedViewController
{
    UIViewController *lastConformedViewController = nil;
    UIViewController *viewController = self.navigationViewController.viewControllers.lastObject;
    while (viewController) {
        if ([viewController conformsToProtocol:@protocol(HTNavigationBackPanGestureProtocol)]){
            lastConformedViewController = viewController;
        }
        
        UIViewController *currentViewController = [viewController ht_currentChildViewController];
        if (currentViewController){
            viewController = currentViewController;
        }
        else
            break;
    }
    
    return (id<HTNavigationBackPanGestureProtocol>)lastConformedViewController;
}

#pragma mark - for inherit

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer
{
    _simultaneouslyScrollView = nil;
    
    if (self.navigationViewController.viewControllers.count <= 1)
        return NO;
    
    if (!UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation))
        return NO;
    
    id<HTNavigationBackPanGestureProtocol> topmostViewController = [self topmostConformedViewController];
    
    if (topmostViewController &&
        [topmostViewController respondsToSelector:@selector(navigationControllerBackPanGestureRecognizerShouldBegin:)])
    {
        if (![topmostViewController navigationControllerBackPanGestureRecognizerShouldBegin:gestureRecognizer])
            return NO;
    }
    
    // Ignore when the beginning location is beyond max allowed slide distance to left edge.
    CGPoint beginningLocation = [gestureRecognizer locationInView:gestureRecognizer.view];
    if (_maxAllowedSlideDistanceToLeftEdge > 0 && beginningLocation.x > _maxAllowedSlideDistanceToLeftEdge) {
        return NO;
    }
    CGFloat velocity = [gestureRecognizer velocityInView:self.navigationViewController.view].x;
    if (velocity > 0)
        return YES;
    
    return NO;
}

- (BOOL)gestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIPanGestureRecognizer *)otherGestureRecognizer{
    if (_bPanning)
        return NO;
    
    if (_simultaneouslyScrollView)
        return NO;
    
    if ([gestureRecognizer isKindOfClass:UIPanGestureRecognizer.class] &&
        [otherGestureRecognizer isKindOfClass:UIPanGestureRecognizer.class] &&
        !UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)){
        
        if (![otherGestureRecognizer.view isKindOfClass:UIScrollView.class]){
            return NO;
        }
        
        _simultaneouslyScrollView = (UIScrollView *)otherGestureRecognizer.view;
        UIPanGestureRecognizer *scrollViewPan = (UIPanGestureRecognizer *)otherGestureRecognizer;
        
        id<HTNavigationBackPanGestureProtocol> topmostViewController = [self topmostConformedViewController];
        if (topmostViewController &&
            [topmostViewController respondsToSelector:@selector(navigationControllerBackPanGestureRecognizer:shouldRecognizeSimultaneouslyWithGestureRecognizer:)] &&
            ![topmostViewController navigationControllerBackPanGestureRecognizer:gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:otherGestureRecognizer]){
            _simultaneouslyScrollView = nil;
            _simultaneouslyScrollViewEnable = YES;
            return NO;
        }
        
        if (_simultaneouslyScrollView.contentOffset.x == 0 &&
            [scrollViewPan translationInView:scrollViewPan.view].x > 0) {
            _simultaneouslyScrollViewEnable = NO;
            return YES;
        }else{
            _simultaneouslyScrollViewEnable = YES;
            _simultaneouslyScrollView = nil;
        }
    }
    return NO;
}

- (void)pinImageSetContentScrollView{
    if (_simultaneouslyScrollView && !_simultaneouslyScrollViewEnable) {
        _simultaneouslyScrollView.scrollEnabled = NO;
        //如果上下也有滚动，将contentOffset改成{0,0}，会导致后退的时候跳动。
        //UIEdgeInsets edgeInset = _simultaneouslyScrollView.contentInset;
        //[_simultaneouslyScrollView setContentOffset:CGPointMake(0, -edgeInset.top)];
    }
}

- (void)enableScrollViewAfterGestureRecognize
{
    _simultaneouslyScrollView.scrollEnabled = YES;
    _simultaneouslyScrollView = nil;
}

#pragma mark - pan callback
- (void)panGestureHandlerReceive:(UIPanGestureRecognizer*)gestureRecognizer
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
}

- (void)panGestureHandlerReceiveBegin:(UIPanGestureRecognizer*)gestureRecognizer
{
    id<HTNavigationBackPanGestureProtocol> topmostViewController = [self topmostConformedViewController];
    if ([topmostViewController respondsToSelector:@selector(navigationControllerBackPanGestureRecognizerBegin:)]){
        [topmostViewController navigationControllerBackPanGestureRecognizerBegin:gestureRecognizer];
    }
    
    //暂时只考虑portrait
    CGPoint location = [gestureRecognizer locationInView:self.navigationViewController.view];
    CGFloat velocity = [gestureRecognizer velocityInView:self.navigationViewController.view].x;
    
    NSAssert(velocity > 0, @"默认Navigation手势只支持后退手势");
    
    _bPanning = YES;
    _startPanPosition = location;
    
    [self pinImageSetContentScrollView];
    
    if ([_gestureHandlerDelegate respondsToSelector:@selector(navigationController:panGestureBegin:)]) {
        [_gestureHandlerDelegate navigationController:_navigationViewController panGestureBegin:gestureRecognizer];
    }
}

- (void)panGestureHandlerReceiveChanged:(UIPanGestureRecognizer*)gestureRecognizer
{
    if ([_gestureHandlerDelegate respondsToSelector:@selector(navigationController:panGestureChanged:)]) {
        [_gestureHandlerDelegate navigationController:_navigationViewController panGestureChanged:gestureRecognizer];
    }
}

- (BOOL)isCancelTransitionWhenGestureEnded:(UIPanGestureRecognizer*)gestureRecognizer
{
    CGPoint location = [gestureRecognizer locationInView:self.navigationViewController.view];
    CGFloat velocity = [gestureRecognizer velocityInView:self.navigationViewController.view].x;
    
    if (velocity > 500)
        return NO;
    
    if (location.x - _startPanPosition.x <= CGRectGetWidth(self.navigationViewController.view.frame)/6)
        return YES;
    
    if (velocity < -60)
        return YES;
    
    return NO;
}

- (void)panGestureHandlerReceiveEnded:(UIPanGestureRecognizer*)gestureRecognizer isCanceled:(BOOL)isCanceled
{
    _bPanning = NO;
    
    [self enableScrollViewAfterGestureRecognize];
    
    if ([_gestureHandlerDelegate respondsToSelector:@selector(navigationController:panGestureEnded:isCanceled:)]) {
        [_gestureHandlerDelegate navigationController:_navigationViewController panGestureEnded:gestureRecognizer isCanceled:isCanceled];
    }
}


@end
