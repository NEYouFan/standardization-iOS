//
//  SPShareCollectionViewCell.h
//  StandardizationPractice
//
//  Created by 陶泽宇 on 2016/10/27.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SPSharePopUpView.h"
extern CGFloat const kShareCollectionCellHeight;

@protocol SPShareCollectionViewCellDelegate <NSObject>

- (void)onClickShareItem;

@end

@interface SPShareCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong)SPShareContentData *data;
@property (nonatomic, weak) id<SPShareCollectionViewCellDelegate> delegate;

@end
