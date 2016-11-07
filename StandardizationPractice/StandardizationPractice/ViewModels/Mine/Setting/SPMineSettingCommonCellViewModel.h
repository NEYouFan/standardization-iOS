//
//  SPMineSettingCommonCellViewModel.h
//  StandardizationPractice
//
//  Created by Baitianyu on 21/10/2016.
//  Copyright © 2016 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SPMineSettingCellDescribeData;

@interface SPMineSettingCommonCellViewModel : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *rightTitle;
@property (nonatomic, assign) BOOL showRightTitle;
@property (nonatomic, assign) UITableViewCellSelectionStyle selectionStyle;

- (instancetype)initWithDescribeData:(SPMineSettingCellDescribeData *)describeData;

@end
