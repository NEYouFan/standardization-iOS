//
//  SPMineSettingLogoutCell.h
//  StandardizationPractice
//
//  Created by Baitianyu on 21/10/2016.
//  Copyright © 2016 Netease. All rights reserved.
//

#import "MCTableBaseCell.h"

@class SPMineSettingLogoutCell;

@protocol SPMineSettingLogoutDelegate <NSObject>

@optional
- (void)logout:(SPMineSettingLogoutCell *)cell;

@end

@interface SPMineSettingLogoutCell : MCTableBaseCell

@property (nonatomic, weak) id<SPMineSettingLogoutDelegate> delegate;

@end
