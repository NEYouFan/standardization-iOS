//
//  MCTableBaseCell.h
//  MultiCellTypeTableViewOC
//
//  Created by Baitianyu on 8/26/16.
//  Copyright © 2016 Baitianyu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MCTableBaseDescribeData;

@interface MCTableBaseCell : UITableViewCell

@property (nonatomic, strong) MCTableBaseDescribeData *describeData;

// Override this method in subclasses.
- (CGFloat)cellHeight;

@end
