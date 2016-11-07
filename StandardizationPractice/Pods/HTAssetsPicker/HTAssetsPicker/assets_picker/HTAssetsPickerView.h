//
//  HTAssetsPickerView.h
//  JWAssetsPicker
//
//  Created by jw-mbp on 9/16/15.
//  Copyright (c) 2015 jw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "HTAssetItem.h"
#import "HTAssetsPickerCell.h"
#import "HTAssetsHelper.h"
#import "HTAsset.h"


@protocol HTAssetsPickerDelegate;

/**
 *  HTAssetsPickerView用于视觉上选择单个相册的内容，但可以缓存住之前相册的选择结果，
 *  通过设置assetGroup来切换相册
 *  备注:如果有相机按钮，应用层需要提供图片HTAssetsPickerCamera.png
 */
@interface HTAssetsPickerView : UICollectionView


@property (nonatomic,weak) id<HTAssetsPickerDelegate> assetsPickerDelegate;

/**
 *  HTAssetsPicker的model，用来读取资源信息的ALAssetsGroup
 *  iOS8之前使用该属性设置相册，iOS8之后使用assetCollection，
 *  即使使用assetGroup，内部实现也会使用PHAssetCollection
 */
@property (nonatomic,strong) ALAssetsGroup *assetGroup;

/**
 *  HTAssetsPicker的model，用来读取资源信息的PHAssetCollection
 *  iOS8之后使用该属性设置相册
 */
@property (nonatomic,strong) PHAssetCollection* assetCollection;

/**
 *  最大选择个数，默认NSIntegerMax
 */
@property (nonatomic,assign) NSInteger maxSelectedCount;

/**
 *  所要选择资源类型，支持图片、视频，默认都显示
 */
@property (nonatomic, assign) HTAssetsType assetsType;

/**
 *  设置交互类型，支持单击、双击、长按三种，默认单击。
 */
@property (nonatomic, assign) HTAssetPickerCellInteactType interactTypes;

/**
 *  每行item数量，默认3
 */
@property (nonatomic,assign) NSInteger itemsCountEachRow;

/**
 *  四周留白，默认0
 */
@property (nonatomic,assign) UIEdgeInsets inset;

/**
 *  item之间左右留白，默认4 points
 */
@property (nonatomic,assign) CGFloat interItemSpacing;

/**
 *  item之间上下留白，默认4 points
 */
@property (nonatomic,assign) CGFloat lineSpacing;

/**
 *  item尺寸，如果未指定，则根据interitemSpacing或者lineSpacing则自动计算
 *  计算规则：根据每行个数及interitemSpacing计算出正方形item
 */
@property(nonatomic,assign) CGSize itemSize;

/**
 *  item是否根据asset时间倒序摆放
 *  默认YES,倒序摆放
 */
@property(nonatomic,assign) BOOL itemReverseOrder;

/**
 *  相机按钮项所在位置
 *  小于0或者nil：无相机按钮
 *  等于0：第一个位置
 *  大于0且小于资源数：指定位置
 *  大于资源数：末尾位置
 *  默认为：-1，无相机按钮
 */
@property (nonatomic,assign) NSInteger cameraItemIndex;

/**
 *  相机图片名称
 */
@property (nonatomic,copy) NSString* cameraImageName;

/**
 *  相册选择器使用缩略图大小，默认使用150 * 150
 */
@property (nonatomic,assign) CGSize itemThumbnailSize;

/**
 *  构造函数。
 *  @param cellClass cell for item
 */
- (instancetype)initWithCellClass:(Class)cellClass;

/**
 *  构造函数。
 *  @param cellClass cell for item
 *  @assetItemClass 自定义assetItem,需要是HTAssetItem的子类。默认HTAssetItem。
 */
- (instancetype)initWithCellClass:(Class)cellClass assetItemClass:(Class)assetItemClass;

/**
 *  具有默认选中项的构造函数。
 *
 *  @param assets 初始为选择状态的assets
 *  @param cellClass cell for item
 *
 */
- (instancetype)initWithSelectedAssets:(NSArray<HTAsset*>*)assets cellClass:(Class)cellClass;

/**
 *  具有默认选中项的构造函数。
 *
 *  @param assets 初始为选择状态的assets
 *  @param cellClass cell for item
 *  @assetItemClass 自定义assetItem,需要是HTAssetItem的子类。默认HTAssetItem。
 *
 */
- (instancetype)initWithSelectedAssets:(NSArray<HTAsset*>*)assets cellClass:(Class)cellClass assetItemClass:(Class)assetItemClass;

/**
 *  获取当前相册的所有assets
 *  用例：预览所有
 *
 */
- (NSArray<HTAsset*>*)allAssets;

/**
 *  获取选中的assets
 *  资源按照选中顺序排序，且可能所属于不同相册
 *
 *  @return 选中的assets
 */
- (NSArray<HTAsset*>*)selectedAssets;

/**
 *  获取选中的assets个数。比用[[imagepicker selectedAssets] count]效率高
 *  @return 选中的assets个数
 */
- (NSUInteger)selectedAssetsCount;

/**
 *  获取assetItems。当用户自定义了HTAssetItem，并修改所有的AssetItem的属性，可以使用该接口。
 *  用例：当选择个数等于最大选择数时，修改所有的AssetItem中自定义的disable属性，cell根据disable属性修改样式。  
 *  @return 所有的assetItems
 */
- (NSArray<HTAssetItem *> *)assetItems;

/**
 *  清空所有选择
 */
- (void)clear;

/**
 *  根据assets选择Item
 *
 */
- (void)selectAssets:(NSArray<HTAsset*>*)assets;

/**
 *  根据assets取消选择Item
 *
 */
- (void)deselectAssets:(NSArray<HTAsset*>*)assets;

/**
 *  完成选择
 */
- (void)finishSelection;

/**
 *  取消选择
 */
- (void)cancelSelection;

/**
 * 重新加载
 */
- (void)reloadWithCompletionBlock:(void (^)(void))block;
@end


@protocol HTAssetsPickerDelegate <NSObject>
/**
 *  选择完成回调
 *
 *  @param assetsPicker
 *  @param assets       有序选择的HTAsset
 */
- (void)assetsPicker:(HTAssetsPickerView*)assetsPicker didFinishPickingWithAssets:(NSArray<HTAsset*>*)assets;

/**
 *  取消选择回调
 *
 *  @param assetsPicker
 */
- (void) assetsPickerDidCancelPicking:(HTAssetsPickerView*)assetsPicker;

@optional
/**
 *  选择单个asset回调
 *  用例：单选立即返回
 *
 *  @param assetsPicker
 *  @param asset        所选资源
 */
- (void)assetsPicker:(HTAssetsPickerView*)assetsPicker didSelectAsset:(HTAsset*)asset;

/**
 *  取消选择单个asset回调
 *  用例：单选立即返回
 *
 *  @param assetsPicker
 *  @param asset        所选资源
 */
- (void)assetsPicker:(HTAssetsPickerView*)assetsPicker didDeselectAsset:(HTAsset*)asset;

/**
 *  切换相册
 *  用例:清除已选资源
 *
 *  @param assetsPicker
 */
- (void)assetsPickerSwitchAssetsGroup:(HTAssetsPickerView*)assetsPicker;

/**
 *  达到最大选择数
 *  用例：弹出超出最大数限制提示用户
 *
 *  @param assetsPicker
 */
- (void)assetsPickerDidExceedMaxSelectedCount:(HTAssetsPickerView*)assetsPicker;


/**
 *  相机点击回调
 *
 *  @param assetsPicker
 */
- (void)assetsPickerCameraClicked:(HTAssetsPickerView *)assetsPicker;


@end
