//
//  HTRefreshView.m
//  HTUI
//
//  Created by Bai_tianyu on 9/14/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "HTRefreshView.h"
#import "HTRefreshViewLogger.h"
#import "UIScrollView+MSControllerAssociation.h"

@interface HTRefreshView ()

@end

@implementation HTRefreshView

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
        // Do nothing.
        // SubClasses can rewrite this method to do something.
    }
    return self;
}



#pragma mark - Public methods.

- (void)startRefresh:(BOOL)animated {
    // Do nothing.
    // SubClasses can rewrite this method to do something.
}

- (void)endRefresh:(BOOL)animated {
    // Do nothing.
    // SubClasses can rewrite this method to do something.
}

- (void)loadSubViews {
    // Do nothing.
    // Need user rewrite this method in HTTopLeftRefreshView's subclass.
}

- (void)addRefreshingHandler:(refreshHandler)block {
    // Do nothing.
    // SubClasses can rewrite this method to do something.
}



#pragma mark - Setter & Getter

- (void)setRefreshEnabled:(BOOL)refreshEnabled {
    _refreshEnabled = refreshEnabled;
}

- (void)setOriginalContentInset:(UIEdgeInsets)originalContentInset {
    _originalContentInset = originalContentInset;
    _originalContentInsetSetted = YES;
    // In order to call KVO.(Can trigger KVO)
    _scrollView.contentSize = _scrollView.contentSize;
}

@end