//
//  SPShareCollectionViewCell.m
//  StandardizationPractice
//
//  Created by 陶泽宇 on 2016/10/27.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import "SPShareCollectionViewCell.h"
#import <HTCommonUtility/UIView+Frame.h>
#import <HTCommonUtility/ColorUtils.h>

const CGFloat kShareCollectionCellHeight = 105;
@interface SPShareCollectionViewCell ()

@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UILabel *label;

@end

@implementation SPShareCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self loadSubViews];
    }
    return self;
}

- (void)loadSubViews{
    _button = [UIButton buttonWithType:UIButtonTypeCustom];
    _button.width = 50;
    _button.height = 50;
    _button.y = 18;
    _button.middleX = self.contentView.middleX;
    [_button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_button];
    
    _label = [[UILabel alloc] init];
    _label.text = self.data.title;
    _label.font = [UIFont fontWithName:@"Arial-BoldMT" size:13];
    _label.textColor = [UIColor colorWithRGBValue:0x999999];
    _label.textAlignment = NSTextAlignmentCenter;
    _label.width = self.contentView.width - 10;
    _label.y = _button.bottom + 12;
    _label.height = 14;
    _label.middleX = self.contentView.middleX;
    [self.contentView addSubview:_label];
}

- (void)setData:(SPShareContentData *)data{
    _data = data;
    [_button setImage:self.data.image forState:UIControlStateNormal];
    [_button setImage:self.data.imagePressed forState:UIControlStateHighlighted];
    _label.text = self.data.title;
    [self setNeedsLayout];
}

- (void)buttonClicked:(id)sender{
    if ([self.delegate respondsToSelector:@selector(onClickShareItem)]) {
        [self.delegate onClickShareItem];
    }
}

@end
