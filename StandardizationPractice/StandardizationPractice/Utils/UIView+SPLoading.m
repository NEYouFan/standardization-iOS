//
//  UIView+SPLoading.m
//  StandardizationPractice
//
//  Created by Baitianyu on 21/10/2016.
//  Copyright © 2016 Netease. All rights reserved.
//

#import "UIView+SPLoading.h"
#import "Masonry.h"
#import "SPLoadingView.h"
#import "SPLoadingEmptyView.h"
#import "SPLoadingColors.h"
#import <objc/runtime.h>

static char const *kLoadingKey;
static char const *kLoadingEmptyKey;
static char const *kLoadingErrorKey;
static char const *kRetryBlockKey;

@implementation UIView (SPLoading)

#pragma mark - Loading.

- (void)sp_showLoading {
    [self sp_showLoadingWithBackgroundColor:[SPLoadingColors defaultLoadingBackground]];
}

- (void)sp_showLoadingWithBackgroundColor:(UIColor *)backgroundColor {
    SPLoadingView *loadingView = [self sp_getLoadingView];
    loadingView.backgroundColor = backgroundColor;

    if (!loadingView.superview) {
        [self addSubview:loadingView];
    }
    [self bringSubviewToFront:loadingView];
    
    [loadingView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(self);
        make.center.equalTo(self);
    }];
    
    [loadingView startLoadingAnimation];
}

- (void)sp_hideLoading {
    [self sp_hideLoading:nil];
}

- (void)sp_hideLoading:(SPCompleteBlock)complete {
    SPLoadingView *loadingView = [self sp_getLoadingView];
    [UIView animateWithDuration:0.25
                     animations:^{
                         loadingView.alpha = 0;
                     } completion:^(BOOL finished) {
                         [loadingView stopLoadingAnimation];
                         if (loadingView.superview) {
                             [loadingView removeFromSuperview];
                             loadingView.alpha = 1;
                         }
                         if (complete) {
                             complete();
                         }
                     }];
}

- (SPLoadingView *)sp_getLoadingView {
    SPLoadingView *loadingView = objc_getAssociatedObject(self, &kLoadingKey);
    if (!loadingView) {
        loadingView = [[SPLoadingView alloc] init];
        [self addSubview:loadingView];
        objc_setAssociatedObject(self, &kLoadingKey, loadingView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return loadingView;
}


#pragma mark - Loading empty.

- (void)sp_showLoadingEmpty {
    [self sp_showLoadingEmptyWithBackgroundColor:[SPLoadingColors defaultLoadingBackground]];
}

- (void)sp_showLoadingEmptyWithBackgroundColor:(UIColor *)backgroundColor {
    @SPWeakSelf(self);
    [self sp_hideLoading:^{
        SPLoadingEmptyView *loadingEmptyView = [weakSelf sp_getLoadingEmptyView];
        loadingEmptyView.backgroundColor = backgroundColor;
        loadingEmptyView.alpha = 0;
        
        if (!loadingEmptyView.superview) {
            [weakSelf addSubview:loadingEmptyView];
        }
        [weakSelf bringSubviewToFront:loadingEmptyView];
        
        [loadingEmptyView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(self);
            make.center.equalTo(self);
        }];
        
        [UIView animateWithDuration:0.25 animations:^{
            loadingEmptyView.alpha = 1;
        }];
    }];
}

- (void)sp_hideLoadingEmpty {
    [self sp_hideLoadingEmpty:nil];
}

- (void)sp_hideLoadingEmpty:(SPCompleteBlock)complete {
    SPLoadingEmptyView *loadingEmptyView = [self sp_getLoadingEmptyView];
    [UIView animateWithDuration:0.25
                     animations:^{
                         loadingEmptyView.alpha = 0;
                     } completion:^(BOOL finished) {
                         if (loadingEmptyView.superview) {
                             [loadingEmptyView removeFromSuperview];
                             loadingEmptyView.alpha = 1;
                         }
                         if (complete) {
                             complete();
                         }
                     }];
}

- (SPLoadingEmptyView *)sp_getLoadingEmptyView {
    SPLoadingEmptyView *loadingEmptyView = objc_getAssociatedObject(self, &kLoadingEmptyKey);
    if (!loadingEmptyView) {
        loadingEmptyView = [[SPLoadingEmptyView alloc] init];
        [self addSubview:loadingEmptyView];
        objc_setAssociatedObject(self, &kLoadingEmptyKey, loadingEmptyView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return loadingEmptyView;
}


#pragma mark - Loading error.

- (void)sp_showLoadingError:(SPRetryLoadingBlock)retry {
    [self sp_showLoadingErrorWithBackgroundColor:[SPLoadingColors defaultLoadingBackground]
                                      retryBlock:retry];
}

- (void)sp_showLoadingErrorWithBackgroundColor:(UIColor *)backgroundColor retryBlock:(SPRetryLoadingBlock)retry {
    @SPWeakSelf(self);
    [self sp_hideLoading:^{
        SPLoadingErrorView *loadingErrorView = [weakSelf sp_getLoadingErrorView];
        loadingErrorView.backgroundColor = backgroundColor;
        loadingErrorView.alpha = 0;
        if (!loadingErrorView.superview) {
            [weakSelf addSubview:loadingErrorView];
        }
        [weakSelf bringSubviewToFront:loadingErrorView];
        
        [loadingErrorView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(self);
            make.center.equalTo(self);
        }];
        
        objc_setAssociatedObject(self, &kRetryBlockKey, retry, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        [UIView animateWithDuration:0.25 animations:^{
            loadingErrorView.alpha = 1;
        }];
    }];
}

- (void)sp_hideLoadingError {
    [self sp_hideLoadingError:nil];
}

- (void)sp_hideLoadingError:(SPCompleteBlock)complete {
    SPLoadingErrorView *loadingErrorView = [self sp_getLoadingErrorView];
    if (loadingErrorView.superview) {
        [loadingErrorView removeFromSuperview];
        loadingErrorView.alpha = 1;
    }
    if (complete) {
        complete();
    }
}

- (SPLoadingErrorView *)sp_getLoadingErrorView {
    SPLoadingErrorView *loadingErrorView = objc_getAssociatedObject(self, &kLoadingErrorKey);
    if (!loadingErrorView) {
        loadingErrorView = [[SPLoadingErrorView alloc] init];
        loadingErrorView.delegate = self;
        [self addSubview:loadingErrorView];
        objc_setAssociatedObject(self, &kLoadingErrorKey, loadingErrorView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return loadingErrorView;
}

- (void)loadingReload:(SPLoadingErrorView *)view {
    [self sp_hideLoadingError];
    SPRetryLoadingBlock retryBlock = objc_getAssociatedObject(self, &kRetryBlockKey);
    if (retryBlock) {
        retryBlock();
    }
}

@end
