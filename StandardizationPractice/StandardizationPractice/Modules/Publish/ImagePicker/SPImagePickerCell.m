//
//  SPImagePickerCell.m
//  StandardizationPractice
//
//  Created by Baitianyu on 01/11/2016.
//  Copyright © 2016 Netease. All rights reserved.
//

#import "SPImagePickerCell.h"

@interface SPImagePickerCell ()

@property (nonatomic, strong) UIButton *selectButton;

@end

@implementation SPImagePickerCell

#pragma mark - Life cycle.

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self loadSubviews];
    }
    
    return self;
}


#pragma mark - Load views.

- (void)loadSubviews {
    _selectButton = [[UIButton alloc] init];
    [_selectButton addTarget:self action:@selector(selectButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_selectButton];
}


#pragma mark - Layout.

- (void)layoutSubviews {
    [super layoutSubviews];
    _selectButton.frame = self.contentView.bounds;
}


#pragma mark - Override.

- (void)selectedWithIndex:(NSInteger)index {
    
}

- (void)deselected {
    
}


#pragma mark - Actions.

- (void)selectButtonClicked:(id)sender {
    [self trySelect];
}

@end
