//
//  SPAlbumChooserCell.m
//  StandardizationPractice
//
//  Created by Baitianyu on 31/10/2016.
//  Copyright © 2016 Netease. All rights reserved.
//

#import "SPAlbumChooserCell.h"
#import "SPPublishSizes.h"
#import "UIView+Frame.h"
#import "UIView+SPLine.h"

@interface SPAlbumChooserCell ()

@property (nonatomic, strong) UIImageView *thumbnailImageView;
@property (nonatomic, strong) UILabel *groupNameLabel;
@property (nonatomic, strong) UIImageView *arrowImageView;

@end

@implementation SPAlbumChooserCell

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
    
    _thumbnailImageView = [[UIImageView alloc] init];
    [self.contentView addSubview:_thumbnailImageView];
    
    _groupNameLabel = [[UILabel alloc] init];
    _groupNameLabel.font = [SPPublishSizes albumChooserGroupNameFont];
    _groupNameLabel.textColor = [SPThemeColors lightTextColor];
    [self.contentView addSubview:_groupNameLabel];
    
    _arrowImageView = [[UIImageView alloc] init];
    [self.contentView addSubview:_arrowImageView];
}


#pragma mark - Layout.

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _thumbnailImageView.size = [SPPublishSizes albumChooserThumbnailSize];
    _thumbnailImageView.x = [SPThemeSizes leftMargin];
    _thumbnailImageView.middleY = self.contentView.height / 2;
    
    [_groupNameLabel sizeToFit];
    _groupNameLabel.x = _thumbnailImageView.tail + [SPPublishSizes albumChooserThumbnailGroupGap];
    _groupNameLabel.middleY = self.contentView.height / 2;
    
    _arrowImageView.tail = self.contentView.width - [SPThemeSizes rightMargin];
    _arrowImageView.middleY = self.contentView.height / 2;
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake([SPThemeSizes screenWidth], [SPPublishSizes albumChooserCellHeight]);
}


#pragma mark - Setter.

- (void)setViewModel:(SPAlbumChooserCellViewModel *)viewModel {
    if (_viewModel == viewModel) {
        return;
    }
    
    _viewModel = viewModel;
    _thumbnailImageView.image = _viewModel.thumbnailImage;
    _groupNameLabel.text = _viewModel.groupName;
}

@end
