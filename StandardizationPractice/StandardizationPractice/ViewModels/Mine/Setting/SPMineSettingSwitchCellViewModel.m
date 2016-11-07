//
//  SPMineSettingSwitchCellViewModel.m
//  StandardizationPractice
//
//  Created by Baitianyu on 21/10/2016.
//  Copyright © 2016 Netease. All rights reserved.
//

#import "SPMineSettingSwitchCellViewModel.h"
#import "SPMineSettingCellDescribeData.h"

@implementation SPMineSettingSwitchCellViewModel

- (instancetype)initWithDescribeData:(SPMineSettingCellDescribeData *)describeData {
    if (self = [super init]) {
        _title = describeData.title;
        _switchOn = describeData.isSwitchOn;
        _delegate = describeData.switchDelegate;
    }
    
    return self;
}

@end
