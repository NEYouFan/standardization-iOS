//
//  SPMineSettingCommonCellViewModel.m
//  StandardizationPractice
//
//  Created by Baitianyu on 21/10/2016.
//  Copyright © 2016 Netease. All rights reserved.
//

#import "SPMineSettingCommonCellViewModel.h"
#import "SPMineSettingCellDescribeData.h"

@implementation SPMineSettingCommonCellViewModel

- (instancetype)initWithDescribeData:(SPMineSettingCellDescribeData *)describeData {
    if (self = [super init]) {
        _title = describeData.title;
        _rightTitle = describeData.rightTitle;
        _showRightTitle = _rightTitle.length > 0;
        _selectionStyle = describeData.selectionStyle;
    }
    
    return self;
}

@end
