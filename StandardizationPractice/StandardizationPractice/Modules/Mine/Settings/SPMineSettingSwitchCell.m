//
//  SPMineSettingSwitchCell.m
//  StandardizationPractice
//
//  Created by Baitianyu on 21/10/2016.
//  Copyright © 2016 Netease. All rights reserved.
//

#import "SPMineSettingSwitchCell.h"
#import "SPMineSettingSwitchCellViewModel.h"
#import "SPMineSettingCellDescribeData.h"
#import "SPMineSizes.h"
#import "UIView+Frame.h"
#import "UIView+SPLine.h"

@interface SPMineSettingSwitchCell ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UISwitch *switchButton;

@end

@implementation SPMineSettingSwitchCell

#pragma mark - Life cycle.

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self loadSubviews];
    }
    return self;
}


#pragma mark - Load views.

- (void)loadSubviews {
    [self.contentView sp_addBottomLineWithLeftMargin:0 rightMargin:0];
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.textColor = [SPThemeColors lightTextColor];
    _titleLabel.font = [SPMineSizes mineTitleFont];
    [self.contentView addSubview:_titleLabel];
    
    _switchButton = [[UISwitch alloc] init];
    [_switchButton addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_switchButton];
}


#pragma mark - Layout.

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [_titleLabel sizeToFit];
    _titleLabel.x = [SPThemeSizes leftMargin];
    _titleLabel.middleY = self.contentView.height / 2;
    
    _switchButton.tail = self.contentView.width - [SPThemeSizes rightMargin];
    _switchButton.middleY = _titleLabel.middleY;
}

- (CGFloat)cellHeight {
    return 40;
}


#pragma mark - Setter.

- (void)setDescribeData:(MCTableBaseDescribeData *)describeData {
    if ([describeData isKindOfClass:[SPMineSettingCellDescribeData class]]) {
        SPMineSettingCellDescribeData *data = (SPMineSettingCellDescribeData *)describeData;
        self.viewModel = [[SPMineSettingSwitchCellViewModel alloc] initWithDescribeData:data];
    }
}

- (void)setViewModel:(SPMineSettingSwitchCellViewModel *)viewModel {
    if (_viewModel == viewModel) {
        return;
    }
    
    _viewModel = viewModel;
    _titleLabel.text = _viewModel.title;
    _switchButton.on = _viewModel.switchOn;
    _delegate = _viewModel.delegate;
    [self setNeedsLayout];
}


#pragma mark - Actions.

- (void)switchChanged:(id)sender {
    if ([_delegate respondsToSelector:@selector(switchChanged:)]) {
        [_delegate switchChanged:_switchButton.on];
    }
}

@end
