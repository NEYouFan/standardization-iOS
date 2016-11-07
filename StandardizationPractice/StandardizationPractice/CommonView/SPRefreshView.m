//
//  SPRefreshView.m
//  StandardizationPractice
//
//  Created by Baitianyu on 19/10/2016.
//  Copyright © 2016 Netease. All rights reserved.
//

#import "SPRefreshView.h"
#import "UIView+Frame.h"
#import "SPLoadingSizes.h"

@interface SPRefreshView ()

@property (nonatomic, strong) UIImageView *indicateImageView;
@property (nonatomic, strong) UIImageView *activitorImageView;
@property (nonatomic, strong) UILabel *indicateLabel;

@end

@implementation SPRefreshView

#pragma mark - Load views.

- (void)loadSubViews {
    _indicateImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"refreshing_arrow"]];
    [_indicateImageView sizeToFit];
    _indicateImageView.contentMode = UIViewContentModeCenter;
    [self addSubview:_indicateImageView];
    
    _indicateLabel = [[UILabel alloc] init];
    _indicateLabel.text = @"下拉更新...";
    _indicateLabel.numberOfLines = 1;
    _indicateLabel.font = [SPThemeSizes refreshingIndicateFont];
    _indicateLabel.textColor = [SPThemeColors lightTextColor];
    [self addSubview:_indicateLabel];
    
    _activitorImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"refreshing_activitor"]];
    [_activitorImageView sizeToFit];
    _activitorImageView.hidden = YES;
    [self addSubview:_activitorImageView];
}


#pragma mark - Layout.

- (void)layoutSubviews {
    [super layoutSubviews];
    [_indicateLabel sizeToFit];
    
    CGFloat width = _indicateLabel.width + _indicateImageView.image.size.width + [SPLoadingSizes refreshingIconLabelGap];
    
    _indicateImageView.middleX = (self.width - width) / 2 + _indicateImageView.image.size.width / 2;
    _indicateImageView.middleY = self.height / 2;

    _activitorImageView.middleY = self.height / 2;
    _activitorImageView.middleX = _indicateImageView.middleX;
    
    _indicateLabel.middleY = self.height / 2;
    _indicateLabel.x = _activitorImageView.tail + [SPLoadingSizes refreshingIconLabelGap];
}


#pragma mark - HTRefreshViewDelegate.

- (CGFloat)refreshingInset {
    return kRefreshViewHeight;
}

- (CGFloat)refreshableInset {
    return kRefreshViewHeight;
}

- (void)refreshStateChanged:(HTRefreshState)state {
    switch (state) {
        case HTRefreshStateCanEngageRefresh: {
            _indicateLabel.text = @"松开更新...";
            [self layoutIfNeeded];
        }
            break;
        case HTRefreshStateDidEngageRefresh: {
            // Refresh is on going.
            _indicateLabel.text = @"更新中...";
            _indicateImageView.hidden = YES;
            _activitorImageView.hidden = NO;
            [self layoutIfNeeded];
            
            [self startAnimating];
        }
            break;
        case HTRefreshStateDidDisengageRefresh: {
            _indicateLabel.text = @"下拉更新...";
            [self layoutIfNeeded];
        }
            break;
        case HTRefreshStateWillEndRefresh: {
            _indicateLabel.text = @"更新完成...";
            [self layoutIfNeeded];
        }
            break;
        case HTRefreshStateDidEndRefresh: {
            // Refresh is end.
            _indicateLabel.text = @"下拉刷新...";
            [self resetIndicationImageView];
            _indicateImageView.hidden = NO;
            _activitorImageView.hidden = YES;
            [self layoutIfNeeded];
            [self stopAnimating];
        }
            break;
    }
}

- (void)refreshPercentChanged:(CGFloat)percent offset:(CGFloat)offset direction:(HTRefreshDirection)direction {
    if (percent > 1)
        percent = 1;
    _indicateImageView.transform = CGAffineTransformMakeRotation(M_PI * percent);
}


#pragma mark - Animation.

- (void)rotateIndicationImageView {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.25];
    _indicateImageView.transform = CGAffineTransformMakeRotation(M_PI);
    [UIView commitAnimations];
}

- (void)resetIndicationImageView {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.25];
    _indicateImageView.transform = CGAffineTransformIdentity;
    [UIView commitAnimations];
}

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
