//
//  SPMineSettingLogoutCell.m
//  StandardizationPractice
//
//  Created by Baitianyu on 21/10/2016.
//  Copyright © 2016 Netease. All rights reserved.
//

#import "SPMineSettingLogoutCell.h"
#import "UIView+SPLine.h"
#import "SPMineSettingCellDescribeData.h"
#import "SPMineSizes.h"
#import "UIView+Frame.h"

@interface SPMineSettingLogoutCell ()

@property (nonatomic, strong) UIButton *logoutButton;

@end

@implementation SPMineSettingLogoutCell

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
    _logoutButton = [[UIButton alloc] init];
    [_logoutButton addTarget:self action:@selector(logout:) forControlEvents:UIControlEventTouchUpInside];
    [_logoutButton setBackgroundImage:[UIImage imageNamed:@"setting_logout"] forState:UIControlStateNormal];
    [_logoutButton setBackgroundImage:[UIImage imageNamed:@"setting_logout_highlight"] forState:UIControlStateHighlighted];
    _logoutButton.layer.cornerRadius = [SPThemeSizes cornerRadiusSize];
    _logoutButton.layer.masksToBounds = YES;
    [self.contentView addSubview:_logoutButton];
}


#pragma mark - Layout.

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _logoutButton.size = [SPMineSizes logoutButtonSize];
    _logoutButton.middleX = self.contentView.width / 2;
    _logoutButton.bottom = self.contentView.height;
}

- (CGFloat)cellHeight {
    return 93;
}


#pragma mark - Setter.

- (void)setDescribeData:(MCTableBaseDescribeData *)describeData {
    if ([describeData isKindOfClass:[SPMineSettingCellDescribeData class]]) {
        SPMineSettingCellDescribeData *data = (SPMineSettingCellDescribeData *)describeData;
        _delegate = data.logoutDelegate;
    }
}


#pragma mark - Actions.

- (void)logout:(id)sender {
    if ([_delegate respondsToSelector:@selector(logout:)]) {
        [_delegate logout:self];
    }
}

@end
