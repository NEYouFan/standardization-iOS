//
//  SPMineSettingSwitchCell.h
//  StandardizationPractice
//
//  Created by Baitianyu on 21/10/2016.
//  Copyright © 2016 Netease. All rights reserved.
//

#import "MCTableBaseCell.h"

@protocol SPMineSettingSwitchDelegate <NSObject>

@optional
- (void)switchChanged:(BOOL)switchOn;

@end

@class SPMineSettingSwitchCellViewModel;

@interface SPMineSettingSwitchCell : MCTableBaseCell

@property (nonatomic, weak) id<SPMineSettingSwitchDelegate> delegate;
@property (nonatomic, strong) SPMineSettingSwitchCellViewModel *viewModel;

@end
