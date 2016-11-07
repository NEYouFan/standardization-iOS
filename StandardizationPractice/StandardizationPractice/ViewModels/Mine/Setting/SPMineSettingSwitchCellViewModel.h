//
//  SPMineSettingSwitchCellViewModel.h
//  StandardizationPractice
//
//  Created by Baitianyu on 21/10/2016.
//  Copyright © 2016 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPMineSettingSwitchCell.h"

@class SPMineSettingCellDescribeData;

@interface SPMineSettingSwitchCellViewModel : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) BOOL switchOn;
@property (nonatomic, weak) id<SPMineSettingSwitchDelegate> delegate;

- (instancetype)initWithDescribeData:(SPMineSettingCellDescribeData *)describeData;

@end
