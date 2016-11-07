//
//  MCTableBaseDescribeData.h
//  MultiCellTypeTableViewOC
//
//  Created by Baitianyu on 8/26/16.
//  Copyright © 2016 Baitianyu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class MCTableBaseDescribeData;
@class MCTableBaseCell;

typedef void (^CustomCellBlock)(MCTableBaseCell *cell, MCTableBaseDescribeData *describeData);
typedef void (^SelectCellBlock)(MCTableBaseCell *cell, MCTableBaseDescribeData *describeData);

@interface MCTableBaseDescribeData : NSObject

@property (nonatomic, copy) Class cellClass;
@property (nonatomic, copy) CustomCellBlock customCellBlock;
@property (nonatomic, copy) SelectCellBlock selectCellBlock;

- (CGFloat)cellHeight;
- (CustomCellBlock)defaultCustomCellBlock;

@end
