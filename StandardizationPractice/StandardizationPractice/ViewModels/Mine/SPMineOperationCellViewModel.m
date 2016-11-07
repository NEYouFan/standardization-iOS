//
//  SPMineOperationCellViewModel.m
//  StandardizationPractice
//
//  Created by Baitianyu on 19/10/2016.
//  Copyright © 2016 Netease. All rights reserved.
//

#import "SPMineOperationCellViewModel.h"
#import "SPMineCellDescribeData.h"

@implementation SPMineOperationCellViewModel

- (instancetype)initWithDescribeData:(SPMineCellDescribeData *)describeData {
    if (self = [super init]) {
        _title = describeData.title;
        _iconImage = [UIImage imageNamed:describeData.iconName];
    }
    
    return self;
}

@end
