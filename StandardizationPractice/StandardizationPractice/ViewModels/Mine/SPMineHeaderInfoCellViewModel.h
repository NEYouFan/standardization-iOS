//
//  SPMineHeaderInfoCellViewModel.h
//  StandardizationPractice
//
//  Created by Baitianyu on 19/10/2016.
//  Copyright © 2016 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPMineHeaderInfoCell.h"

@class SPMineCellDescribeData;

@interface SPMineHeaderInfoCellViewModel : NSObject

@property (nonatomic, assign) BOOL alreadyLogin;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, strong) UIImage *headerImage;
@property (nonatomic, weak) id<SPMineHeaderInfoCellDelegate> delegate;

- (instancetype)initWithDescribeData:(SPMineCellDescribeData *)describeData;

@end
