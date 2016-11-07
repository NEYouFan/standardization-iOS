//
//  SPMineHeaderInfoCellViewModel.m
//  StandardizationPractice
//
//  Created by Baitianyu on 19/10/2016.
//  Copyright © 2016 Netease. All rights reserved.
//

#import "SPMineHeaderInfoCellViewModel.h"
#import "SPMineCellDescribeData.h"
#import "SPUserDataManager.h"

@implementation SPMineHeaderInfoCellViewModel

- (instancetype)initWithDescribeData:(SPMineCellDescribeData *)describeData {
    if (self = [super init]) {
        _delegate = describeData.delegate;
        _headerImage = [UIImage imageNamed:[SPUserDataManager sharedInstance].headerIcon];
        _userName = [SPUserDataManager sharedInstance].userName;
        _alreadyLogin = [SPUserDataManager sharedInstance].alreadyLogin;
    }
    
    return self;
}

@end
