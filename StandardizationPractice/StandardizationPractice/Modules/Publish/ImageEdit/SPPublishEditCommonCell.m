//
//  SPPublishEditCommonCell.m
//  StandardizationPractice
//
//  Created by Baitianyu on 28/10/2016.
//  Copyright © 2016 Netease. All rights reserved.
//

#import "SPPublishEditCommonCell.h"
#import "SPPublishColors.h"
#import "SPPublishSizes.h"
#import "UIView+Frame.h"
#import "SPPublishEditDescribeData.h"
#import "UIView+SPLine.h"

@interface SPPublishEditCommonCell ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *contentLabel;

@end

@implementation SPPublishEditCommonCell

#pragma mark - Life cycle.

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self loadSubviews];
    }
    
    return self;
}


#pragma mark - Load views.

- (void)loadSubviews {
    [self.contentView sp_addBottomLineWithLeftMargin:[SPThemeSizes leftMargin] rightMargin:[SPThemeSizes rightMargin]];
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.textColor = [SPThemeColors lightTextColor];
    _titleLabel.font = [SPPublishSizes titleFont];
    [self.contentView addSubview:_titleLabel];
    
    _contentLabel = [[UILabel alloc] init];
    _contentLabel.textColor = [SPThemeColors lightTextColor];
    _contentLabel.font = [SPPublishSizes titleFont];
    [self.contentView addSubview:_contentLabel];
}


#pragma mark - Layout.

- (void)layoutSubviews {
    [super layoutSubviews];
    [_titleLabel sizeToFit];
    _titleLabel.x = [SPThemeSizes leftMargin];
    _titleLabel.middleY = self.contentView.height / 2;
    
    [_contentLabel sizeToFit];
    _contentLabel.tail = self.contentView.width - [SPThemeSizes rightMargin];
    _contentLabel.middleY = self.contentView.height / 2;
}

- (CGFloat)cellHeight {
    return 37;
}


#pragma mark - Setter.

- (void)setDescribeData:(MCTableBaseDescribeData *)describeData {
    if ([describeData isKindOfClass:[SPPublishEditDescribeData class]]) {
        SPPublishEditDescribeData *data = (SPPublishEditDescribeData *)describeData;
        _titleLabel.text = data.title;
        _contentLabel.text = data.content;
        [self setNeedsLayout];
    }
}

@end
