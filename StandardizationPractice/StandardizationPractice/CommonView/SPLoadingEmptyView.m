//
//  SPLoadingEmptyView.m
//  StandardizationPractice
//
//  Created by Baitianyu on 19/10/2016.
//  Copyright © 2016 Netease. All rights reserved.
//

#import "SPLoadingEmptyView.h"
#import "UIView+Frame.h"
#import "SPLoadingSizes.h"

@interface SPLoadingEmptyView ()

@property (nonatomic, strong) UILabel *indicateLabel;
@property (nonatomic, strong) UIImageView *indicateImageView;

@end

@implementation SPLoadingEmptyView

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
    _indicateLabel.text = @"暂时没有数据";
    [_indicateLabel sizeToFit];
    [self addSubview:_indicateLabel];
    
    _indicateImageView = [[UIImageView alloc] init];
    _indicateImageView.image = [UIImage imageNamed:@"loading_empty"];
    [_indicateImageView sizeToFit];
    [self addSubview:_indicateImageView];
}


#pragma mark - Layout.

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat height = _indicateLabel.height + _indicateImageView.height + [SPThemeSizes titleIconGap];
    _indicateImageView.y = (self.height - height) / 2;
    _indicateImageView.middleX = self.width / 2;
    
    _indicateLabel.bottom = self.height - _indicateImageView.y;
    _indicateLabel.middleX = self.width / 2;
}

@end
