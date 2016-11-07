//
//  HTTopLeftRefreshView.m
//  HTUI
//
//  Created by Bai_tianyu on 9/10/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "HTTopLeftRefreshView.h"
#import "UIScrollView+MSControllerAssociation.h"
#import "HTRefreshViewLogger.h"
#import "ReactiveCocoa.h"
#import "RACEXTScope.h"


@interface HTTopLeftRefreshView ()  <MSPullToRefreshDelegate>

/// 是否可调整 contentSize
@property (nonatomic, assign) BOOL canAdjustContentSize;

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

@implementation HTTopLeftRefreshView

#pragma mark - HTRefreshView Life Cycle.

- (id)initWithScrollView:(UIScrollView *)scrollView direction:(HTRefreshDirection)direction
        followScrollView:(BOOL)follow {
    return [self initWithScrollView:scrollView
                          direction:direction
                   followScrollView:follow
                     followDistance:0.0];
}

- (id)initWithScrollView:(UIScrollView *)scrollView direction:(HTRefreshDirection)direction
        followScrollView:(BOOL)follow followDistance:(CGFloat)distance {
    if (self = [super init]) {
        // If direction is valid.
        if ((direction != HTRefreshDirectionTop) && (direction != HTRefreshDirectionLeft)) {
            HTRefreshViewLogError(@"HTTopLeftRefreshView:Invalid Direction");
            return nil;
        }
        
        // Assignment
        self.refreshDirection = direction;
        self.scrollView = scrollView;
        self.followScrollView = follow;
        self.followDistance = distance;
        self.refreshEnabled = YES;
        self.canAdjustContentSize = YES;
        
        [self loadSubViews];

        // Check if the scrollView already had an MSPullToRefreshController.
#warning scrollView只有一个refreshController并且这个refreshController维护了不止一个delegate; 每一个方向上有一个delegate.
#warning ? 这里为什么要将refreshController存在scrollView那里？是因为ScrollView与RefreshController是一对一？我觉得这个持有关系比较难理解
        self.msRefreshController = [scrollView ht_getMSPullToRefreshController];
        if (!self.msRefreshController) {
            self.msRefreshController = [[MSPullToRefreshController alloc] initWithScrollView:scrollView
                                                                                    delegate:self
                                                                                   direction:(int)direction];
            [scrollView ht_setMSPullToRefreshController:self.msRefreshController];
        } else {
            [self.msRefreshController setDelegate:self withDirection:(int)direction];
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
    // Need user rewrite this method in HTTopLeftRefreshView's subclass.
}

- (void)layoutSubviews {
    self.scrollView.contentSize = self.scrollView.contentSize;
    [super layoutSubviews];
}


#pragma mark - Public methods.

#warning 用于程序自动刷新.
- (void)startRefresh:(BOOL)animated {
    [self.msRefreshController startRefreshingDirection:(int)self.refreshDirection
                                          delegate:self
                                          animated:animated];
}

- (void)endRefresh:(BOOL)animated {
    [self.msRefreshController finishRefreshingDirection:(int)self.refreshDirection animated:animated];
}

- (void)addRefreshingHandler:(refreshHandler)block {
    self.refreshingHandler = block;
}



#pragma mark - KVO

- (void)contentSizeChanged {
    // 调整 contentSize
    CGSize newContentSize = self.scrollView.contentSize;
    // 调整宽度
    CGFloat beforeAdjustedSizeWidth = self.scrollView.frame.size.width -
                                        self.originalContentInset.left -
                                        self.originalContentInset.right;
    CGFloat adjustedSizeWidth = (newContentSize.width > beforeAdjustedSizeWidth)?
    newContentSize.width :
    beforeAdjustedSizeWidth;
    // 调整高度
    CGFloat beforeAdjustedSizeHeight = self.scrollView.frame.size.height -
                                         self.originalContentInset.top -
                                         self.originalContentInset.bottom;
    CGFloat adjustedSizeHeigth = (newContentSize.height > beforeAdjustedSizeHeight)?
    newContentSize.height :
    beforeAdjustedSizeHeight;
    
    CGSize adjustedContentSize = CGSizeMake(adjustedSizeWidth, adjustedSizeHeigth);
    if (_canAdjustContentSize && self.originalContentInsetSetted) {
        self.canAdjustContentSize = NO;
        [self.scrollView setContentSize:adjustedContentSize];
        self.canAdjustContentSize = YES;
    }
    
    // 调整 RefreshView 的位置
    CGFloat originX = (self.refreshDirection == HTRefreshDirectionTop)? 0 : (-self.bounds.size.width - self.followDistance);
    CGFloat originY = (self.refreshDirection == HTRefreshDirectionLeft)? 0 : (-self.bounds.size.height - self.followDistance);
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
#warning const变量或者宏定义说明一下这个值.
        return -1.0;
    }

    CGFloat refreshableInset = 0.0;
    // If the user gives the refreshableInset.
    if ([self respondsToSelector:@selector(refreshableInset)]) {
        // Use the refreshableInset getting from user.
        refreshableInset = [self refreshableInset];
    } else {
        // Use the default value.
        switch (direction) {
            case HTRefreshDirectionTop:
            case HTRefreshDirectionBottom:
                refreshableInset = self.bounds.size.height;
                break;
            case HTRefreshDirectionLeft:
            case HTRefreshDirectionRight:
                refreshableInset = self.bounds.size.width;
                break;
        }
     }
    
#warning 加下说明
    if (refreshableInset < 0.000001 || refreshableInset > -0.000001) {
        refreshableInset += 0.000001;
    }
    return refreshableInset;
}

- (CGFloat)pullToRefreshController:(MSPullToRefreshController *)controller
       refreshingInsetForDirection:(MSRefreshDirection)direction {
    // If parameters are valid.
    if (![self checkController:controller direction:direction]) {
        return -1.0;
    }
    
    CGFloat refreshingInset = 0.0;
    // If the user give the refreshingInset.
    if ([self respondsToSelector:@selector(refreshingInset)]) {
        // Use the refreshableInset getting from user.
        refreshingInset = [self refreshingInset];
    } else {
        // Use the default value.
        switch (direction) {
            case HTRefreshDirectionTop:
                refreshingInset = self.bounds.size.height;
                break;
            case HTRefreshDirectionLeft:
                refreshingInset = self.bounds.size.width;
                break;
            case HTRefreshDirectionBottom:
            case HTRefreshDirectionRight:
                refreshingInset = 0.0;
                break;
        }
    }
    if (refreshingInset < 0.000001 || refreshingInset > -0.000001) {
        refreshingInset += 0.000001;
    }
    return refreshingInset;
}

- (CGFloat)pullToRefreshController:(MSPullToRefreshController *)controller
        promptingInsetForDirection:(MSRefreshDirection)direction {
    return 0.0;
}

- (void)pullToRefreshController:(MSPullToRefreshController *)controller
      canEngageRefreshDirection:(MSRefreshDirection)direction {
    // If parameters are valid.
    if (![self checkController:controller direction:direction]) {
        return;
    }
    
    if (self.refreshEnabled && [self respondsToSelector:@selector(refreshStateChanged:)]) {
        [self refreshStateChanged:HTRefreshStateCanEngageRefresh];
    }
}

- (void)pullToRefreshController:(MSPullToRefreshController *)controller
      didEngageRefreshDirection:(MSRefreshDirection)direction {
    // If parameters are valid.
    if (![self checkController:controller direction:direction]) {
        return;
    }
    
    if (self.refreshEnabled) {
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
    
    if (self.refreshEnabled && [self respondsToSelector:@selector(refreshStateChanged:)]) {
        [self refreshStateChanged:HTRefreshStateDidDisengageRefresh];
    }
}

- (void)pullToRefreshController:(MSPullToRefreshController *)controller
        willEndRefreshDirection:(MSRefreshDirection)direction {
    // If parameters are valid.
    if (![self checkController:controller direction:direction]) {
        return;
    }
    if (self.refreshEnabled && [self respondsToSelector:@selector(refreshStateChanged:)]) {
        [self refreshStateChanged:HTRefreshStateWillEndRefresh];
    }
}

- (void)pullToRefreshController:(MSPullToRefreshController *)controller
         didEndRefreshDirection:(MSRefreshDirection)direction {
    // If parameters are valid.
    if (![self checkController:controller direction:direction]) {
        return;
    }
    
    if (self.refreshEnabled && [self respondsToSelector:@selector(refreshStateChanged:)]) {
        [self refreshStateChanged:HTRefreshStateDidEndRefresh];
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
    
    if (self.refreshEnabled && [self respondsToSelector:@selector(refreshPercentChanged:offset:direction:)]) {
        [self refreshPercentChanged:percent offset:offset direction:(HTRefreshDirection)direction];
    }
}



#pragma mark - Setter & Getter



#pragma mark - Private methods.

- (void)addRefreshViewToScrollView:(UIScrollView *)scrollView {
    [scrollView addSubview:self];
    @weakify(self)
    [RACObserve(self.scrollView, contentSize) subscribeNext:^(id x) {
        @strongify(self)
//#warning 监控contentSize. TODO: 可以删除.
        [self contentSizeChanged];
    }];
}

- (BOOL)checkController:(MSPullToRefreshController *)controller direction:(MSRefreshDirection)direction {
    if (controller != self.msRefreshController || (int)direction != (int)self.refreshDirection) {
        HTRefreshViewLogError(@"HTTopLeftRefreshView: Wrong parameters in delegate methods.");
        return NO;
    }
    return YES;
}


@end