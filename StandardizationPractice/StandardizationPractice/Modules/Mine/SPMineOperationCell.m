//
//  SPMineOperationCell.m
//  StandardizationPractice
//
//  Created by Baitianyu on 19/10/2016.
//  Copyright © 2016 Netease. All rights reserved.
//

#import "SPMineOperationCell.h"
#import "UIView+SPLine.h"
#import "SPMineSizes.h"
#import "SPMineColors.h"
#import "UIView+Frame.h"
#import "SPMineCellDescribeData.h"
#import "SPMineOperationCellViewModel.h"

@interface SPMineOperationCell ()

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *rightArrowImageView;

@end

@implementation SPMineOperationCell

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
    _iconImageView = [[UIImageView alloc] init];
    [self.contentView addSubview:_iconImageView];
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.textColor = [SPThemeColors lightTextColor];
    _titleLabel.font = [SPMineSizes mineTitleFont];
    _titleLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:_titleLabel];
    
    _rightArrowImageView = [[UIImageView alloc] init];
    _rightArrowImageView.image = [UIImage imageNamed:@"right_arrow"];
    [self.contentView addSubview:_rightArrowImageView];
}


#pragma mark - Layout.

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [_iconImageView sizeToFit];
    _iconImageView.x = [SPThemeSizes leftMargin];
    _iconImageView.middleY = self.height / 2;
    
    [_titleLabel sizeToFit];
    _titleLabel.x = _iconImageView.tail + [SPThemeSizes titleIconGap];
    _titleLabel.middleY = self.height / 2;
    
    [_rightArrowImageView sizeToFit];
    _rightArrowImageView.tail = self.width - [SPThemeSizes rightMargin];
    _rightArrowImageView.middleY = self.height / 2;
}

- (CGFloat)cellHeight {
    return 40;
}


#pragma mark - Getter & Setter.

- (void)setDescribeData:(MCTableBaseDescribeData *)describeData {
    if ([describeData isKindOfClass:[SPMineCellDescribeData class]]) {
        SPMineOperationCellViewModel *viewModel = [[SPMineOperationCellViewModel alloc] initWithDescribeData:(SPMineCellDescribeData *)describeData];
        self.viewModel = viewModel;
    }
}

- (void)setViewModel:(SPMineOperationCellViewModel *)viewModel {
    if (_viewModel == viewModel) {
        return;
    }
    
    _viewModel = viewModel;
    _titleLabel.text = _viewModel.title;
    _iconImageView.image = _viewModel.iconImage;
}

@end
