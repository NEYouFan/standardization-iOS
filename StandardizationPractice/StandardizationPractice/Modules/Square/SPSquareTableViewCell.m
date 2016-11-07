//
//  SPSquareTableViewCell.m
//  StandardizationPractice
//
//  Created by 陶泽宇 on 2016/10/20.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import "SPSquareTableViewCell.h"
#import "UIView+Frame.h"
#import "SPThemeSizes.h"
#import "SPSquareSizes.h"
#import "SPSquareColors.h"
#import "SPPhoto.h"
#import <HTImageView/HTImageView.h>

const CGFloat kSquareCellHeight = 254;
const CGFloat kSquareLeftMargin = 8.5;
const CGFloat kSquareTopMargin = 8.5;
const CGFloat kSquareBottomMargin = 5.5;
const CGFloat kSquarePhotoHeight = 166.5;

@interface SPSquareTableViewCell ()

@property (nonatomic, strong) UIView *photoBackgroundView;
@property (nonatomic, strong) UIView *shadowView;
@property (nonatomic, strong) HTImageView *photoView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *numberLabel;
@property (nonatomic, strong) UILabel *locationLabel;
@property (nonatomic, strong) UIView *selectedView;

@end


@implementation SPSquareTableViewCell

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
    _photoBackgroundView = [[UIView alloc] init];
    _photoBackgroundView.backgroundColor = [UIColor whiteColor];
    _photoBackgroundView.clipsToBounds = YES;
    _photoBackgroundView.layer.cornerRadius = 4.0f;
    
    _shadowView = [[UIView alloc] init];
    _shadowView.layer.shadowOffset = CGSizeMake(0, 2);
    _shadowView.layer.shadowOpacity = 0.80;
    _shadowView.layer.shadowColor = [UIColor blackColor].CGColor;
    [_shadowView addSubview:_photoBackgroundView];

    _photoView = [[HTImageView alloc] init];
    [_photoView setNormalImageContentMode:UIViewContentModeScaleToFill
                         placeHodlerImage:[UIImage imageNamed:@"sqaure_photo_default"]
                              contentMode:UIViewContentModeScaleToFill
                               errorImage:nil
                              contentMode:UIViewContentModeScaleToFill];
    [_photoView setFadeInAnimationEnable:YES duration:0.5];
    [_photoBackgroundView addSubview:_photoView];
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.textColor = [SPSquareColors titleLabelTextColor];
    _titleLabel.font = [SPSquareSizes titleLabelFont];
    _titleLabel.textAlignment = NSTextAlignmentLeft;
    [_photoBackgroundView addSubview:_titleLabel];
    
    _numberLabel = [[UILabel alloc] init];
    _numberLabel.textColor = [SPSquareColors numberLabelTextColor];
    _numberLabel.font = [SPSquareSizes numberLabelFont];
    _numberLabel.textAlignment = NSTextAlignmentLeft;
    [_photoBackgroundView addSubview:_numberLabel];
    
    _locationLabel = [[UILabel alloc] init];
    _locationLabel.textColor = [SPSquareColors locationLabelTextColor];
    _locationLabel.font = [SPSquareSizes locationLabelFont];
    _locationLabel.textAlignment = NSTextAlignmentLeft;
    [_photoBackgroundView addSubview:_locationLabel];
    
    _selectedView = [[UIView alloc] init];
    _selectedView.backgroundColor = [SPSquareColors cellSelectedColor];
    _selectedView.hidden = YES;
    [_photoBackgroundView addSubview:_selectedView];
    
    self.contentView.backgroundColor = [SPSquareColors squareBackgroundColor];
    [self.contentView addSubview:_shadowView];
    
}

#pragma mark -layout Subviews
- (void)layoutSubviews{
    _shadowView.frame = CGRectMake(kSquareLeftMargin , kSquareTopMargin, [SPThemeSizes screenWidth] - 2*kSquareLeftMargin, kSquareCellHeight - kSquareTopMargin - kSquareBottomMargin);
    _photoBackgroundView.frame = _shadowView.bounds;
    _selectedView.frame = _photoBackgroundView.bounds;
    _photoView.frame = CGRectMake(0, 0, _photoBackgroundView.width, kSquarePhotoHeight);
    _titleLabel.frame = CGRectMake(12.5, _photoView.bottom - 30.5, _photoBackgroundView.width - 2 * 12.5, 18);
    _numberLabel.frame = CGRectMake(17.5, _photoView.bottom + 14.0, _photoBackgroundView.width - 2 * 17.5, 13);
    _locationLabel.frame = CGRectMake(17.5, _numberLabel.bottom + 14.0, _photoBackgroundView.width - 2 * 17.5, 12);
}

#pragma mark - fill data.

- (void)setData:(id)data{
    if ([data isKindOfClass:[SPPhoto class]]) {
        _data = data;
        SPPhoto *photo = data;
        _titleLabel.text = photo.title;
        [_photoView setImageWithUrl:[NSURL URLWithString: photo.imageUrl]];
        _numberLabel.text = photo.photoNo;
        _locationLabel.text = photo.location;
        [self setNeedsLayout];
    }
}

#pragma mark - overwrite father method

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    if (highlighted) {
        _selectedView.hidden = NO;
    }else{
        _selectedView.hidden = YES;
    }
}



@end

