//
//  SPPopUPView.m
//  StandardizationPractice
//
//  Created by 陶泽宇 on 2016/10/27.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import "SPPopUPView.h"
#import "SPThemeSizes.h"
#import <HTCommonUtility/UIView+Frame.h>
#import <HTCommonUtility/ColorUtils.h>

const CGFloat kCancelButtonHeight = 41;

@interface SPPopUPView ()

@property (nonatomic, strong) UIView *shadowView;
@property (nonatomic, strong) UIButton *cancelButton;

@end


@implementation SPPopUPView

- (instancetype)initWithContentView:(UIView *)contentView{
    if (self = [super init]) {
        _contentView = contentView;
        [self configView];
        return self;
    }
    return nil;
}

- (void)configView{
    self.frame = CGRectMake(19, [SPThemeSizes screenHeight] - 64, [SPThemeSizes screenWidth] - 19*2, 50 + _contentView.height);
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    [window addSubview:self];
    [self loadSubviews];
}

- (void)loadSubviews{
    [self addSubview:_contentView];
    
    _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _cancelButton.layer.cornerRadius = 4.f;
    _cancelButton.clipsToBounds = YES;
    _cancelButton.frame = CGRectMake(0, self.height - kCancelButtonHeight, self.width, kCancelButtonHeight);
    _cancelButton.backgroundColor = [UIColor whiteColor];
    [_cancelButton setTitleColor:[UIColor colorWithRGBValue:0x607d88] forState:UIControlStateNormal];
    [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    _cancelButton.titleLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:20];
    _cancelButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_cancelButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_cancelButton];
}


- (void)popup{
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    _shadowView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, window.width, window.height)];
    _shadowView.backgroundColor = [UIColor blackColor];
    _shadowView.alpha = 0;
    [window addSubview:_shadowView];
    [window bringSubviewToFront:self];
    self.y = [SPThemeSizes screenHeight];
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.y = [SPThemeSizes screenHeight] - self.height;
        _shadowView.alpha = 0.45;
    } completion:^(BOOL finished) {
    }];
}

- (void)dismiss{
    self.y = [SPThemeSizes screenHeight];
    _shadowView.alpha = 0.45;
    self.y = [SPThemeSizes screenHeight] - self.height;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _shadowView.alpha = 0.0;
        self.y = [SPThemeSizes screenHeight];
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [_shadowView removeFromSuperview];
        _shadowView =nil;
        [self removeFromSuperview];
    }];
}

@end
