//
//  SPLoadingView.m
//  StandardizationPractice
//
//  Created by Baitianyu on 19/10/2016.
//  Copyright © 2016 Netease. All rights reserved.
//

#import "SPLoadingView.h"
#import "UIView+Frame.h"
#import "SPLoadingSizes.h"

@interface SPLoadingView ()

@property (nonatomic, strong) UILabel *indicateLabel;
@property (nonatomic, strong) UIImageView *indicateImageView;

@end

@implementation SPLoadingView

#pragma mark - Life cycle.

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self loadSubviews];
    }
    
    return self;
}


#pragma mark - Load views.

- (void)loadSubviews {
    _indicateLabel = [[UILabel alloc] init];
    _indicateLabel.textColor = [SPThemeColors lightTextColor];
    _indicateLabel.font = [SPLoadingSizes loadingIndicateFont];
    _indicateLabel.textAlignment = NSTextAlignmentCenter;
    _indicateLabel.text = @"正在加载";
    [_indicateLabel sizeToFit];
    [self addSubview:_indicateLabel];
    
    _indicateImageView = [[UIImageView alloc] init];
    _indicateImageView.image = [UIImage imageNamed:@"loading"];
    [_indicateImageView sizeToFit];
    [self addSubview:_indicateImageView];
}


#pragma mark - Layout.

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = _indicateLabel.width + _indicateImageView.width + [SPThemeSizes titleIconGap];
    _indicateImageView.x = (self.width - width) / 2;
    _indicateImageView.middleY = self.height / 2;
    
    _indicateLabel.tail = self.width - _indicateImageView.x;
    _indicateLabel.middleY = self.height / 2;
}


#pragma mark - Public methods.

- (void)startLoadingAnimation {
    [_indicateImageView.layer removeAnimationForKey:@"Rotation"];
    _indicateImageView.transform = CGAffineTransformIdentity;
    CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.fromValue = [NSNumber numberWithFloat:0.0f];
    animation.toValue = [NSNumber numberWithFloat: 2 * M_PI];
    animation.repeatCount = INFINITY;
    animation.duration = 0.7;
    animation.removedOnCompletion = NO;
    [_indicateImageView.layer addAnimation:animation forKey:@"Rotation"];
}

- (void)stopLoadingAnimation {
    CGFloat curRotate = [[_indicateImageView.layer.presentationLayer valueForKeyPath:@"transform.rotation.z"] floatValue];
    [_indicateImageView.layer removeAllAnimations];
    CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.fromValue = [NSNumber numberWithFloat:curRotate];
    animation.toValue = [NSNumber numberWithFloat: curRotate];
    animation.removedOnCompletion = YES;
    [_indicateImageView.layer addAnimation:animation forKey:@"Rotation"];
}

@end
