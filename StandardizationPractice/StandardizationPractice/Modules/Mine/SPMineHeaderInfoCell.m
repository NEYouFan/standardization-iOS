//
//  SPMineHeaderInfoCell.m
//  StandardizationPractice
//
//  Created by Baitianyu on 19/10/2016.
//  Copyright © 2016 Netease. All rights reserved.
//

#import "SPMineHeaderInfoCell.h"
#import "SPMineCellDescribeData.h"
#import "SPMineHeaderInfoCellViewModel.h"
#import "SPMineColors.h"
#import "SPMineSizes.h"
#import "UIView+Frame.h"
#import "UIImage+ImageWithColor.h"

@interface SPMineHeaderInfoCell ()

@property (nonatomic, strong) UIButton *loginButton;
@property (nonatomic, strong) UIImageView *headerImageView;
@property (nonatomic, strong) UILabel *nameLabel;

@end

@implementation SPMineHeaderInfoCell

#pragma mark - Life cycle.
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = [SPMineColors headerInfoBackgroundColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self loadSubviews];
    }
    
    return self;
}


#pragma mark - Load views.

- (void)loadSubviews {
    _loginButton = [[UIButton alloc] init];
    [_loginButton setTitle:@"登陆/注册" forState:UIControlStateNormal];
    [_loginButton addTarget:self action:@selector(loginClicked:) forControlEvents:UIControlEventTouchUpInside];
    _loginButton.layer.cornerRadius = [SPThemeSizes cornerRadiusSize];
    _loginButton.layer.borderWidth = [SPThemeSizes lineWidth];
    _loginButton.layer.borderColor = [SPMineColors loginButtonBorderColor].CGColor;
    _loginButton.layer.masksToBounds = YES;
    [_loginButton setBackgroundImage:[UIImage imageWithColor:[SPThemeColors buttonColor]] forState:UIControlStateNormal];
    [_loginButton setBackgroundImage:[UIImage imageWithColor:[SPThemeColors highlightButtonColor]] forState:UIControlStateHighlighted];
    [self.contentView addSubview:_loginButton];
    
    _headerImageView = [[UIImageView alloc] init];
    _headerImageView.layer.cornerRadius = [SPMineSizes headerIconWidth] / 2;
    [self.contentView addSubview:_headerImageView];
    
    _nameLabel = [[UILabel alloc] init];
    _nameLabel.textColor = [SPThemeColors lightTextColor];
    _nameLabel.font = [SPMineSizes userNameFont];
    [self.contentView addSubview:_nameLabel];
}


#pragma mark - Layout.

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _headerImageView.width = [SPMineSizes headerIconWidth];
    _headerImageView.height = [SPMineSizes headerIconWidth];
    _headerImageView.center = self.contentView.center;
    
    _loginButton.size = [SPMineSizes loginButtonSize];
    _loginButton.center = self.contentView.center;
    
    [_nameLabel sizeToFit];
    _nameLabel.middleX = self.contentView.width / 2;
    _nameLabel.y = _headerImageView.bottom + [SPThemeSizes titleIconGap];
}

- (CGFloat)cellHeight {
    return 244;
}


#pragma mark - Actions.

- (void)loginClicked:(id)sender {
    if ([_delegate respondsToSelector:@selector(loginOrRegister:)]) {
        [_delegate loginOrRegister:self];
    }
}


#pragma mark - Setter.

- (void)setDescribeData:(MCTableBaseDescribeData *)describeData {
    if ([describeData isKindOfClass:[SPMineCellDescribeData class]]) {
        SPMineCellDescribeData *data = (SPMineCellDescribeData *)describeData;
        SPMineHeaderInfoCellViewModel *viewModel = [[SPMineHeaderInfoCellViewModel alloc] initWithDescribeData:data];
        self.viewModel = viewModel;
        self.delegate = data.delegate;
    }
}

- (void)setViewModel:(SPMineHeaderInfoCellViewModel *)viewModel {
    if (_viewModel == viewModel) {
        return;
    }
    
    _viewModel = viewModel;
    _delegate = _viewModel.delegate;
    if (_viewModel.alreadyLogin) {
        _headerImageView.hidden = NO;
        _loginButton.hidden = YES;
        _nameLabel.hidden = NO;
        _headerImageView.image = _viewModel.headerImage;
        _nameLabel.text = _viewModel.userName;
    } else {
        _headerImageView.hidden = YES;
        _nameLabel.hidden = YES;
        _loginButton.hidden = NO;
    }
    [self setNeedsLayout];
}

@end
