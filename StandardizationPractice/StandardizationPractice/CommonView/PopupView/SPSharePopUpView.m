//
//  SPSharePopUpView.m
//  StandardizationPractice
//
//  Created by 陶泽宇 on 2016/10/27.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import "SPSharePopUpView.h"
#import "SPPopUPView.h"
#import "SPThemeSizes.h"
#import "SPShareCollectionViewCell.h"
const CGFloat kNumberOfCellsInRow = 4;

@interface SPSharePopUpView ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,SPShareCollectionViewCellDelegate>

@property (nonatomic, strong) SPPopUPView *popUpView;
@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation SPSharePopUpView

+ (instancetype)sharedInstance{
    static SPSharePopUpView *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SPSharePopUpView alloc] init];
    });
    return sharedInstance;
}

- (void)setContents:(NSArray *)contents{
    _contents = contents;
    [self configView];
}

-(void)configView{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init]; // 自定义的布局对象
    
    layout.itemSize = [self calculateItemSize];
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, [SPThemeSizes screenWidth] - 38, [self collectionViewHeight])
                                         collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.layer.cornerRadius = 4.0f;
    [_collectionView registerClass:[SPShareCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([SPShareCollectionViewCell class])];
    
    _popUpView = [[SPPopUPView alloc] initWithContentView:_collectionView];
}

- (void)show{
    [self.popUpView popup];
}

- (void)dismiss{
    [self.popUpView dismiss];
}

#pragma mark ---- UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _contents.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    SPShareCollectionViewCell *cell = [_collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([SPShareCollectionViewCell class]) forIndexPath:indexPath];
    cell.data = _contents[indexPath.row];
    cell.delegate = self;
    return cell;
}


#pragma mark ---- UICollectionViewDelegate

// 选中某item
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
}

#pragma mark ---- UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return [self calculateItemSize];
}
    

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 9.5, 0, 0);
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}

#pragma mark ------SPShareCollectionViewCellDelegate

- (void)onClickShareItem{
    [self dismiss];
}


# pragma mark private method
- (CGFloat)collectionViewHeight{
    return kShareCollectionCellHeight * ceilf(_contents.count/kNumberOfCellsInRow);
}

- (CGSize)calculateItemSize{
    CGFloat height = kShareCollectionCellHeight;
    CGFloat width =(([SPThemeSizes screenWidth] - 38) - 19)/kNumberOfCellsInRow;
    return CGSizeMake(width, height);
}


@end

@implementation SPShareContentData


@end
