//
//  MCTableBaseCell.m
//  MultiCellTypeTableViewOC
//
//  Created by Baitianyu on 8/26/16.
//  Copyright © 2016 Baitianyu. All rights reserved.
//

#import "MCTableBaseCell.h"

static const CGFloat defaultCellHeight = -1.0;

@implementation MCTableBaseCell

#pragma mark - Life cycle.

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
    }
    
    return self;
}

- (CGFloat)cellHeight {
    return defaultCellHeight;
}

@end
