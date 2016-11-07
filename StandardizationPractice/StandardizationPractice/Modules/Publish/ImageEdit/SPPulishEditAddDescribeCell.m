//
//  SPPulishEditAddDescribeCell.m
//  StandardizationPractice
//
//  Created by Baitianyu on 28/10/2016.
//  Copyright © 2016 Netease. All rights reserved.
//

#import "SPPulishEditAddDescribeCell.h"
#import "SPPublishColors.h"
#import "SPPublishSizes.h"
#import "UIView+Frame.h"
#import "SPPublishEditDescribeData.h"
#import "UIView+SPLine.h"

@interface SPPulishEditAddDescribeCell ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UITextView *inputTextView;

@end

@implementation SPPulishEditAddDescribeCell

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
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.textColor = [SPThemeColors lightTextColor];
    _titleLabel.font = [SPPublishSizes titleFont];
    [self.contentView addSubview:_titleLabel];

    _inputTextView = [[UITextView alloc] init];
    _inputTextView.layer.masksToBounds = YES;
    _inputTextView.textColor = [SPThemeColors lightTextColor];
    _inputTextView.font = [SPPublishSizes editDescribeTextViewFont];
    _inputTextView.layer.cornerRadius = [SPThemeSizes cornerRadiusSize];
    _inputTextView.layer.borderColor = [SPThemeColors lineColor].CGColor;
    _inputTextView.layer.borderWidth = [SPThemeSizes lineWidth];
    [self.contentView addSubview:_inputTextView];
}


#pragma mark - Layout.

- (void)layoutSubviews {
    [super layoutSubviews];
    [_titleLabel sizeToFit];
    _titleLabel.x = [SPThemeSizes leftMargin];
    _titleLabel.y = [SPPublishSizes editTitleTextViewGap];
    
    _inputTextView.width = self.contentView.width - [SPThemeSizes leftMargin] - [SPThemeSizes rightMargin];
    _inputTextView.height = [SPPublishSizes editInputTextViewHeight];
    _inputTextView.x = [SPThemeSizes leftMargin];
    _inputTextView.y = _titleLabel.bottom + [SPPublishSizes editTitleTextViewGap];
}

- (CGFloat)cellHeight {
    return [SPPublishSizes editInputTextViewHeight] + _titleLabel.font.pointSize + 2 * [SPPublishSizes editTitleTextViewGap];
}


#pragma mark - Setter.

- (void)setDescribeData:(MCTableBaseDescribeData *)describeData {
    if ([describeData isKindOfClass:[SPPublishEditDescribeData class]]) {
        SPPublishEditDescribeData *data = (SPPublishEditDescribeData *)describeData;
        _titleLabel.text = data.title;
    }
}

@end
