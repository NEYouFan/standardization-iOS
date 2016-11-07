//
//  SPMineSettingCellDescribeData.h
//  StandardizationPractice
//
//  Created by Baitianyu on 21/10/2016.
//  Copyright © 2016 Netease. All rights reserved.
//

#import "MCTableBaseDescribeData.h"
#import "SPMineSettingLogoutCell.h"
#import "SPMineSettingSwitchCell.h"

@interface SPMineSettingCellDescribeData : MCTableBaseDescribeData

@property (nonatomic, weak) id<SPMineSettingSwitchDelegate> switchDelegate;
@property (nonatomic, weak) id<SPMineSettingLogoutDelegate> logoutDelegate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *rightTitle;
@property (nonatomic, assign, getter=isSwitchOn) BOOL switchOn;
@property (nonatomic, assign) UITableViewCellSelectionStyle selectionStyle;

@end
