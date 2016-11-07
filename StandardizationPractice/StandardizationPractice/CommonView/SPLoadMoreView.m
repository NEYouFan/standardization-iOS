//
//  SPLoadMoreView.m
//  StandardizationPractice
//
//  Created by 陶泽宇 on 2016/10/21.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import "SPLoadMoreView.h"
#import "UIView+Frame.h"
#import "SPLoadingSizes.h"

@interface SPLoadMoreView ()

@property (nonatomic, strong) UIImageView *activitorImageView;
@property (nonatomic, strong) UILabel *indicateLabel;

@end

@implementation SPLoadMoreView

#pragma mark - Load views.

- (void)loadSubViews {
    _indicateLabel = [[UILabel alloc] init];
    _indicateLabel.text = @"正在加载...";
    _indicateLabel.numberOfLines = 1;
    _indicateLabel.font = [SPThemeSizes refreshingIndicateFont];
    _indicateLabel.textColor = [SPThemeColors lightTextColor];
    [self addSubview:_indicateLabel];
    
    _activitorImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"refreshing_activitor"]];
    [_activitorImageView sizeToFit];
    _activitorImageView.hidden = YES;
    [self addSubview:_activitorImageView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [super layoutSubviews];
    [_indicateLabel sizeToFit];
    
    CGFloat width = _indicateLabel.width + _activitorImageView.width + [SPLoadingSizes refreshingIconLabelGap];
    
    _activitorImageView.middleY = self.height / 2;
    _activitorImageView.x = (self.width - width) / 2;
    
    _indicateLabel.middleY = self.height / 2;
    _indicateLabel.x = _activitorImageView.tail + [SPLoadingSizes refreshingIconLabelGap];
}


#pragma mark - HTRefreshViewDelegate

- (CGFloat)refreshingInset {
    return 0;
}

- (CGFloat)refreshableInset {
    return kLoadMoreViewHeight;
}

- (CGFloat)promptingInset {
    return self.hiddenRefresh? 0 : kLoadMoreViewHeight;
}

- (void)refreshStateChanged:(HTRefreshState)state {
    switch (state) {
        case HTRefreshStateCanEngageRefresh: {
            
        }
            break;
        case HTRefreshStateDidEngageRefresh:
            [self startAnimating];
            break;
        case HTRefreshStateDidDisengageRefresh: {
            
        }
            break;
        case HTRefreshStateWillEndRefresh: {
            
        }
            break;
        case HTRefreshStateDidEndRefresh: {
            [self stopAnimating];
        }
            break;
    }
}


#pragma mark - Animation.

- (void)startAnimating {
    [_activitorImageView.layer removeAnimationForKey:@"Rotation"];
    _activitorImageView.transform = CGAffineTransformIdentity;
    CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.fromValue = [NSNumber numberWithFloat:0.0f];
    animation.toValue = [NSNumber numberWithFloat: 2 * M_PI];
    animation.repeatCount = INFINITY;
    animation.duration = 0.7;
    animation.removedOnCompletion = NO;
    [_activitorImageView.layer addAnimation:animation forKey:@"Rotation"];
}

- (void)stopAnimating {
    CGFloat curRotate = [[_activitorImageView.layer.presentationLayer valueForKeyPath:@"transform.rotation.z"] floatValue];
    [_activitorImageView.layer removeAllAnimations];
    CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.fromValue = [NSNumber numberWithFloat:curRotate];
    animation.toValue = [NSNumber numberWithFloat: curRotate];
    animation.removedOnCompletion = YES;
    [_activitorImageView.layer addAnimation:animation forKey:@"Rotation"];
}

@end
