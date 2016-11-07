//
//  HTAssetPickerCell.h
//  JWAssetsPicker
//
//  Created by jw-mbp on 9/17/15.
//  Copyright (c) 2015 jw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTAssetItem.h"


/**
 *  cell所支持的交互类型
 */
typedef NS_OPTIONS(NSUInteger, HTAssetPickerCellInteactType) {
    HTAssetPickerCellInteactTypeNone        = 0,
    HTAssetPickerCellInteactTypeSingleTapped = 1 << 0,///单击
    HTAssetPickerCellInteactTypeDoubleTapped = 1 << 1,///双击
    HTAssetPickerCellInteactTypeLongPressed  = 1 << 2///长按
};

@protocol HTAssetPickerCellDelegate;

@interface HTAssetsPickerCell : UICollectionViewCell

@property (nonatomic,strong) HTAssetItem* assetItem;
@property (nonatomic,weak) id<HTAssetPickerCellDelegate> delegate;
@property (nonatomic,strong) UIImageView* contentImageView;

/**
 *  子类需要重写该方法，以接收选择状态
 *  不要在这里做动画，只表示一种状态，可能是reloadData引起
 *
 *  @param index    被选择的索引，从1开始
 */
- (void)selectedWithIndex:(NSInteger)index;

/**
 *  子类需要重写该方法，以接收不选择状态
 *  不要在这里做动画，只表示一种状态，可能是reloadData引起
 */
- (void)deselected;

/**
 *  子类需要重写该方法，以复位到初始状态
 *  [super reset] should be called.
 */
- (void)reset;

/**
 *  通知cell被点击
 *  默认忽略所有的交互行为。子类需要重写该方法，以此来决定交互事件所对应的行为
 *  例如：单击选择，长按预览等
 *
 */
- (void)onInteracted:(HTAssetPickerCellInteactType)interactType;


/**
 *  设置model
 *  [super setAssetItem:assetItem] should be called by subclass if override.
 */
- (void)setAssetItem:(HTAssetItem *)assetItem;




/**
 *  试图选中
 *  用户可以根据返回结果做动画
 *
 *  @return 成功返回YES,否则返回NO
 */
- (BOOL)trySelect;

/**
 *  试图取消选中
 *  用户可以根据返回结果做动画
 *
 *  @return 成功返回YES,否则返回NO
 */
- (BOOL)tryDeselect;



@end

@protocol HTAssetPickerCellDelegate <NSObject>

@optional
- (BOOL)shouldSelectAssetsPickerCell:(HTAssetsPickerCell*)assetPickerCell;
- (BOOL)shouldDeselectAssetsPickerCell:(HTAssetsPickerCell*)assetPickerCell;

//可以在此做自定义动画、以及点击图片预览效果等
- (void)didSelectAssetsPickerCell:(HTAssetsPickerCell*)assetPickerCell;
- (void)didDeselectAssetsPickerCell:(HTAssetsPickerCell*)assetPickerCell;




@end
