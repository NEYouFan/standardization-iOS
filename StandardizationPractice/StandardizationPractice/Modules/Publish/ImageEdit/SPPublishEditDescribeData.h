//
//  SPPublishEditDescribeData.h
//  StandardizationPractice
//
//  Created by Baitianyu on 28/10/2016.
//  Copyright © 2016 Netease. All rights reserved.
//

#import "MCTableBaseDescribeData.h"
#import "SPPulishEditFinishCell.h"

@interface SPPublishEditDescribeData : MCTableBaseDescribeData

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, weak) id<SPPublishEditFinishCellDelegate> delegate;

@end
