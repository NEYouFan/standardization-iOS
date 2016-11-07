//
//  SPTableViewGapCell.m
//  StandardizationPractice
//
//  Created by Baitianyu on 18/10/2016.
//  Copyright © 2016 Netease. All rights reserved.
//

#import "SPTableViewGapCell.h"

@implementation SPTableViewGapCell

#pragma mark - Life cycle.

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = [SPThemeColors backgroundColor];
    }
    
    return self;
}

- (CGFloat)cellHeight {
    return [SPThemeSizes cellGap];
}

@end
