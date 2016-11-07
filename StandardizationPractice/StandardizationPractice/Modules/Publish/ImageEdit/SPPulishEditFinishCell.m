//
//  SPPulishEditFinishCell.m
//  StandardizationPractice
//
//  Created by Baitianyu on 28/10/2016.
//  Copyright © 2016 Netease. All rights reserved.
//

#import "SPPulishEditFinishCell.h"
#import "SPPublishColors.h"
#import "SPPublishSizes.h"
#import "UIView+Frame.h"
#import "SPPublishEditDescribeData.h"
#import "UIView+SPLine.h"

@interface SPPulishEditFinishCell ()

@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *publishButton;
@property (nonatomic, strong) UILabel *backLabel;
@property (nonatomic, strong) UILabel *publishLabel;

@end

@implementation SPPulishEditFinishCell

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
    _publishLabel = [[UILabel alloc] init];
    _publishLabel.textColor = [SPThemeColors lightTextColor];
    _publishLabel.font = [SPPublishSizes titleFont];
    _publishLabel.text = @"发布";
    [_publishLabel sizeToFit];
    [self.contentView addSubview:_publishLabel];

    _backLabel = [[UILabel alloc] init];
    _backLabel.textColor = [SPThemeColors lightTextColor];
    _backLabel.font = [SPPublishSizes titleFont];
    _backLabel.text = @"返回";
    [_backLabel sizeToFit];
    [self.contentView addSubview:_backLabel];
    
    _publishButton = [[UIButton alloc] init];
    [_publishButton setBackgroundImage:[UIImage imageNamed:@"publish"] forState:UIControlStateNormal];
    [_publishButton setBackgroundImage:[UIImage imageNamed:@"publish_highlight"] forState:UIControlStateHighlighted];
    [_publishButton sizeToFit];
    [_publishButton addTarget:self action:@selector(publishButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_publishButton];
    
    _backButton = [[UIButton alloc] init];
    [_backButton setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [_backButton setBackgroundImage:[UIImage imageNamed:@"back_highlight"] forState:UIControlStateHighlighted];
    [_backButton sizeToFit];
    [_backButton addTarget:self action:@selector(backButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_backButton];
}


#pragma mark - Layout.

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _backButton.x = [SPPublishSizes editPublishButtonLeftMargin];
    _backButton.y = [SPPublishSizes editPublishButtonTopMargin];
    
    _publishButton.tail = self.contentView.width - [SPPublishSizes editPublishButtonLeftMargin];
    _publishButton.middleY = _backButton.middleY;
    
    _backLabel.middleX = _backButton.middleX;
    _backLabel.y = _backButton.bottom + [SPPublishSizes buttonTitleGap];
    
    _publishLabel.middleX = _publishButton.middleX;
    _publishLabel.y = _backLabel.y;
}

- (CGFloat)cellHeight {
    return 120;
}


#pragma mark - Setter.

- (void)setDescribeData:(MCTableBaseDescribeData *)describeData {
    if ([describeData isKindOfClass:[SPPublishEditDescribeData class]]) {
        SPPublishEditDescribeData *data = (SPPublishEditDescribeData *)describeData;
        self.delegate = data.delegate;
    }
}


#pragma mark - Actions.

- (void)publishButtonClicked:(id)sender {
    [_delegate editFinishedAndPublish:self];
}

- (void)backButtonClicked:(id)sender {
    [_delegate editFinishedAndBack:self];
}

@end
