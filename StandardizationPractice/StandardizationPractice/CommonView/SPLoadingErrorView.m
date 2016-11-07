//
//  SPLoadingErrorView.m
//  StandardizationPractice
//
//  Created by Baitianyu on 19/10/2016.
//  Copyright © 2016 Netease. All rights reserved.
//

#import "SPLoadingErrorView.h"
#import "UIView+Frame.h"
#import "UIImage+ImageWithColor.h"
#import "SPLoadingSizes.h"

@interface SPLoadingErrorView ()

@property (nonatomic, strong) UILabel *indicateLabel;
@property (nonatomic, strong) UIImageView *indicateImageView;
@property (nonatomic, strong) UIButton *reloadButton;

@end

@implementation SPLoadingErrorView

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
    _indicateLabel.text = @"无法访问该页面";
    [_indicateLabel sizeToFit];
    [self addSubview:_indicateLabel];
    
    _indicateImageView = [[UIImageView alloc] init];
    _indicateImageView.image = [UIImage imageNamed:@"loading_error"];
    [_indicateImageView sizeToFit];
    [self addSubview:_indicateImageView];
    
    _reloadButton = [[UIButton alloc] init];
    [_reloadButton setTitle:@"重新加载" forState:UIControlStateNormal];
    _reloadButton.layer.cornerRadius = [SPThemeSizes cornerRadiusSize];
    _reloadButton.layer.masksToBounds = YES;
    [_reloadButton setBackgroundImage:[UIImage imageWithColor:[SPThemeColors buttonColor]] forState:UIControlStateNormal];
    [_reloadButton setBackgroundImage:[UIImage imageWithColor:[SPThemeColors highlightButtonColor]] forState:UIControlStateHighlighted];
    [_reloadButton addTarget:self action:@selector(reload:) forControlEvents:UIControlEventTouchUpInside];
    _reloadButton.titleLabel.font = [SPLoadingSizes loadingIndicateFont];
    [self addSubview:_reloadButton];
}


#pragma mark - Layout.

- (void)layoutSubviews {
    [super layoutSubviews];
    _reloadButton.size = [SPLoadingSizes reloadButtonSize];
    CGFloat height = _indicateLabel.height + _indicateImageView.height + [SPThemeSizes titleIconGap] + _reloadButton.height + [SPLoadingSizes titleReloadButtonGap];

    _indicateImageView.y = (self.height - height) / 2;
    _indicateImageView.middleX = self.width / 2;

    _indicateLabel.y = _indicateImageView.bottom + [SPThemeSizes titleIconGap];
    _indicateLabel.middleX = self.width / 2;
    
    _reloadButton.y = _indicateLabel.bottom + [SPLoadingSizes titleReloadButtonGap];
    _reloadButton.middleX = self.width / 2;
}


#pragma mark - Actions.

- (void)reload:(id)sender {
    [_delegate loadingReload:self];
}

@end
