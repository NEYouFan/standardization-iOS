//
//  SPMineCellDescribeData.h
//  StandardizationPractice
//
//  Created by Baitianyu on 19/10/2016.
//  Copyright © 2016 Netease. All rights reserved.
//

#import "MCTableBaseDescribeData.h"
#import "SPMineHeaderInfoCell.h"

@interface SPMineCellDescribeData : MCTableBaseDescribeData

@property (nonatomic, copy) NSString *iconName;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, weak) id<SPMineHeaderInfoCellDelegate> delegate;

@end
