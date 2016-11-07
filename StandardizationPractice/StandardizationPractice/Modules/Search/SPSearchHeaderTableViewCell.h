//
//  SPSearchHeaderTableViewCell.h
//  StandardizationPractice
//
//  Created by 陶泽宇 on 2016/10/27.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

extern CGFloat const kSearchHeaderCellHeight;

typedef NS_ENUM(NSInteger, SPSearchHeaderCellType){
    SPSearchHeaderCellType_History = 0,
    SPSearchHeaderCellType_Guess,
    
};


@interface SPSearchHeaderTableViewCell : UITableViewCell

@property (nonatomic, assign) SPSearchHeaderCellType cellType;

@end

