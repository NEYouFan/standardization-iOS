//
//  SPMineOperationCellViewModel.h
//  StandardizationPractice
//
//  Created by Baitianyu on 19/10/2016.
//  Copyright © 2016 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SPMineCellDescribeData;

@interface SPMineOperationCellViewModel : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIImage *iconImage;

- (instancetype)initWithDescribeData:(SPMineCellDescribeData *)describeData;

@end
