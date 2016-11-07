//
//  MCTableBaseDescribeData.m
//  MultiCellTypeTableViewOC
//
//  Created by Baitianyu on 8/26/16.
//  Copyright © 2016 Baitianyu. All rights reserved.
//

#import "MCTableBaseDescribeData.h"
#import "MCTableBaseCell.h"

@interface MCTableBaseDescribeData ()

@property (nonatomic, weak) MCTableBaseCell *cell;

@end

@implementation MCTableBaseDescribeData

- (instancetype)init {
    if (self = [super init]) {
        _customCellBlock = [self defaultCustomCellBlock];
    }
    
    return self;
}

- (CustomCellBlock)defaultCustomCellBlock {
    return ^(MCTableBaseCell *cell, MCTableBaseDescribeData *describeData) {
        _cell = cell;
        cell.describeData = describeData;
    };
}

- (CGFloat)cellHeight {
    return [_cell cellHeight];
}

@end
