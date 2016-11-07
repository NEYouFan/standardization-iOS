//
//  SPMineSettingController.h
//  StandardizationPractice
//
//  Created by Baitianyu on 21/10/2016.
//  Copyright © 2016 Netease. All rights reserved.
//

#import "SPBaseViewController.h"

typedef NS_ENUM(NSInteger, SPMineSettingActionType) {
    SPMineSettingActionTypeNone = 0,
    SPMineSettingActionTypeLogout,
    SPMineSettingActionTypeClearCache
};

@class SPMineSettingController;

@protocol SPMineSettingControllerDelegate <NSObject>

@required
- (void)refreshUser:(SPMineSettingController *)settingController;

@end

@interface SPMineSettingController : SPBaseViewController

@property (nonatomic, weak) id<SPMineSettingControllerDelegate> delegate;

@end
