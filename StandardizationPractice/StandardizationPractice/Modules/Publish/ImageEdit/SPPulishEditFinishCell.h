//
//  SPPulishEditFinishCell.h
//  StandardizationPractice
//
//  Created by Baitianyu on 28/10/2016.
//  Copyright © 2016 Netease. All rights reserved.
//

#import "MCTableBaseCell.h"

@class SPPulishEditFinishCell;

@protocol SPPublishEditFinishCellDelegate <NSObject>

@required
- (void)editFinishedAndPublish:(SPPulishEditFinishCell *)cell;
- (void)editFinishedAndBack:(SPPulishEditFinishCell *)cell;

@end

@interface SPPulishEditFinishCell : MCTableBaseCell

@property (nonatomic, weak) id<SPPublishEditFinishCellDelegate> delegate;

@end
