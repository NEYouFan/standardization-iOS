//
//  SPImagePickerController.m
//  StandardizationPractice
//
//  Created by Baitianyu on 31/10/2016.
//  Copyright © 2016 Netease. All rights reserved.
//

#import "SPImagePickerController.h"
#import "HTAssetsPickerView.h"
#import "HTAssetsPickerCell.h"
#import "UIViewController+SPNavigationBar.h"
#import "HTControllerRouteInfo.h"
#import "HTControllerRouter.h"
#import "HTContainerViewController.h"
#import "UINavigationBar+HT.h"
#import "HTNavigationPanProtocol.h"
#import "UIViewController+HTRouter.h"
#import "HTNavigationController.h"
#import "AppDelegate.h"
#import "SPImagePickerCell.h"

@interface SPImagePickerController () <HTAssetsPickerDelegate>

@property (nonatomic, strong) UIButton *closeButton;

@end

@implementation SPImagePickerController

#pragma mark - Life cycle.

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubviews];
    
    [self sp_applyDefaultNavigationBarStyle];
    [self sp_addNavigationLeftBackItem];
    _closeButton = [self sp_addNavigationRightCloseItem];
    [_closeButton addTarget:self action:@selector(closeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.title = _naviTitle;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    _assetsPicker.frame = self.view.bounds;
}


#pragma mark - Load views.

- (void)loadSubviews {
    _assetsPicker = [[HTAssetsPickerView alloc]initWithCellClass:[SPImagePickerCell class]];
    _assetsPicker.assetsPickerDelegate = self;
    _assetsPicker.assetsType = HTAssetsTypePhoto;
    _assetsPicker.assetGroup = _assetGroup;
    [self.view addSubview:_assetsPicker];
}

#pragma mark - HTAssetsPickerDelegate. 
// 两个方法均需改为 optional 类型，此处为了防止警告，先加上该方法
- (void)assetsPicker:(HTAssetsPickerView *)assetsPicker didFinishPickingWithAssets:(NSArray<HTAsset *> *)assets {
    
}

- (void)assetsPickerDidCancelPicking:(HTAssetsPickerView *)assetsPicker {
    
}

- (void)assetsPicker:(HTAssetsPickerView *)assetsPicker didSelectAsset:(HTAsset *)asset {
    HTControllerRouteParam *param = [[HTControllerRouteParam alloc] init];
    param.url = @"standardization://publish/edit";
    param.launchMode = HTControllerLaunchModePresentNavigation;
    param.params = [asset originImage];
    param.delegate = self;
    
    [[HTControllerRouter sharedRouter] route:param];
}


#pragma mark - Actions.

- (void)closeButtonClicked:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    [_delegate imagePickerDismiss:self];
}

@end
