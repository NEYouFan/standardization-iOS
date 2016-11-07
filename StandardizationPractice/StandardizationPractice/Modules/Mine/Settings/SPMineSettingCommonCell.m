//
//  SPMineSettingCommonCell.m
//  StandardizationPractice
//
//  Created by Baitianyu on 21/10/2016.
//  Copyright © 2016 Netease. All rights reserved.
//

#import "SPMineSettingCommonCell.h"
#import "SPMineSettingCommonCellViewModel.h"
#import "SPMineSettingCellDescribeData.h"
#import "SPMineSizes.h"
#import "UIView+Frame.h"
#import "UIView+SPLine.h"

@interface SPMineSettingCommonCell ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *rightTitleLabel;
@property (nonatomic, strong) UIImageView *arrowImageView;

@end

@implementation SPMineSettingCommonCell

#pragma mark - Life cycle.

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
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
    
    _rightTitleLabel = [[UILabel alloc] init];
    _rightTitleLabel.textColor = [SPThemeColors lightTextColor];
    _rightTitleLabel.font = [SPMineSizes mineTitleFont];
    [self.contentView addSubview:_rightTitleLabel];
    
    _arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"right_arrow"]];
    [self.contentView addSubview:_arrowImageView];
}


#pragma mark - Layout.

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [_titleLabel sizeToFit];
    _titleLabel.x = [SPThemeSizes leftMargin];
    _titleLabel.middleY = self.contentView.height / 2;

    [_arrowImageView sizeToFit];
    _arrowImageView.tail = self.contentView.width - [SPThemeSizes rightMargin];
    _arrowImageView.middleY = _titleLabel.middleY;
    
    [_rightTitleLabel sizeToFit];
    _rightTitleLabel.tail = _arrowImageView.x - [SPThemeSizes titleIconGap];
    _rightTitleLabel.middleY = _titleLabel.middleY;
}

- (CGFloat)cellHeight {
    return 40;
}


#pragma mark - Setter.

- (void)setDescribeData:(MCTableBaseDescribeData *)describeData {
    if ([describeData isKindOfClass:[SPMineSettingCellDescribeData class]]) {
        SPMineSettingCellDescribeData *data = (SPMineSettingCellDescribeData *)describeData;
        self.viewModel = [[SPMineSettingCommonCellViewModel alloc] initWithDescribeData:data];
    }
}

- (void)setViewModel:(SPMineSettingCommonCellViewModel *)viewModel {
    if (_viewModel == viewModel) {
        return;
    }
    
    _viewModel = viewModel;
    _titleLabel.text = _viewModel.title;
    _rightTitleLabel.hidden = !_viewModel.showRightTitle;
    _rightTitleLabel.text = _viewModel.rightTitle;
    self.selectionStyle = _viewModel.selectionStyle;
    [self setNeedsLayout];
}

@end
