//
//  SPSearchHeaderTableViewCell.m
//  StandardizationPractice
//
//  Created by 陶泽宇 on 2016/10/27.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import "SPSearchHeaderTableViewCell.h"
#import "UIView+Frame.h"
#import "UIView+SPLine.h"
#import "SPSearchSizes.h"
#import "SPSearchColors.h"
#import <HTCommonUtility/ColorUtils.h>

const CGFloat kSearchHeaderCellHeight = 28;

@interface SPSearchHeaderTableViewCell ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *iconView;

@end

@implementation SPSearchHeaderTableViewCell

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
    _iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"search_history"]];
    _iconView.frame = CGRectMake(26, 11, 16, 16);
    [self.contentView addSubview:_iconView];
    
    _titleLabel = [[UILabel alloc] init ];
    _titleLabel.frame = CGRectMake(_iconView.x + _iconView.width + 9, _iconView.y, [SPThemeSizes screenWidth] - 100 , _iconView.height);
    _titleLabel.text = @"历史记录";
    _titleLabel.textColor = [SPSearchColors searchTextColor];
    _titleLabel.font = [SPSearchSizes searchHeaderTextFont];
    _titleLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:_titleLabel];
}

#pragma mark -layout Subviews
- (void)layoutSubviews{
    if (self.cellType == SPSearchHeaderCellType_Guess) {
        _iconView.frame = CGRectMake(23.5, 13, 21, 12);
    }else {
        _iconView.frame = CGRectMake(26, 11, 16, 16);
    }
    _titleLabel.frame = CGRectMake(_iconView.x + _iconView.width + 9, _iconView.y, [SPThemeSizes screenWidth] - 100 , _iconView.height);
}

#pragma mark - fill data.

- (void)setCellType:(SPSearchHeaderCellType)cellType{
    _cellType = cellType;
    if (cellType == SPSearchHeaderCellType_Guess) {
        _titleLabel.text = @"猜你想搜";
        _iconView.image = [UIImage imageNamed:@"search_guess"];
    }else{
        _titleLabel.text = @"历史记录";
        _iconView.image = [UIImage imageNamed:@"search_history"];
    }
    [self setNeedsLayout];
}


@end
