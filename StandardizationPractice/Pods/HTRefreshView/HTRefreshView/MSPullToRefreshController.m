//
//  MSPullToRefreshController.m
//
//  Created by John Wu on 3/5/12.
//  Modified by (Netease)Bai_tianyu on 9/15/15.
//  Copyright (c) 2012 TFM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ReactiveCocoa.h"
#import "RACEXTScope.h"
#import "MSPullToRefreshController.h"
#import "HTRefreshView.h"
#import "HTRefreshViewLogger.h"
#import "RACEXTScope.h"
#import "NSObject+HTSafeObserver.h"

@interface MSPullToRefreshController ()

/*
 The next properties is NSMapTable or Array type, this is because 
 informations for diffrent directions are stored seperate.
 */
/// Indicate whether the contentInset setting animation has finished.
@property (nonatomic, strong) NSMutableArray *insetAnimationFinished;
/// Indicate if a refresh's business logic has finished.
@property (nonatomic, strong) NSMutableArray *logicRefreshFinished;
/// Indicate whether the refresh sequence could be finish.
@property (nonatomic, strong) NSMutableArray *canFinish;
/*!
 ScrollView's original content inset before refresh sequence. Stored diffrent 
 direction's original contentInset seperate to fix the ORIGINAL MS Library's bug.
 */
@property (nonatomic, strong) NSMutableArray *originalContentInsets;

@property (nonatomic, weak) id<MSPullToRefreshDelegate> topDelegate;
@property (nonatomic, weak) id<MSPullToRefreshDelegate> leftDelegate;
@property (nonatomic, weak) id<MSPullToRefreshDelegate> bottomDelegate;
@property (nonatomic, weak) id<MSPullToRefreshDelegate> rightDelegate;

/*!
 When the ScrollView's contentOffset changed,check if the refresh stage should 
 change on the specified direction.
 
 @param direction The direction to be checked whether should change the refresh stage.
 @param delegate  Delegate to recieve callbacks.
 */
#warning 方法名
- (void) _checkOffsetsForDirection:(MSRefreshDirection)direction
                          delegate:(id<MSPullToRefreshDelegate>)delegate;

/*!
 Adjust the contentInset of scrollView. To get smooth view scrolling.
 
 @param contentInset The contentInset to be set to scrollView.
 @param direction    Which direction, used to set the insetAnimationFinished.
 */
- (void)adjustContentInset:(UIEdgeInsets)contentInset
                 direction:(MSRefreshDirection)direction;

/*!
 判断给定方向上 canFinish 是否应该改变
 
 @param direction Specified direction.
 */
- (void)judgeCanFinish:(MSRefreshDirection)direction;

/*!
 ContentOffset 变化时计算与刷新操作有关的参数
 
 @param canEngage 是否松手即可执行刷新.
 @param reachEdge content 是否滚动到 scrollView 的边缘.
 @param percent   拖拽距离与 refreshableInset 的比例.
 @param direction 给定的方向(不同方向判别条件不同).
 @param delegate  提供 refreshableInset 等参数的 RefreshView.
 
 @return 为满足刷新操作需设置的 contentInset.
 */
- (UIEdgeInsets)calculateCanEngage:(BOOL *)canEngage
                        reachEdges:(BOOL *)reachEdge
                           percent:(CGFloat *)percent
                         direction:(MSRefreshDirection)direction
                          delegate:(id<MSPullToRefreshDelegate>)delegate;

@end


@implementation MSPullToRefreshController

#pragma mark - Object Life Cycle

- (id)initWithScrollView:(UIScrollView *)scrollView
                delegate:(id<MSPullToRefreshDelegate>)delegate
               direction:(MSRefreshDirection)direction {
    if (!scrollView || !delegate ) {
        HTRefreshViewLogError(@"MSpullToRefreshController: Invalid parameters!");
        return nil;
    }
    
    if (self = [super init]) {
        // Add delegate
        [self setDelegate:delegate withDirection:direction];
        // Set variables.
        self.scrollView = scrollView;
#warning 使用@(NO)即可. refreshMode 数组同.
//        self.insetAnimationFinished = [NSMutableArray arrayWithObjects:@(NO), @(NO), @(NO), @(NO), nil];
        self.insetAnimationFinished = [NSMutableArray arrayWithObjects:
                                       [NSNumber numberWithBool:NO],
                                       [NSNumber numberWithBool:NO],
                                       [NSNumber numberWithBool:NO],
                                       [NSNumber numberWithBool:NO], nil];
        self.logicRefreshFinished = [NSMutableArray arrayWithArray:_insetAnimationFinished];
        self.canFinish = [NSMutableArray arrayWithArray:_insetAnimationFinished];
        // Default is {0,0,0,0}
        self.originalContentInsets = [NSMutableArray arrayWithObjects:
                                      [NSValue valueWithUIEdgeInsets:UIEdgeInsetsZero],
                                      [NSValue valueWithUIEdgeInsets:UIEdgeInsetsZero],
                                      [NSValue valueWithUIEdgeInsets:UIEdgeInsetsZero],
                                      [NSValue valueWithUIEdgeInsets:UIEdgeInsetsZero], nil];
        // Default is MSDraggingTriggerRefresh mode.
        self.refreshMode = [NSMutableArray arrayWithObjects:
                            [NSNumber numberWithInteger:MSDraggingTriggerRefresh],
                            [NSNumber numberWithInteger:MSDraggingTriggerRefresh],
                            [NSNumber numberWithInteger:MSDraggingTriggerRefresh],
                            [NSNumber numberWithInteger:MSDraggingTriggerRefresh],nil];
        
        /*
         Observe the contentOffset.
         Use ReactiveCocoa.
         */
        @weakify(self)
        [RACObserve(self.scrollView, contentOffset) subscribeNext:^(id x) {
            @strongify(self)
//#warning 监控contentOffset
            [self contentOffsetChanged];
        }];
    }
    return self;
}

- (id<MSPullToRefreshDelegate>)delegateWithDirection:(MSRefreshDirection)direction
{
    switch (direction) {
        case MSRefreshDirectionTop:
            return _topDelegate;
        
        case MSRefreshDirectionLeft:
            return _leftDelegate;

            
        case MSRefreshDirectionRight:
            return _rightDelegate;
            
        case MSRefreshDirectionBottom:
            return _bottomDelegate;
            
        default:
            break;
    }
}

- (void)setDelegate:(id<MSPullToRefreshDelegate>)delegate withDirection:(MSRefreshDirection)direction
{
    switch (direction) {
        case MSRefreshDirectionTop:
            _topDelegate = delegate;
            break;
            
        case MSRefreshDirectionLeft:
            _leftDelegate = delegate;
            break;
            
        case MSRefreshDirectionRight:
            _rightDelegate = delegate;
            break;
            
        case MSRefreshDirectionBottom:
            _bottomDelegate = delegate;
            break;
            
        default:
            break;
    }
}

- (void)dealloc {
    // Basic clean up. Now use ReactiveCocoa to manage observer.
}



#pragma mark - KVO

- (void)contentOffsetChanged {
    id<MSPullToRefreshDelegate> delegate = nil;

    // For each direction, check to see if refresh sequence needs to be updated.
    for (MSRefreshDirection direction = MSRefreshDirectionTop;
                           direction <= MSRefreshDirectionRight;
                                                    direction++) {

        delegate = [self delegateWithDirection:direction];
        if (delegate) {
            // If the delegate allow the refresh in the given direction.
            BOOL canRefresh = [delegate pullToRefreshController:self
                                          canRefreshInDirection:direction];

            if (canRefresh)
#warning 核心就是这个方法，这个方法检查offset并且通知到delegate也就是HTRefreshView.
                [self _checkOffsetsForDirection:direction delegate:delegate];
        }
    }
}



#pragma mark - Public Methods

#warning 只能由RefreshView的startRefresh触发？
- (void)startRefreshingDirection:(MSRefreshDirection)direction
                        delegate:(id<MSPullToRefreshDelegate>)delegate {
    [self startRefreshingDirection:direction delegate:delegate animated:NO];
}

- (void)startRefreshingDirection:(MSRefreshDirection)direction
                        delegate:(id<MSPullToRefreshDelegate>)delegate
                        animated:(BOOL)animated {
    if ([_refreshMode[direction] integerValue] == MSDoNotTriggerRefresh) {
        return;
    }
    
    MSRefreshingDirections refreshingDirection = 1 << direction;
    MSRefreshableDirections refreshableDirection = 1 << direction;
    UIEdgeInsets contentInset = _scrollView.contentInset;
    CGPoint contentOffset = CGPointZero;
    // pullToRefreshController:refreshingInsetForDirection: is required method.
    CGFloat refreshingInset = [delegate pullToRefreshController:self
                                    refreshingInsetForDirection:direction];
    
    // 宽度和高度均取 frame 和 contentSize 的较大值
    CGFloat adjustedSizeWidth = (_scrollView.contentSize.width > _scrollView.frame.size.width)?
    _scrollView.contentSize.width : _scrollView.frame.size.width;
    CGFloat adjustedSizeHeigth = (_scrollView.contentSize.height > _scrollView.frame.size.height)?
    _scrollView.contentSize.height : _scrollView.frame.size.height;
    CGSize adjustedContentSize = CGSizeMake(adjustedSizeWidth, adjustedSizeHeigth);
    
#warning 模拟滑动.
    CGFloat originalContentOffsetX = 0.0;
    CGFloat originalContentOffsetY = 0.0;
    switch (direction) {
        case MSRefreshDirectionTop:
            originalContentOffsetY = -contentInset.top;
            contentInset = UIEdgeInsetsMake(contentInset.top + refreshingInset,
                                            contentInset.left,
                                            contentInset.bottom, contentInset.right);
            contentOffset = CGPointMake(0, -refreshingInset + originalContentOffsetY);
            break;
        case MSRefreshDirectionLeft:
            originalContentOffsetX = -contentInset.left;
            contentInset = UIEdgeInsetsMake(contentInset.top,
                                            contentInset.left + refreshingInset,
                                            contentInset.bottom, contentInset.right);
            contentOffset = CGPointMake(-refreshingInset + originalContentOffsetX, 0);
            break;
        case MSRefreshDirectionBottom:
            originalContentOffsetY = adjustedContentSize.height - _scrollView.frame.size.height + contentInset.bottom;
            contentInset = UIEdgeInsetsMake(contentInset.top,
                                            contentInset.left,
                                            contentInset.bottom + refreshingInset,
                                            contentInset.right);
            contentOffset = CGPointMake(0, originalContentOffsetY + refreshingInset);
            break;
        case MSRefreshDirectionRight:
            originalContentOffsetX = adjustedContentSize.width - _scrollView.frame.size.width + contentInset.right;
            contentInset = UIEdgeInsetsMake(contentInset.top,
                                            contentInset.left,
                                            contentInset.bottom,
                                            contentInset.right + refreshingInset);
            contentOffset = CGPointMake(originalContentOffsetX + refreshingInset, 0);
            break;
        default:
            break;
    }
    
    self.refreshingDirections |= refreshingDirection;
    self.refreshableDirections &= ~refreshableDirection;
    self.insetAnimationFinished[direction] = [NSNumber numberWithBool:NO];
    self.logicRefreshFinished[direction] = [NSNumber numberWithBool:NO];
    self.originalContentInsets[direction] = [NSValue valueWithUIEdgeInsets:_scrollView.contentInset];
    
    if ([delegate respondsToSelector:@selector(pullToRefreshController:didEngageRefreshDirection:)]) {
        [delegate pullToRefreshController:self didEngageRefreshDirection:direction];
    }
    @weakify(self)
    [UIView animateWithDuration:.25
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^ {
                         @strongify(self)
                         self.scrollView.contentInset = contentInset;
                         self.scrollView.contentOffset = contentOffset;
                     }
                     completion:^(BOOL finished) {
                         @strongify(self)
                         self.insetAnimationFinished[direction] = [NSNumber numberWithBool:YES];
                         if ([self.logicRefreshFinished[direction] boolValue]) {
                             [self finishRefreshingDirection:direction animated:YES];
                         }
                     }];
    
}

- (void)finishRefreshingDirection:(MSRefreshDirection)direction {
    [self finishRefreshingDirection:direction animated:NO];
}

#warning 这个方法太大，是否可以拆分 ?
- (void)finishRefreshingDirection:(MSRefreshDirection)direction animated:(BOOL)animated {
    
    if ([_refreshMode[direction] integerValue] == MSDoNotTriggerRefresh) {
        return;
    }
    id<MSPullToRefreshDelegate> delegate = [self delegateWithDirection:direction];
#warning 这里代码有错误 didEndRefreshDirection VS willEndRefreshDirection
    if ([delegate respondsToSelector:@selector(pullToRefreshController:didEndRefreshDirection:)]) {
        [delegate pullToRefreshController:self willEndRefreshDirection:direction];
    }
    
    CALayer *presentationLayer = _scrollView.layer.presentationLayer;
    UIEdgeInsets contentInset = _scrollView.contentInset;
    MSRefreshingDirections refreshingDirection = MSRefreshingDirectionNone;
    // 宽度和高度均取 frame 和 contentSize 的较大值
    CGFloat adjustedSizeWidth = (_scrollView.contentSize.width > _scrollView.frame.size.width)?
    _scrollView.contentSize.width : _scrollView.frame.size.width;
    CGFloat adjustedSizeHeigth = (_scrollView.contentSize.height > _scrollView.frame.size.height)?
    _scrollView.contentSize.height : _scrollView.frame.size.height;
    
#warning [_canFinish[direction] boolValue] 可以先取出来.
#warning 下面要做的事情实际上是恢复原位.
    switch (direction) {
        case MSRefreshDirectionTop:
            refreshingDirection = MSRefreshingDirectionTop;
            contentInset = UIEdgeInsetsMake([_originalContentInsets[direction] UIEdgeInsetsValue].top,
                                            contentInset.left,
                                            contentInset.bottom,
                                            contentInset.right);
            /*
             tableview reloadData 时会回弹到当前的 ContentInset 处，如果此时手指未松开，会出现闪跳的问题
             本处设置 contentOffset 防止闪跳
             */
            if (presentationLayer.bounds.origin.y < -contentInset.top &&
                ![_canFinish[direction] boolValue]) {
                [_scrollView setContentOffset:CGPointMake(presentationLayer.bounds.origin.x,
                                                          presentationLayer.bounds.origin.y)];
            }
            break;
        case MSRefreshDirectionLeft:
            refreshingDirection = MSRefreshingDirectionLeft;
            contentInset = UIEdgeInsetsMake(contentInset.top,
                                            [_originalContentInsets[direction] UIEdgeInsetsValue].left,
                                            contentInset.bottom,
                                            contentInset.right);
            if (presentationLayer.bounds.origin.x < -contentInset.left &&
                ![_canFinish[direction] boolValue]) {
                [_scrollView setContentOffset:CGPointMake(presentationLayer.bounds.origin.x,
                                                          presentationLayer.bounds.origin.y)];
            }
            break;
        case MSRefreshDirectionBottom:
            refreshingDirection = MSRefreshingDirectionBottom;
            contentInset = UIEdgeInsetsMake(contentInset.top,
                                            contentInset.left,
                                            [_originalContentInsets[direction] UIEdgeInsetsValue].bottom,
                                            contentInset.right);

            if ((presentationLayer.bounds.origin.y +
                 _scrollView.frame.size.height - adjustedSizeHeigth > contentInset.bottom) &&
                ![_canFinish[direction] boolValue]) {

                [_scrollView setContentOffset:CGPointMake(presentationLayer.bounds.origin.x,
                                                          presentationLayer.bounds.origin.y)];
            }
            break;
        case MSRefreshDirectionRight:
            refreshingDirection = MSRefreshingDirectionRight;
            contentInset = UIEdgeInsetsMake(contentInset.top,
                                            contentInset.left,
                                            contentInset.bottom,
                                            [_originalContentInsets[direction] UIEdgeInsetsValue].right);

            if ((presentationLayer.bounds.origin.x +
                 _scrollView.frame.size.width - adjustedSizeWidth > contentInset.right) &&
                ![_canFinish[direction] boolValue]) {
                
                [_scrollView setContentOffset:CGPointMake(presentationLayer.bounds.origin.x,
                                                          presentationLayer.bounds.origin.y)];
            }
            break;
        default:
            break;
    }
    
#warning 下面没看明白....
    self.logicRefreshFinished[direction] = [NSNumber numberWithBool:YES];
    
    if (![_insetAnimationFinished[direction] boolValue] ||
        ![_canFinish[direction] boolValue]) {
        return;
    }
    
    self.logicRefreshFinished[direction] = [NSNumber numberWithBool:NO];
    self.insetAnimationFinished[direction] = [NSNumber numberWithBool:NO];
    
    [_scrollView setContentOffset:CGPointMake(presentationLayer.bounds.origin.x,
                                              presentationLayer.bounds.origin.y) animated:NO];
    
#warning 下面的代码可以封装成为一个方法.
    if (animated) {
        @weakify(self)
        [UIView animateWithDuration:.25
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^() {
                             @strongify(self)
                             self.scrollView.contentInset = contentInset;
                         }
                         completion:^(BOOL finished) {
                         }];
    } else {
        self.scrollView.contentInset = contentInset;
    }
    
    if ([delegate respondsToSelector:@selector(pullToRefreshController:didEndRefreshDirection:)]) {
        [delegate pullToRefreshController:self didEndRefreshDirection:direction];
    }
    self.refreshingDirections &= ~refreshingDirection;
}



#pragma mark - Setter & Getter



#pragma mark - Private Methods

/*!
 When the ScrollView's contentOffset changed,check if the refresh stage should
 change on the specified direction.
 
 @param direction The direction to be checked whether should change the refresh stage.
 @param delegate  Delegate to recieve callbacks.
 */
- (void)_checkOffsetsForDirection:(MSRefreshDirection)direction
                         delegate:(id<MSPullToRefreshDelegate>)delegate {
    // Check if canFinish should change on specified direction.
#warning 这个方法太别扭了. 而且这个方法与上面的变量定义都无关，可以提前调用. 包括下面的refreshingDirection的判断...
    [self judgeCanFinish:direction];
    
    // If the specified direction is currently refreshing, do not need to caculate more.
    MSRefreshingDirections refreshingDirection = 1 << direction;
    if (self.refreshingDirections & refreshingDirection) {
        return;
    }
    
    
    // Define some local variables.
    CALayer *presentaionLayer = _scrollView.layer.presentationLayer;
    // Refresh sequence information.
    MSRefreshableDirections refreshableDirection = 1 << direction;
    UIEdgeInsets contentInset = _scrollView.contentInset;
    BOOL canEngage = NO; // If scroll across the refreshable inset.
    BOOL reachEdge = NO; // Whether the scrollView's content reach edges.
    CGFloat percent = 0.0;
    
#warning 在这之前的    UIEdgeInsets contentInset = _scrollView.contentInset; 可以合成一句.
    // Calculate refresh informations.
    contentInset = [self calculateCanEngage:&canEngage reachEdges:&reachEdge
                                   percent:&percent direction:direction
                                  delegate:delegate];
    // Notify the dragging percent.
    if ([delegate respondsToSelector:@selector(pullToRefreshController:
                                               refreshPercentChanged:
                                               offset:
                                               direction:)]) {
        [delegate pullToRefreshController:self
                    refreshPercentChanged:percent
                                   offset:presentaionLayer.bounds.origin.y
                                direction:direction];
    }
    
    // Notify content has reached the edges of scrollview.
#warning reachEdge和前面的条件可以合并.
    if ([_refreshMode[direction] integerValue] == MSDoNotTriggerRefresh) {
        if (reachEdge &&
            [delegate respondsToSelector:@selector(pullToRefreshController:
                                                   didReachEdgeDirection:)]) {
            [delegate pullToRefreshController:self didReachEdgeDirection:direction];
        }
        return;
    }

#warning 建议self.refreshableDirections & refreshableDirection 弄成一个更清晰的表达式描述, 原因：多处使用，且表意不直接.
#warning if-else层级太多了一点，尽量改进.
    // Only go in here if the refreshmode for the specified direction is MSDraggingTriggerRefresh.
    if (canEngage) {
        // only go in here if user pulled past the inflection offset
        if (!_scrollView.dragging && _scrollView.decelerating &&
            (self.refreshableDirections & refreshableDirection)) {
            /*
             If you are decelerating, it means you've stopped dragging,
             but it doesnot mean _scrollView.dragging is NO.
             */
            self.refreshingDirections |= refreshingDirection;
            self.refreshableDirections &= ~refreshableDirection;
            self.originalContentInsets[direction] = [NSValue valueWithUIEdgeInsets:_scrollView.contentInset];
            
            // For smooth view changing cause by contentOffset's change.
            self.logicRefreshFinished[direction] = [NSNumber numberWithBool:NO];
            self.insetAnimationFinished[direction] = [NSNumber numberWithBool:NO];
            // Need call this before adjustContentInset.
            if ([delegate respondsToSelector:@selector(pullToRefreshController:
                                                       didEngageRefreshDirection:)]) {
                [delegate pullToRefreshController:self didEngageRefreshDirection:direction];
            }
            // Adjust contentInset
            [self adjustContentInset:contentInset direction:direction];
        } else if (!(self.refreshableDirections & refreshableDirection)) {
            // Only go in here the first time you've dragged past releasable offset
            self.refreshableDirections |= refreshableDirection;
            
            if ([delegate respondsToSelector:@selector(pullToRefreshController:
                                                       canEngageRefreshDirection:)]) {
                [delegate pullToRefreshController:self canEngageRefreshDirection:direction];
            }
        }
    } else if ((self.refreshableDirections & refreshableDirection) ) {
        // if you're here it means you've crossed back from the releasable offset
        self.refreshableDirections &= ~refreshableDirection;
        
        if ([delegate respondsToSelector:@selector(pullToRefreshController:
                                                   didDisengageRefreshDirection:)]) {
            [delegate pullToRefreshController:self didDisengageRefreshDirection:direction];
        }
    }
}

/*!
 Adjust the contentInset of scrollView. To get smooth view scrolling.
 
 @param contentInset The contentInset to be set to scrollView.
 @param direction    Which direction, used to set the insetAnimationFinished.
 */
- (void)adjustContentInset:(UIEdgeInsets)contentInset direction:(MSRefreshDirection)direction {
    /*
     First set the contentOffset to presentationLayer.bounds.origin,
     and this can avoid the bounce flash bug in SVPullToRefresh Lib.
     */
    CALayer *presentationLayer = _scrollView.layer.presentationLayer;
    [_scrollView setContentOffset:CGPointMake(presentationLayer.bounds.origin.x,
                                              presentationLayer.bounds.origin.y) animated:NO];
    // Set the scrollView's contentInset animated.
    @weakify(self)
    [UIView animateWithDuration:0.25
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         @strongify(self)
                         self.scrollView.contentInset = contentInset;
                     }
                     completion:^(BOOL finished){
                         @strongify(self)
                         self.insetAnimationFinished[direction] = [NSNumber numberWithBool:YES];
                         
                         if ([self.logicRefreshFinished[direction] boolValue] &&
                             [self.canFinish[direction] boolValue]) {
                             [self finishRefreshingDirection:direction animated:YES];
                         }
                     }];
}

/*!
 判断给定方向上 canFinish 是否应该改变
 
 @param direction Specified direction.
 */
- (void)judgeCanFinish:(MSRefreshDirection)direction {
    CALayer *modelLayer = _scrollView.layer.modelLayer;
    UIEdgeInsets contentInset = _scrollView.contentInset;
    BOOL insetAnimationFinished = [_insetAnimationFinished[direction] boolValue];
    BOOL logicRefreshFinished = [_logicRefreshFinished[direction] boolValue];
    /*
     Can not observe presentationlayer.
     Must use modelLayer here. May be presentationLayer is still < -contentInset.top, but,
     contentOffset is already equal to contentInset.top. So the contentOffset will not change,
     and this judgement can not be checked. So dead lock happens.
     */
    switch (direction) {
        case MSRefreshDirectionTop:
            if (modelLayer.bounds.origin.y < -contentInset.top - 0.001) {
                _canFinish[direction] = [NSNumber numberWithBool:NO];
            } else if (modelLayer.bounds.origin.y > -contentInset.top + 0.001) {
                _canFinish[direction] = [NSNumber numberWithBool:YES];
#warning 这个方法里面做的事情太多了，finishRefreshingDirection建议不要在这个方法里调用.
#warning 建议更改方式: 1. finishRefreshingDirection是否调用的判断放到外面去; 2. 这个方法直接返回一个BOOL值然后拿到这个BOOL值后再去设置指定方向的_canFinish. 例如这个方法变成 -(BOOL)canFinish:(MSRefreshDirection)direction;
                if (insetAnimationFinished && logicRefreshFinished) {
                    [self finishRefreshingDirection:direction animated:YES];
                }
            } else {
                if (_scrollView.dragging) {
                    _canFinish[direction] = [NSNumber numberWithBool:NO];
                } else {
                    _canFinish[direction] = [NSNumber numberWithBool:YES];
                    if (insetAnimationFinished && logicRefreshFinished) {
                        [self finishRefreshingDirection:direction animated:YES];
                    }
                }
            }
            break;
        case MSRefreshDirectionLeft:
            if (modelLayer.bounds.origin.x < -contentInset.left - 0.001) {
                _canFinish[direction] = [NSNumber numberWithBool:NO];
            } else if (modelLayer.bounds.origin.x > -contentInset.left + 0.001) {
                _canFinish[direction] = [NSNumber numberWithBool:YES];
                if (insetAnimationFinished && logicRefreshFinished) {
                    [self finishRefreshingDirection:direction animated:YES];
                }
            } else {
                if (_scrollView.dragging) {
                    _canFinish[direction] = [NSNumber numberWithBool:NO];
                } else {
                    _canFinish[direction] = [NSNumber numberWithBool:YES];
                    if (insetAnimationFinished && logicRefreshFinished) {
                        [self finishRefreshingDirection:direction animated:YES];
                    }
                }
            }
            break;
        case MSRefreshDirectionBottom:
            _canFinish[direction] = [NSNumber numberWithBool:YES];
            break;
        case MSRefreshDirectionRight:
            _canFinish[direction] = [NSNumber numberWithBool:YES];
            break;
    }
}

/*!
 ContentOffset 变化时计算与刷新操作有关的参数
 
 @param canEngage 是否松手即可执行刷新.
 @param reachEdge content 是否滚动到 scrollView 的边缘.
 @param percent   拖拽距离与 refreshableInset 的比例.
 @param direction 给定的方向(不同方向判别条件不同).
 @param delegate  提供 refreshableInset 等参数的 RefreshView.
 
 @return 为满足刷新操作需设置的 contentInset.
 */
- (UIEdgeInsets)calculateCanEngage:(BOOL *)canEngage
                        reachEdges:(BOOL *)reachEdge
                           percent:(CGFloat *)percent
                         direction:(MSRefreshDirection)direction
                          delegate:(id<MSPullToRefreshDelegate>)delegate {
    
    CALayer *presentaionLayer = _scrollView.layer.presentationLayer? _scrollView.layer.presentationLayer : _scrollView.layer;
    UIEdgeInsets contentInset = _scrollView.contentInset;
    CGFloat refreshableInset = [delegate pullToRefreshController:self refreshableInsetForDirection:direction];
    CGFloat refreshingInset = [delegate pullToRefreshController:self refreshingInsetForDirection:direction];
    CGFloat promptingInset = [delegate pullToRefreshController:self promptingInsetForDirection:direction];

    switch (direction) {
        case MSRefreshDirectionTop:
            if (presentaionLayer.bounds.origin.y < -contentInset.top && refreshableInset != 0) {
                *percent = (-presentaionLayer.bounds.origin.y - contentInset.top) / refreshableInset;
            }
            *canEngage = presentaionLayer.bounds.origin.y < (-refreshableInset - contentInset.top);
            contentInset = UIEdgeInsetsMake(contentInset.top + refreshingInset,
                                            contentInset.left,
                                            contentInset.bottom,
                                            contentInset.right);
            break;
        case MSRefreshDirectionLeft:
            if (presentaionLayer.bounds.origin.x < -contentInset.left &&
                (refreshableInset > 0.000001 || refreshableInset < -0.000001)) {
                *percent = (-presentaionLayer.bounds.origin.x - contentInset.left) / refreshableInset;
            }
            *canEngage = presentaionLayer.bounds.origin.x < (-refreshableInset - contentInset.left);
            contentInset = UIEdgeInsetsMake(contentInset.top,
                                            contentInset.left + refreshingInset,
                                            contentInset.bottom,
                                            contentInset.right);
            break;
        case MSRefreshDirectionBottom:
            if ((presentaionLayer.bounds.origin.y + _scrollView.frame.size.height -
                 _scrollView.contentSize.height) > contentInset.bottom &&
                (refreshableInset > 0.000001 || refreshableInset < -0.000001)) {
                // Calculate the percent.
                *percent = (presentaionLayer.bounds.origin.y + _scrollView.frame.size.height -
                            _scrollView.contentSize.height - contentInset.bottom) / refreshableInset;
            }
            *canEngage = (presentaionLayer.bounds.origin.y + _scrollView.frame.size.height -
                          _scrollView.contentSize.height) > (refreshableInset + contentInset.bottom);
            *reachEdge = (presentaionLayer.bounds.origin.y +
                          _scrollView.frame.size.height -
                          _scrollView.contentSize.height) > (contentInset.bottom - promptingInset);

            contentInset = UIEdgeInsetsMake(contentInset.top,
                                            contentInset.left,
                                            refreshingInset + contentInset.bottom,
                                            contentInset.right);
            break;
        case MSRefreshDirectionRight:
            if ((presentaionLayer.bounds.origin.x + _scrollView.frame.size.width -
                _scrollView.contentSize.width) > contentInset.right &&
                (refreshableInset > 0.000001 || refreshableInset < -0.000001)) {
                // Calculate the percent.
                *percent = (presentaionLayer.bounds.origin.x + _scrollView.frame.size.width -
                            _scrollView.contentSize.width - contentInset.right) / refreshableInset;
            }
            *canEngage = (presentaionLayer.bounds.origin.x + _scrollView.frame.size.width -
                          _scrollView.contentSize.width) > (refreshableInset + contentInset.right);
            *reachEdge = (presentaionLayer.bounds.origin.x +
                          _scrollView.frame.size.width -
                          _scrollView.contentSize.width) > (contentInset.right - promptingInset);
            contentInset = UIEdgeInsetsMake(contentInset.top,
                                            contentInset.left,
                                            contentInset.bottom,
                                            refreshingInset + contentInset.right);
            break;
    }
    return contentInset;
}


#pragma mark - Setter & Getter

- (void)setRefreshMode:(HTTriggerLoadMoreMode)loadMoreMode
             direction:(HTRefreshDirection)direction {
    switch (loadMoreMode) {
        case HTTriggerLoadMoreModeDoNotTrigger:
        case HTTriggerLoadMoreModeAutoTrigger:
            _refreshMode[direction] = [NSNumber numberWithInteger:MSDoNotTriggerRefresh];
            break;
        case HTTriggerLoadMoreModeDraggingTrigger:
            _refreshMode[direction] = [NSNumber numberWithInteger:MSDraggingTriggerRefresh];
            break;
    }
}


@end
