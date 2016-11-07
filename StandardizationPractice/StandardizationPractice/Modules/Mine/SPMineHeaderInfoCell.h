//
//  SPMineHeaderInfoCell.h
//  StandardizationPractice
//
//  Created by Baitianyu on 19/10/2016.
//  Copyright © 2016 Netease. All rights reserved.
//

#import "MCTableBaseCell.h"

@class SPMineHeaderInfoCellViewModel;
@class SPMineHeaderInfoCell;

@protocol SPMineHeaderInfoCellDelegate <NSObject>

@optional
- (void)loginOrRegister:(SPMineHeaderInfoCell *)cell;

@end

@interface SPMineHeaderInfoCell : MCTableBaseCell

@property (nonatomic, strong) SPMineHeaderInfoCellViewModel *viewModel;
@property (nonatomic, weak) id<SPMineHeaderInfoCellDelegate> delegate;

@end
