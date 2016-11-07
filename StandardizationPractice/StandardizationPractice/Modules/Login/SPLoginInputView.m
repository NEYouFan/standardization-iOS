//
//  SPLoginInputView.m
//  StandardizationPractice
//
//  Created by Baitianyu on 01/11/2016.
//  Copyright © 2016 Netease. All rights reserved.
//

#import "SPLoginInputView.h"
#import "UIView+SPLine.h"
#import "SPLoginInputViewModel.h"
#import "UIView+Frame.h"
#import "SPLoginSizes.h"
#import "SPLoginColors.h"

@interface SPLoginInputView ()

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UIButton *optionButton;

@end

@implementation SPLoginInputView

#pragma mark - Life cycle.

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self loadSubviews];
    }
    
    return self;
}


#pragma mark - Load views.

- (void)loadSubviews {
    [self sp_addBottomLineWithLeftMargin:0 rightMargin:0];
    
    _inputTextField = [[UITextField alloc] init];
    [self addSubview:_inputTextField];
    
    _iconImageView = [[UIImageView alloc] init];
    [self addSubview:_iconImageView];
    
    _optionButton = [[UIButton alloc] init];
    [self addSubview:_optionButton];
}


#pragma mark - Layout.

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [_iconImageView sizeToFit];
    _iconImageView.bottom = self.height - [SPLoginSizes iconImageBottomMargin];
    _iconImageView.x = 0;
    
    [_optionButton sizeToFit];
    _optionButton.bottom = _iconImageView.bottom;
    _optionButton.tail = self.width;
    
    _inputTextField.width = self.width - _iconImageView.width - _optionButton.width - [SPLoginSizes iconPlaceholderGap];
    _inputTextField.height = _iconImageView.height;
    _inputTextField.x = _iconImageView.tail + [SPLoginSizes iconPlaceholderGap];
    _inputTextField.bottom = _iconImageView.bottom;
}


#pragma mark - Setter & Getter.

- (void)setViewModel:(SPLoginInputViewModel *)viewModel {
    if (_viewModel == viewModel) {
        return;
    }
    
    _viewModel = viewModel;
    
    NSMutableAttributedString *attributedPlaceholder = [[NSMutableAttributedString alloc] initWithString:_viewModel.placeholder];
    [attributedPlaceholder addAttribute:NSForegroundColorAttributeName
                                  value:[SPThemeColors placeholderTextColor]
                                  range:NSMakeRange(0, _viewModel.placeholder.length)];
    [attributedPlaceholder addAttribute:NSFontAttributeName
                                  value:[SPLoginSizes placeholderFont]
                                  range:NSMakeRange(0, _viewModel.placeholder.length)];
    _inputTextField.attributedPlaceholder = attributedPlaceholder;
    
    _iconImageView.image = _viewModel.iconImage;
    if (_viewModel.optionString) {
        _optionButton.hidden = NO;
        [_optionButton setTitle:_viewModel.optionString forState:UIControlStateNormal];
    } else {
        _optionButton.hidden = YES;
    }
    
    [self setNeedsLayout];
}

- (NSString *)text {
    return _inputTextField.text;
}

@end
