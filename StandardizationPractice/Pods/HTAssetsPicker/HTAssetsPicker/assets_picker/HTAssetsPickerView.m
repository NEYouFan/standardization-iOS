//
//  HTAssetsPicker.m
//  JWAssetsPicker
//
//  Created by jw-mbp on 9/16/15.
//  Copyright (c) 2015 jw. All rights reserved.
//

#import "HTAssetsPickerView.h"
#import "HTCameraAssetItem.h"
#import "HTAsset.h"

@implementation UICollectionView (Convenience)
- (NSArray *)aapl_indexPathsForElementsInRect:(CGRect)rect {
    NSArray *allLayoutAttributes = [self.collectionViewLayout layoutAttributesForElementsInRect:rect];
    if (allLayoutAttributes.count == 0) { return nil; }
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:allLayoutAttributes.count];
    for (UICollectionViewLayoutAttributes *layoutAttributes in allLayoutAttributes) {
        NSIndexPath *indexPath = layoutAttributes.indexPath;
        [indexPaths addObject:indexPath];
    }
    return indexPaths;
}
@end

static NSString* HTAssetsPickerCellClass = @"HTAssetsPickerCellClass";

@interface HTAssetsPickerView ()<HTAssetPickerCellDelegate, UICollectionViewDelegate, UICollectionViewDataSource>

/*正序或逆序摆放的item，根据itemReverseOrder决定*/
@property (nonatomic,copy) NSMutableArray<HTAssetItem*>* assetItems;

/**
 *  (1)保证选择顺序
 *  (2)可能在不同相册
 */
@property (nonatomic,copy) NSMutableArray<HTAssetItem*>* selectedAssetItems;

/**
 *  用户自定义的cell的类型
 */
@property (nonatomic, assign) Class cellClass;

/**
 *  用户自定义的model的类型
 */
@property (nonatomic, assign) Class assetItemClass;

@property (nonatomic, strong) UICollectionViewFlowLayout* flowLayout;

@property (nonatomic, assign) CGRect previousPreheatRect;
@end


@implementation HTAssetsPickerView

- (instancetype)initWithCellClass:(Class)cellClass
{
    return [self initWithSelectedAssets:nil cellClass:cellClass assetItemClass:HTAssetItem.class];
}

- (instancetype)initWithCellClass:(Class)cellClass assetItemClass:(Class)assetItemClass
{
    return [self initWithSelectedAssets:nil cellClass:cellClass assetItemClass:assetItemClass.class];
}

- (instancetype)initWithSelectedAssets:(NSArray<HTAsset*>*)assets cellClass:(Class)cellClass
{
    return [self initWithSelectedAssets:assets cellClass:cellClass assetItemClass:HTAssetItem.class];
}

- (instancetype)initWithSelectedAssets:(NSArray<HTAsset*>*)assets cellClass:(Class)cellClass assetItemClass:(Class)assetItemClass
{
    _flowLayout = [[UICollectionViewFlowLayout alloc]init];
    self = [super initWithFrame:CGRectZero collectionViewLayout:_flowLayout];
    if (self) {
        NSParameterAssert([cellClass isSubclassOfClass:HTAssetsPickerCell.class]);
        NSParameterAssert([assetItemClass isSubclassOfClass:HTAssetItem.class]);
        _assetItems = [[NSMutableArray alloc]init];
        _selectedAssetItems = [[NSMutableArray alloc]init];
        _itemsCountEachRow = 3;
        _cameraItemIndex = -1;
        _maxSelectedCount = NSIntegerMax;
        _cellClass = cellClass ? cellClass : [HTAssetsPickerCell class];
        _assetItemClass = assetItemClass;
        _interactTypes = HTAssetPickerCellInteactTypeSingleTapped;
        _itemReverseOrder = YES;
        _itemSize = CGSizeMake(0, 0);
        _itemThumbnailSize = CGSizeMake(150, 150);
        
        self.backgroundColor = [UIColor clearColor];
        self.dataSource = self;
        self.delegate = self;
        [self registerClass:_cellClass forCellWithReuseIdentifier:HTAssetsPickerCellClass];
        [self initGestureRecognizers];
        [self selectAssets:assets];
    }
    return self;
}

- (NSArray<HTAsset*>*)allAssets
{
    NSMutableArray<HTAsset*>* assets = [[NSMutableArray alloc]init];
    [_assetItems enumerateObjectsUsingBlock:^(HTAssetItem* obj, NSUInteger idx, BOOL *stop) {
        [assets addObject:obj.asset];
    }];
    return assets;
}
- (NSArray<HTAsset*>*)selectedAssets
{
    NSMutableArray<HTAsset*>* assets = [[NSMutableArray alloc]init];
    [_selectedAssetItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        HTAssetItem* item = obj;
        [assets addObject:item.asset];
    }];
    return assets;
    
    
}

- (NSUInteger)selectedAssetsCount
{
    return [_selectedAssetItems count];
}

- (NSArray<HTAssetItem *> *)assetItems
{
    return [_assetItems copy];
}

- (void)clear
{
    [_selectedAssetItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        HTAssetItem* item = obj;
        item.selected = NO;
        item.index = 0;
    }];
    [_selectedAssetItems removeAllObjects];
    [self reloadData];
}

- (void)selectAssets:(NSArray<HTAsset*>*)assets
{
    if (!assets || assets.count == 0) {
        return;
    }
    
    NSMutableArray<NSString*>* idsArray = [NSMutableArray new];
    [assets enumerateObjectsUsingBlock:^(HTAsset*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [idsArray addObject:[obj localIdentifier]];
    }];
    
    __block BOOL hasSelected = NO;
    [idsArray enumerateObjectsUsingBlock:^(NSString * _Nonnull identifier, NSUInteger UrlIdx, BOOL * _Nonnull urlStop) {
        [_assetItems enumerateObjectsUsingBlock:^(HTAssetItem*  _Nonnull item, NSUInteger itemIdx, BOOL * _Nonnull itemStop) {
            if ([identifier isEqual:[item.asset localIdentifier]]) {
                NSUInteger index = [_selectedAssetItems indexOfObject:item];
                if (index == NSNotFound) {
                    [_selectedAssetItems addObject:item];
                    item.index = [_selectedAssetItems count];
                    item.selected = YES;
                    hasSelected = YES;
                }
            }
        }];
    }];
    
    if (hasSelected) {
        [self reloadData];
    }
}

- (void)deselectAssets:(NSArray<HTAsset*>*)assets
{
    if (!assets) {
        return;
    }
    
    NSMutableArray<NSString*>* idsArray = [NSMutableArray new];
    [assets enumerateObjectsUsingBlock:^(HTAsset *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [idsArray addObject:[obj localIdentifier]];
    }];
    
    NSMutableArray<HTAssetItem*>* toRemoveItems = [[NSMutableArray alloc]init];
    
    __block BOOL hasDeselected = NO;
    [idsArray enumerateObjectsUsingBlock:^(NSString * _Nonnull identifier, NSUInteger UrlIdx, BOOL * _Nonnull urlStop) {
        [_selectedAssetItems enumerateObjectsUsingBlock:^(HTAssetItem*  _Nonnull item, NSUInteger itemIdx, BOOL * _Nonnull itemStop) {
            if ([identifier isEqual:[item.asset localIdentifier]]) {
                [toRemoveItems addObject:item];
                item.selected = NO;
                item.index = 0;
                hasDeselected = YES;
            }
        }];
    }];
    
    if (hasDeselected) {
        [toRemoveItems enumerateObjectsUsingBlock:^(HTAssetItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [_selectedAssetItems removeObject:obj];
        }];
        [self reloadData];
    }
}


- (void)finishSelection
{
    [self.assetsPickerDelegate assetsPicker:self didFinishPickingWithAssets:self.selectedAssets];
}

- (void)cancelSelection
{
    [self.assetsPickerDelegate assetsPickerDidCancelPicking:self];
}

- (void)setAssetGroup:(ALAssetsGroup *)assetGroup
{
    if (assetGroup == _assetGroup || !assetGroup) {
        return;
    }
    //8.0+ use photokit
    if (HTASSETSPICKER_USE_PHOTOKIT) {
        PHFetchResult<PHAssetCollection *> * fetchResult = [PHAssetCollection fetchAssetCollectionsWithALAssetGroupURLs:@[[assetGroup valueForProperty:ALAssetsGroupPropertyURL]] options:nil];

        if (fetchResult.count == 1) {
            PHAssetCollection *assetCollection = (PHAssetCollection *)fetchResult[0];
            if (assetCollection.localIdentifier != _assetCollection.localIdentifier) {
                _assetCollection = assetCollection;
            }else{
                return;
            }
        }else{
            return;
        }
    }else{//for 7.0
        _assetGroup = assetGroup;
    }
    [self reloadWithCompletionBlock:nil];

}

- (void)setAssetCollection:(PHAssetCollection *)assetCollection{
    if (assetCollection == _assetCollection || !assetCollection) {
        return;
    }
    _assetCollection = assetCollection;
    [self reloadWithCompletionBlock:nil];
}


- (void)reloadWithCompletionBlock:(void (^)(void))block
{
    [_assetItems removeAllObjects];
    [_selectedAssetItems removeAllObjects];
    void (^innerBlock)(void) = ^void(void){
        //插入相机item
        if (_cameraItemIndex !=-1) {
            HTCameraAssetItem* cameraItem = [[HTCameraAssetItem alloc]init];
            cameraItem.imageName = _cameraImageName;
            if (_cameraItemIndex >= 0 && _cameraItemIndex <= [_assetItems count]) {
                [_assetItems insertObject:cameraItem atIndex:_cameraItemIndex];
            }else if (_cameraItemIndex > [_assetItems count]){
                [_assetItems addObject:cameraItem];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadData];
            if (block) {
                block();
            }
        });
    };
    
    if (_assetCollection) {
        PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
        if (_assetsType == HTAssetsTypePhoto) {
            fetchOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeImage];
        }else if(_assetsType == HTAssetsTypeVideo){
            fetchOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeVideo];
        }
        PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:_assetCollection options:fetchOptions];
        [fetchResult enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj) {
                // 获取一个资源（PHAsset）
                PHAsset *asset = obj;
                [self createAndAddItemWithAsset:asset isPHAsset:YES];
                
            }
        }];
        innerBlock();
    }else{
        [_assetGroup setAssetsFilter:[HTAssetsHelper assetsFilterFromType:self.assetsType]];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [_assetGroup enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if (!result) {
                    innerBlock();
                    return;
                }
                [self createAndAddItemWithAsset:result isPHAsset:NO];
            }];
        });
    }
}

- (void)createAndAddItemWithAsset:(id)asset isPHAsset:(BOOL)isPHAsset
{
    HTAssetItem* item = [[_assetItemClass alloc]init];
    item.thumbnailSize = _itemThumbnailSize;
    if (isPHAsset) {
        HTAsset* htasset = [[HTAsset alloc]initWihtAsset:asset];
        item.asset = htasset;
        
        PHAssetMediaType mediaType = [(PHAsset*)asset mediaType];
        if (mediaType == PHAssetMediaTypeImage) {
            htasset.assetType = HTAssetsTypePhoto;
        }else if(mediaType == PHAssetMediaTypeVideo){
            htasset.assetType = HTAssetsTypeVideo;
        }else{
            htasset.assetType = HTAssetsTypeNone;
        }
    }else{
        HTAsset* htasset = [[HTAsset alloc]initWihtAsset:asset];
        item.asset = htasset;
        
        ALAsset* alAsset = (ALAsset*)asset;
        NSString* mediaType = [alAsset valueForProperty:ALAssetPropertyType];
        
        if ([mediaType isEqualToString:ALAssetTypePhoto]) {
            htasset.assetType = HTAssetsTypePhoto;
        }else if([mediaType isEqualToString:ALAssetTypePhoto]){
            htasset.assetType = HTAssetsTypeVideo;
        }else{
            htasset.assetType = HTAssetsTypeNone;
        }
        
    }
    
    if (self.itemReverseOrder) {
        [_assetItems insertObject:item atIndex:0];
    }else{
        [_assetItems addObject:item];
    }
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGSize itemSize;
    if (_itemSize.height > 0 && _itemSize.width > 0) {
        itemSize = _itemSize;
    }else{
        itemSize.width = (self.bounds.size.width - _inset.left - _inset.right - (_itemsCountEachRow - 1)*_interItemSpacing)/_itemsCountEachRow;
        itemSize.height = itemSize.width;
    }
    if (itemSize.width != _flowLayout.itemSize.width
        || itemSize.height != _flowLayout.itemSize.height
        || _flowLayout.minimumInteritemSpacing != _interItemSpacing
        || _flowLayout.minimumLineSpacing != _lineSpacing) {
        _flowLayout.itemSize = itemSize;
        _flowLayout.minimumInteritemSpacing = _interItemSpacing;
        _flowLayout.minimumLineSpacing = _lineSpacing;
        [_flowLayout invalidateLayout];
    }
}

#pragma mark - CollectionView
- (void)initGestureRecognizers
{
    
    __block UIGestureRecognizer* singleGR = nil;
    __block UIGestureRecognizer* doubleGR = nil;
    
    if (_interactTypes & HTAssetPickerCellInteactTypeSingleTapped) {
        //单击
        UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(collectionViewTapped:)];
        singleTapRecognizer.numberOfTapsRequired = 1;
        [self addGestureRecognizer:singleTapRecognizer];
        singleGR = singleTapRecognizer;
    }
    
    if (_interactTypes & HTAssetPickerCellInteactTypeDoubleTapped) {
        //双击
        UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(collectionViewDoubleTapped:)];
        doubleTapRecognizer.numberOfTapsRequired = 2;
        [self addGestureRecognizer:doubleTapRecognizer];
        doubleGR = doubleTapRecognizer;
    }
    
    if (_interactTypes & HTAssetPickerCellInteactTypeLongPressed) {
        //长按
        UILongPressGestureRecognizer *longPressedRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(collectionViewLongPressed:)];
        [self addGestureRecognizer:longPressedRecognizer];
    }
    
    //同时有单击和双击，添加依赖
    if (singleGR && doubleGR) {
        [singleGR requireGestureRecognizerToFail:doubleGR];
    }
}

- (void)collectionViewTapped:(UITapGestureRecognizer*)gestureRecognizer
{
    [self notifyInteractionToCell:[self itemOfHitTest:gestureRecognizer] withType:HTAssetPickerCellInteactTypeSingleTapped];
    
}

- (void)collectionViewDoubleTapped:(UITapGestureRecognizer*)gestureRecognizer
{
    [self notifyInteractionToCell:[self itemOfHitTest:gestureRecognizer] withType:HTAssetPickerCellInteactTypeDoubleTapped];
}

- (void)collectionViewLongPressed:(UITapGestureRecognizer*)gestureRecognizer
{
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        [self notifyInteractionToCell:[self itemOfHitTest:gestureRecognizer] withType:HTAssetPickerCellInteactTypeLongPressed];
    }
    
}

/**
 *  获得点击处的Cell
 *
 *  @param gestureRecognizer
 *
 *  @return HTAssetsPickerCell if hit，nil if not hit.
 */
- (HTAssetsPickerCell*)itemOfHitTest:(UITapGestureRecognizer*)gestureRecognizer
{
    CGPoint position = [gestureRecognizer locationInView:self];
    NSIndexPath* path = [self indexPathForItemAtPoint:position];
    UICollectionViewCell* cell = [self cellForItemAtIndexPath:path];
    if ([cell isKindOfClass:[HTAssetsPickerCell class]]) {
        return (HTAssetsPickerCell*)cell;
    }else{
        return nil;
    }
}

- (void)notifyInteractionToCell:(HTAssetsPickerCell*)cell withType:(HTAssetPickerCellInteactType)interactType
{
    if (cell) {
        if (![cell.assetItem isKindOfClass:[HTCameraAssetItem class]]) {
            [cell onInteracted:HTAssetPickerCellInteactTypeSingleTapped];
        }else{
            if ([_assetsPickerDelegate respondsToSelector:@selector(assetsPickerCameraClicked:)]) {
                //通知相机点击事件
                [_assetsPickerDelegate assetsPickerCameraClicked:self];
            }
        }
    }
}

#pragma mark - HTAssetPickerCellDelegate
- (BOOL)shouldSelectAssetsPickerCell:(HTAssetsPickerCell*)assetPickerCell
{
    if ([_selectedAssetItems count] >= _maxSelectedCount) {
        if ([_assetsPickerDelegate respondsToSelector:@selector(assetsPickerDidExceedMaxSelectedCount:)]) {
            [_assetsPickerDelegate assetsPickerDidExceedMaxSelectedCount:self];
        }
        return NO;
    }
    return YES;
}
- (BOOL)shouldDeselectAssetsPickerCell:(HTAssetsPickerCell*)assetPickerCell
{
    return YES;
}

//可以在此做自定义动画、以及点击图片预览效果等
- (void)didSelectAssetsPickerCell:(HTAssetsPickerCell*)assetPickerCell
{
    [_selectedAssetItems addObject:[assetPickerCell assetItem]];
    [assetPickerCell assetItem].index = [_selectedAssetItems count];
    if ([_assetsPickerDelegate respondsToSelector:@selector(assetsPicker:didSelectAsset:)]) {
        [_assetsPickerDelegate assetsPicker:self didSelectAsset:[assetPickerCell assetItem].asset];
    }
    [assetPickerCell selectedWithIndex:[_selectedAssetItems count]];
}
- (void)didDeselectAssetsPickerCell:(HTAssetsPickerCell*)assetPickerCell
{
    NSUInteger index = [_selectedAssetItems indexOfObject:[assetPickerCell assetItem]];
    [assetPickerCell assetItem].index = 0;
    [_selectedAssetItems removeObjectAtIndex:index];
    //更新其他item的选中索引
    for (NSUInteger i = index; i < [_selectedAssetItems count]; i++) {
        ((HTAssetItem*)(_selectedAssetItems[i])).index-- ;
    }
    if ([_assetsPickerDelegate respondsToSelector:@selector(assetsPicker:didDeselectAsset:)]) {
        [_assetsPickerDelegate assetsPicker:self didDeselectAsset:[assetPickerCell assetItem].asset];
    }
    
    [self reloadData];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_assetItems count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    HTAssetsPickerCell* cell = (HTAssetsPickerCell*)[collectionView dequeueReusableCellWithReuseIdentifier:HTAssetsPickerCellClass forIndexPath:indexPath];
    cell.delegate = self;
    [cell setAssetItem:_assetItems[[indexPath row]]];
    
    return cell;
}


#pragma mark -- setter
- (void)setItemsCountEachRow:(NSInteger)itemsCountEachRow
{
    NSParameterAssert(itemsCountEachRow > 0);
    _itemsCountEachRow = itemsCountEachRow;
}

- (void)setInset:(UIEdgeInsets)inset
{
    _inset = inset;
    self.contentInset = inset;
}


@end
