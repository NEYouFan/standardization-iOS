//
//  HTBottomRightRefreshView.m
//  HTUI
//
//  Created by Bai_tianyu on 9/10/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "HTBottomRightRefreshView.h"
#import "UIScrollView+MSControllerAssociation.h"
#import "HTRefreshViewLogger.h"
#import "ReactiveCocoa.h"
#import "RACEXTScope.h"

@interface HTBottomRightRefreshView () <MSPullToRefreshDelegate>
/// 是否可调整 contentSize
@property (nonatomic, assign) BOOL canAdjustContentSize;
/// 是否调整了 contentInset，为了适配添加该属性
@property (nonatomic, assign) BOOL isContentInsetAdjusted;

/*!
 将 HTRefreshView 添加到 ScrollView 上
 
 @param scrollView 标明添加刷新功能到哪个 UIScrollView。
 */
- (void)addRefreshViewToScrollView:(UIScrollView *)scrollView;

/*!
 检测发送消息的 controller 和 消息作用的刷新方向是否合法
 
 @param controller 发送消息的 controller
 @param direction  刷新方向
 
 @return YES: 合法；
          NO: 不合法。
 */
- (BOOL)checkController:(MSPullToRefreshController *)controller
              direction:(MSRefreshDirection)direction;

@end


@implementation HTBottomRightRefreshView

#pragma mark - HTRefreshView Life Cycle.

- (id)initWithScrollView:(UIScrollView *)scrollView
               direction:(HTRefreshDirection)direction
        followScrollView:(BOOL)follow
          followDistance:(CGFloat)distance {

    if (self = [super initWithScrollView:scrollView
                               direction:direction
                        followScrollView:follow
                          followDistance:distance]) {
        // Check if the direction is valid.
        if ((direction != HTRefreshDirectionBottom) && (direction != HTRefreshDirectionRight)) {
            HTRefreshViewLogError(@"HTBottomRightRefreshView:Invalid Direction");
            return nil;
        }

        // Check if the scrollView already had an MSPullToRefreshController.
        if (!(self.msRefreshController = [scrollView ht_getMSPullToRefreshController])) {
            self.msRefreshController = [[MSPullToRefreshController alloc] initWithScrollView:scrollView
                                                                                    delegate:self
                                                                                   direction:(int)direction];
            [scrollView ht_setMSPullToRefreshController:self.msRefreshController];
        } else {
            [self.msRefreshController setDelegate:self withDirection:(MSRefreshDirection)direction];
        }

        // Assignment
        self.refreshDirection = direction;
        self.scrollView = scrollView;
        self.followScrollView = follow;
        self.followDistance = distance;
        self.refreshEnabled = NO;
        self.isRefreshing = NO;
        self.triggerLoadMoreMode = HTTriggerLoadMoreModeAutoTrigger;
        self.canAdjustContentSize = YES;
        [self loadSubViews];
        
        if ([self respondsToSelector:@selector(promptingInfoInset)]) {
            self.promptingInset = [self promptingInfoInset];
        } else {
            self.promptingInset = -1.0;
        }
        if (follow) {
            [self addRefreshViewToScrollView:scrollView];
        }
    }
    return self;
}



#pragma mark - Load Views.

- (void)loadSubViews {
    // do nothing.
    // Need user rewrite this method in HTTopLeftRefreshView's or HTBottomRightRefreshView's subclass.
}

- (void)layoutSubviews {
    self.scrollView.contentSize = self.scrollView.contentSize;
    [super layoutSubviews];
}


#pragma mark - Public methods.

- (void)startRefresh:(BOOL)animated {
    if (self.refreshEnabled && !_isRefreshing) {
        self.isRefreshing = YES;
        if (self.triggerLoadMoreMode == HTTriggerLoadMoreModeDraggingTrigger) {
            [self.msRefreshController startRefreshingDirection:(int)self.refreshDirection
                                                  delegate:self
                                                  animated:animated];
        }
    }
}

- (void)endRefresh:(BOOL)animated {
    if (_triggerLoadMoreMode == HTTriggerLoadMoreModeDraggingTrigger) {
        [self.msRefreshController finishRefreshingDirection:(int)self.refreshDirection animated:animated];
    } else if ([self respondsToSelector:@selector(refreshStateChanged:)]) {
        [self refreshStateChanged:HTRefreshStateDidEndRefresh];
    }
    self.isRefreshing = NO;
}

- (void)addRefreshingHandler:(refreshHandler)block {
    self.refreshingHandler = block;
}



#pragma mark - KVO

- (void)contentSizeChanged {
    // 调整 contentSize ()
    CGSize newContentSize = self.scrollView.contentSize;
    // 调整宽度
    CGFloat beforeAdjustedSizeWidth = self.scrollView.frame.size.width -
                                        self.originalContentInset.left - self.originalContentInset.right;
    CGFloat adjustedSizeWidth = (newContentSize.width > beforeAdjustedSizeWidth)?
                                                   newContentSize.width :
                                                 beforeAdjustedSizeWidth;
    // 调整高度
    CGFloat beforeAdjustedSizeHeight = self.scrollView.frame.size.height -
                                           self.originalContentInset.top - self.originalContentInset.bottom;
    CGFloat adjustedSizeHeigth = (newContentSize.height > beforeAdjustedSizeHeight)?
                                                     newContentSize.height :
                                                   beforeAdjustedSizeHeight;
    
    CGSize adjustedContentSize = CGSizeMake(adjustedSizeWidth, adjustedSizeHeigth);
    if (_canAdjustContentSize && self.originalContentInsetSetted) {
        // 这里使用 originalContentInsetSetted 为了确定只有在设置 originalContentInset 后才应该调整 contentSize
        self.canAdjustContentSize = NO;
        [self.scrollView setContentSize:adjustedContentSize];
        self.canAdjustContentSize = YES;
    }

    // 调整 contentInset
    UIEdgeInsets newContentInset = UIEdgeInsetsZero;
    switch (self.refreshDirection) {
        case HTRefreshDirectionBottom: {
            if (newContentSize.height > beforeAdjustedSizeHeight || _alwaysShowRefreshView) {
                self.hidden = _hiddenRefresh;
                self.refreshEnabled = !_hiddenRefresh;
            } else {
                self.hidden = YES;
                self.refreshEnabled = NO;
            }
            if ((newContentSize.height > beforeAdjustedSizeHeight || _alwaysShowRefreshView) && !_isRefreshing) {
                // For other directions, must set to the current contentInset.
                newContentInset = UIEdgeInsetsMake(self.scrollView.contentInset.top,
                                                   self.scrollView.contentInset.left,
                                                   self.originalContentInset.bottom + self.promptingInset,
                                                   self.scrollView.contentInset.right);
                [UIView animateWithDuration:.25
                                      delay:0
                                    options:UIViewAnimationOptionCurveEaseOut
                                 animations:^{
                                     self.scrollView.contentInset = newContentInset;
                                 } completion:^(BOOL finished) {
                                     
                                 }];
                _isContentInsetAdjusted = YES;
            } else if (_isContentInsetAdjusted && !_isRefreshing) {
                // 如果刷新后数据变少了，那么应该将 contentInset 设为原有值(即去除 promptingInset)
                newContentInset = UIEdgeInsetsMake(self.scrollView.contentInset.top,
                                                   self.scrollView.contentInset.left,
                                                   self.originalContentInset.bottom,
                                                   self.scrollView.contentInset.right);
                [UIView animateWithDuration:.25
                                      delay:0
                                    options:UIViewAnimationOptionCurveEaseOut
                                 animations:^{
                                     self.scrollView.contentInset = newContentInset;
                                 } completion:^(BOOL finished) {
                                     
                                 }];
                _isContentInsetAdjusted = NO;
            }
        }
            break;
        case HTRefreshDirectionRight: {
            if (newContentSize.width > beforeAdjustedSizeWidth || _alwaysShowRefreshView) {
                self.hidden = _hiddenRefresh;
                self.refreshEnabled = !_hiddenRefresh;
            } else {
                self.hidden = YES;
                self.refreshEnabled = NO;
            }
            if ((newContentSize.width > beforeAdjustedSizeWidth || _alwaysShowRefreshView) && !_isRefreshing) {
                // For other directions, must set to the current contentInset.
                newContentInset = UIEdgeInsetsMake(self.scrollView.contentInset.top,
                                                   self.scrollView.contentInset.left,
                                                   self.scrollView.contentInset.bottom,
                                                   self.originalContentInset.right + self.promptingInset);
                [UIView animateWithDuration:.25
                                      delay:0
                                    options:UIViewAnimationOptionCurveEaseOut
                                 animations:^{
                                     self.scrollView.contentInset = newContentInset;
                                 } completion:^(BOOL finished) {
                                     
                                 }];
                _isContentInsetAdjusted = YES;
            } else if (_isContentInsetAdjusted && !_isRefreshing) {
                newContentInset = UIEdgeInsetsMake(self.scrollView.contentInset.top,
                                                   self.scrollView.contentInset.left,
                                                   self.originalContentInset.bottom,
                                                   self.scrollView.contentInset.right);
                [UIView animateWithDuration:.25
                                      delay:0
                                    options:UIViewAnimationOptionCurveEaseOut
                                 animations:^{
                                     self.scrollView.contentInset = newContentInset;
                                 } completion:^(BOOL finished) {
                                     
                                 }];
                _isContentInsetAdjusted = NO;
            }
        }
            break;
        case HTRefreshDirectionLeft:
        case HTRefreshDirectionTop:
            break;
    }

    // 调整 RefreshView 的位置
    CGFloat originX = (self.refreshDirection == HTRefreshDirectionBottom)? 0 :
    (adjustedSizeWidth + self.followDistance);
    
    CGFloat originY = (self.refreshDirection == HTRefreshDirectionRight)? 0 :
    (adjustedSizeHeigth + self.followDistance);
    
    CGRect refreshViewFrameRect = CGRectMake(originX, originY,
                                             self.bounds.size.width,
                                             self.bounds.size.height);
    self.frame = refreshViewFrameRect;
}



#pragma mark - MSPullToRefreshDelegate

- (BOOL)pullToRefreshController:(MSPullToRefreshController *)controller
          canRefreshInDirection:(MSRefreshDirection)direction {

    return ([self checkController:controller direction:direction] && self.refreshEnabled);
}

- (CGFloat)pullToRefreshController:(MSPullToRefreshController *)controller
      refreshableInsetForDirection:(MSRefreshDirection) direction {
    // If parameters are valid.
    if (![self checkController:controller direction:direction]) {
        return -1.0;
    }
    // Must be positive value.
    // If the user give the refreshableInset.
    CGFloat refreshableInset = 0.0;
    // If the user gives the refreshableInset.
    if ([self respondsToSelector:@selector(refreshableInset)]) {
        // Use the given value.
        refreshableInset = [self refreshableInset];
    } else {
        // Use the default value.
        switch (direction) {
            case HTRefreshDirectionTop:
            case HTRefreshDirectionBottom:
                refreshableInset = self.scrollView.bounds.size.height;
                break;
            case HTRefreshDirectionLeft:
            case HTRefreshDirectionRight:
                refreshableInset = self.scrollView.bounds.size.width;
        }
    }
    /* 
     因为 MS库中需要根据 refreshableInset 计算 percent，所以此处不能为 0
     此外，为了浮点数运算设置(MS库中有大量浮点数运算，如果此处设为0值，会引起bug)
     */
    if (refreshableInset < 0.000001 || refreshableInset > -0.000001) {
        refreshableInset += 0.001;
    }
    return refreshableInset;
}

- (CGFloat)pullToRefreshController:(MSPullToRefreshController *)controller
       refreshingInsetForDirection:(MSRefreshDirection)direction {
    // If parameters are valid.
    if (![self checkController:controller direction:direction]) {
        return -1.0;
    }
    // RefreshingInset can be negative, suggest that a refreshview is smaller than the refreshable Rect.
    // If the user give the refreshingInset.
    CGFloat refreshingInset = 0.0;
    if ([self respondsToSelector:@selector(refreshingInset)]) {
        refreshingInset = [self refreshingInset];
    }
    // 为了浮点数运算设置(MS库中有大量浮点数运算，如果此处设为0值，会引起bug)
    if (refreshingInset < 0.000001 || refreshingInset > -0.000001) {
        refreshingInset += 0.001;
    }
    return refreshingInset;
}

- (CGFloat)pullToRefreshController:(MSPullToRefreshController *)controller
        promptingInsetForDirection:(MSRefreshDirection)direction {
    // If parameters are valid.
    if (![self checkController:controller direction:direction]) {
        return -1.0;
    }

    CGFloat promptingInset = 0.0;
    if ([self respondsToSelector:@selector(promptingInset)]) {
        return [self promptingInset];
    } else {
        // Use the default value.
        switch (direction) {
            case HTRefreshDirectionTop:
            case HTRefreshDirectionBottom:
                promptingInset = self.scrollView.bounds.size.height;
                break;
            case HTRefreshDirectionLeft:
            case HTRefreshDirectionRight:
                promptingInset = self.scrollView.bounds.size.width;
                break;
        }
    }
    return promptingInset;
}

- (void)pullToRefreshController:(MSPullToRefreshController *)controller
      canEngageRefreshDirection:(MSRefreshDirection)direction {
    // If parameters are valid.
    if (![self checkController:controller direction:direction]) {
        return;
    }
    if (!_isRefreshing && self.refreshEnabled && (self.triggerLoadMoreMode == HTTriggerLoadMoreModeDraggingTrigger) &&
        [self respondsToSelector:@selector(refreshStateChanged:)]) {
        [self refreshStateChanged:HTRefreshStateCanEngageRefresh];
    }
}

- (void)pullToRefreshController:(MSPullToRefreshController *)controller
      didEngageRefreshDirection:(MSRefreshDirection)direction {
    // If parameters are valid.
    if (![self checkController:controller direction:direction]) {
        return;
    }
    if (self.refreshEnabled && !_isRefreshing && (_triggerLoadMoreMode == HTTriggerLoadMoreModeDraggingTrigger)) {
        self.isRefreshing = YES;
        if (self.refreshingHandler) {
            __weak HTRefreshView *weakSelf = self;
            self.refreshingHandler(weakSelf);
        }
        if ([self respondsToSelector:@selector(refreshStateChanged:)]) {
            [self refreshStateChanged:HTRefreshStateDidEngageRefresh];
        }
    }
}

- (void)pullToRefreshController:(MSPullToRefreshController *)controller
   didDisengageRefreshDirection:(MSRefreshDirection)direction {
    // If parameters are valid.
    if (![self checkController:controller direction:direction]) {
        return;
    }
    if (!_isRefreshing && self.refreshEnabled && (_triggerLoadMoreMode == HTTriggerLoadMoreModeDraggingTrigger) &&
        [self respondsToSelector:@selector(refreshStateChanged:)]) {
        [self refreshStateChanged:HTRefreshStateDidDisengageRefresh];
    }
}

- (void)pullToRefreshController:(MSPullToRefreshController *)controller
        willEndRefreshDirection:(MSRefreshDirection)direction {
    // If parameters are valid.
    if (![self checkController:controller direction:direction]) {
        return;
    }
    if (self.refreshEnabled && (_triggerLoadMoreMode == HTTriggerLoadMoreModeDraggingTrigger) &&
        [self respondsToSelector:@selector(refreshStateChanged:)]) {
        [self refreshStateChanged:HTRefreshStateWillEndRefresh];
    }
}

- (void)pullToRefreshController:(MSPullToRefreshController *)controller
         didEndRefreshDirection:(MSRefreshDirection)direction {
    // If parameters are valid.
    if (![self checkController:controller direction:direction]) {
        return;
    }
    if (self.refreshEnabled && (_triggerLoadMoreMode == HTTriggerLoadMoreModeDraggingTrigger) &&
        [self respondsToSelector:@selector(refreshStateChanged:)]) {
        self.isRefreshing = NO;
        [self refreshStateChanged:HTRefreshStateDidEndRefresh];
    }
}

- (void)pullToRefreshController:(MSPullToRefreshController *)controller
          didReachEdgeDirection:(MSRefreshDirection)direction {
    // If parameters are valid.
    if (![self checkController:controller direction:direction]) {
        return;
    }
    if (!_isRefreshing && self.refreshEnabled && _triggerLoadMoreMode == HTTriggerLoadMoreModeAutoTrigger &&
        self.originalContentInsetSetted) {
        self.isRefreshing = YES;
        if ([self respondsToSelector:@selector(refreshStateChanged:)]) {
            [self refreshStateChanged:HTRefreshStateCanEngageRefresh];
            [self refreshStateChanged:HTRefreshStateDidEngageRefresh];
        }
        if (self.refreshingHandler) {
            __weak HTRefreshView *weakSelf = self;
            self.refreshingHandler(weakSelf);
        }
    }
}

- (void)pullToRefreshController:(MSPullToRefreshController *)controller
          refreshPercentChanged:(CGFloat)percent
                         offset:(CGFloat)offset
                      direction:(MSRefreshDirection)direction {
    // If parameters are valid.
    if (![self checkController:controller direction:direction]) {
        return;
    }
    if (self.refreshEnabled && _triggerLoadMoreMode == HTTriggerLoadMoreModeDraggingTrigger &&
        [self respondsToSelector:@selector(refreshPercentChanged:offset:direction:)]) {
        [self refreshPercentChanged:percent offset:offset direction:(HTRefreshDirection)direction];
    }
}



#pragma mark - Setter & Getter

- (void)setTriggerLoadMoreMode:(HTTriggerLoadMoreMode)triggerLoadMoreMode {
    [self.msRefreshController setRefreshMode:triggerLoadMoreMode direction:self.refreshDirection];
    _triggerLoadMoreMode = triggerLoadMoreMode;
}

- (void)setPromptingInset:(CGFloat)promptingInset {
    // Must be nonnegative value.
    // If the user give the promptingInset.
    _promptingInset = promptingInset;
    if (promptingInset < 0.0) {
        switch (self.refreshDirection) {
            case HTRefreshDirectionBottom:
                _promptingInset = self.bounds.size.height;
                break;
            case HTRefreshDirectionRight:
                _promptingInset = self.bounds.size.width;
                break;
            case HTRefreshDirectionTop:
            case HTRefreshDirectionLeft:
                _promptingInset = 0.0;
                break;
        }
    }
    // In order to call KVO.
    self.scrollView.contentSize = self.scrollView.contentSize;
}

- (void)setHiddenRefresh:(BOOL)hiddenRefresh {
    _hiddenRefresh = hiddenRefresh;
    self.hidden = _hiddenRefresh;
    self.scrollView.contentSize = self.scrollView.contentSize;
}

- (void)setRefreshEnabled:(BOOL)refreshEnabled {
    [super setRefreshEnabled:refreshEnabled];
    if (!refreshEnabled) {
        _isRefreshing = NO;
    }
}



#pragma mark - Private methods.

- (void)addRefreshViewToScrollView:(UIScrollView *)scrollView {
    [scrollView addSubview:self];
    // 监听 contentSize，始终将 RefreshView 置于 ScrollView content 的最下方，两者距离为 distance
    @weakify(self)
    [RACObserve(self.scrollView, contentSize) subscribeNext:^(id x) {
        @strongify(self)
        [self contentSizeChanged];
    }];
}

- (BOOL)checkController:(MSPullToRefreshController *)controller
              direction:(MSRefreshDirection)direction {

    if (controller != self.msRefreshController || (int)direction != (int)self.refreshDirection) {
        HTRefreshViewLogError(@"HTBottomRightRefreshView: Wrong parameters in delegate methods.");
        return NO;
    }
    return YES;
}

@end