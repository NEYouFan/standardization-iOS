//
//  SPPublishEditImageCell.m
//  StandardizationPractice
//
//  Created by Baitianyu on 28/10/2016.
//  Copyright © 2016 Netease. All rights reserved.
//

#import "SPPublishEditImageCell.h"
#import "SPPublishColors.h"
#import "SPPublishSizes.h"
#import "UIView+Frame.h"
#import "SPPublishEditDescribeData.h"
#import "UIView+SPLine.h"

@interface SPPublishEditImageCell ()

@property (nonatomic, strong) UIImageView *editImageView;

@end


@implementation SPPublishEditImageCell

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
    _editImageView = [[UIImageView alloc] init];
    [self.contentView addSubview:_editImageView];
}


#pragma mark - Layout.

- (void)layoutSubviews {
    [super layoutSubviews];
    _editImageView.width = self.contentView.width;
    _editImageView.height = [SPPublishSizes editImageHeight];
    _editImageView.middleY = self.contentView.height / 2;
    _editImageView.x = 0;
}

- (CGFloat)cellHeight {
    return [SPPublishSizes editImageHeight] + [SPPublishSizes editImageCellVerticalMargin] * 2;
}


#pragma mark - Setter.

- (void)setDescribeData:(MCTableBaseDescribeData *)describeData {
    if ([describeData isKindOfClass:[SPPublishEditDescribeData class]]) {
        SPPublishEditDescribeData *data = (SPPublishEditDescribeData *)describeData;
        _editImageView.image = data.image;
    }
}

@end
