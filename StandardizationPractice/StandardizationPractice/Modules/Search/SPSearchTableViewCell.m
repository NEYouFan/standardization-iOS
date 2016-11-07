//
//  SPSearchTableViewCell.m
//  StandardizationPractice
//
//  Created by 陶泽宇 on 2016/10/25.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import "SPSearchTableViewCell.h"
#import "UIView+Frame.h"
#import "SPSearchColors.h"
#import "SPSearchSizes.h"
#import "UIView+SPLine.h"
#import <HTCommonUtility/ColorUtils.h>

const CGFloat kSearchCellHeight = 36;

@interface SPSearchTableViewCell ()

@property (nonatomic, strong) UILabel *titleLabel;

@end


@implementation SPSearchTableViewCell

# pragma mark -init
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self loadSubviews];
    }
    return self;
}

#pragma mark  -Load Subviews
- (void)loadSubviews{
    UIImageView *iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"search_location"]];
    iconView.frame = CGRectMake(26, 18, 20, 16);
    [self.contentView addSubview:iconView];

    _titleLabel = [[UILabel alloc] init];
    _titleLabel.textColor = [SPSearchColors searchTextColor];
    _titleLabel.font = [SPSearchSizes searchCellTextFont];
    _titleLabel.textAlignment = NSTextAlignmentLeft;
    _titleLabel.frame = CGRectMake(85, 18, [SPThemeSizes screenWidth] - 85*2 , iconView.height);
    
    UIImageView *accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"search_accessory"]];
    accessoryView.frame = CGRectMake([SPThemeSizes screenWidth] - 8 - 8, 20, 8, 12);
    [self.contentView addSubview:accessoryView];
    
    [self.contentView sp_addBottomLineWithLeftMargin:55 rightMargin:0];
    [self.contentView addSubview:_titleLabel];
    
}

#pragma mark -layout Subviews
- (void)layoutSubviews{
    
}

#pragma mark - fill data.

- (void)setData:(id)data{
    if ([data isKindOfClass:[NSString class]]) {
        _data = data;
        _titleLabel.text = data;
        [self setNeedsLayout];
    }
}

@end
