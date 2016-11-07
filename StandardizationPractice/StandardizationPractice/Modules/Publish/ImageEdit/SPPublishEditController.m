//
//  SPPublishEditController.m
//  StandardizationPractice
//
//  Created by Baitianyu on 27/10/2016.
//  Copyright © 2016 Netease. All rights reserved.
//

#import "SPPublishEditController.h"
#import "UIViewController+SPNavigationBar.h"
#import "HTControllerRouteInfo.h"
#import "HTControllerRouter.h"
#import "HTContainerViewController.h"
#import "UINavigationBar+HT.h"
#import "HTNavigationPanProtocol.h"
#import "UIViewController+HTRouter.h"
#import "SPPublishEditImageCell.h"
#import "SPPublishEditCommonCell.h"
#import "SPPublishEditDescribeData.h"
#import "SPPulishEditFinishCell.h"
#import "SPPulishEditAddDescribeCell.h"
#import "UITableView+MCRegisterCellClass.h"

@interface SPPublishEditController () <UITableViewDelegate,
                                       UITableViewDataSource,
                                       UIAlertViewDelegate,
                                       HTRouteTargetProtocol,
                                       HTContainerViewControllerProtocol,
                                       SPPublishEditFinishCellDelegate>

@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<NSArray<SPPublishEditDescribeData *> *> *cellDescribeDatas;
@property (nonatomic, copy) NSString *captureCity;
@property (nonatomic, copy) NSString *captureScenery;

@end

@implementation SPPublishEditController
@synthesize containerController;

#pragma mark - Router

+ (HTControllerRouterConfig*)configureRouter {
    HT_EXPORT();
    HTControllerRouterConfig *config = [[HTControllerRouterConfig alloc] initWithUrlPath:[self urlPath]];
    return config;
}

+ (NSString*)urlPath {
    return @"standardization://publish/edit";
}

- (void)receiveRoute:(HTControllerRouteParam*)param {
    self.publishImage = param.params;
    self.delegate = param.delegate;
}


#pragma mark - Life cycle.

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self sp_applyDefaultNavigationBarStyle];
    _closeButton = [self sp_addNavigationRightCloseItem];
    [_closeButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    self.title = @"编辑";
    
    [self loadSubviews];
    [self loadCellDescribeDatas];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    _tableView.frame = self.view.bounds;
}

#pragma mark - Load views.

- (void)loadSubviews {
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = [SPThemeColors backgroundColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    // register cell class, use UITableView+MCRegisterCellClass
    [_tableView registerCellClasses:@[[SPPulishEditAddDescribeCell class],
                                      [SPPublishEditImageCell class],
                                      [SPPublishEditCommonCell class],
                                      [SPPulishEditFinishCell class]]];
}


#pragma mark - Load datas.

- (void)loadCellDescribeDatas {
    @SPWeakSelf(self);
    SPPublishEditDescribeData *editImageCellData = [[SPPublishEditDescribeData alloc] init];
    editImageCellData.cellClass = [SPPublishEditImageCell class];
    editImageCellData.image = _publishImage;
    
    SPPublishEditDescribeData *cityCellData = [[SPPublishEditDescribeData alloc] init];
    cityCellData.cellClass = [SPPublishEditCommonCell class];
    cityCellData.title = @"拍摄城市:";
    cityCellData.content = _captureCity;
    cityCellData.selectCellBlock = ^(MCTableBaseCell *cell, MCTableBaseDescribeData *describeData) {
        UIAlertView *alertView;
        alertView = [[UIAlertView alloc] initWithTitle:@"请输入拍摄城市:"
                                               message:nil
                                              delegate:weakSelf
                                     cancelButtonTitle:@"取消"
                                     otherButtonTitles:@"确定", nil];
        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        alertView.tag = SPPublishEditAlertTypeCity;
        [alertView show];
    };
    
    SPPublishEditDescribeData *scenaryCellData = [[SPPublishEditDescribeData alloc] init];
    scenaryCellData.cellClass = [SPPublishEditCommonCell class];
    scenaryCellData.title = @"拍摄景点:";
    scenaryCellData.content = _captureScenery;
    scenaryCellData.selectCellBlock = ^(MCTableBaseCell *cell, MCTableBaseDescribeData *describeData) {
        UIAlertView *alertView;
        alertView = [[UIAlertView alloc] initWithTitle:@"请输入拍摄景点:"
                                               message:nil
                                              delegate:weakSelf
                                     cancelButtonTitle:@"取消"
                                     otherButtonTitles:@"确定", nil];
        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        alertView.tag = SPPublishEditAlertTypeScenery;
        [alertView show];
    };
    
    SPPublishEditDescribeData *addDescribeCellData = [[SPPublishEditDescribeData alloc] init];
    addDescribeCellData.cellClass = [SPPulishEditAddDescribeCell class];
    addDescribeCellData.title = @"添加描述:";
    
    SPPublishEditDescribeData *finishCellData = [[SPPublishEditDescribeData alloc] init];
    finishCellData.cellClass = [SPPulishEditFinishCell class];
    finishCellData.delegate = self;
    
    _cellDescribeDatas = @[@[editImageCellData,
                             cityCellData,
                             scenaryCellData,
                             addDescribeCellData,
                             finishCellData]];
}


#pragma mark - UITableViewDelegate.

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    SPPublishEditDescribeData *data = _cellDescribeDatas[indexPath.section][indexPath.row];
    UITableViewCell *cell = [_tableView dequeueReusableCellWithClassType:data.cellClass];
    data.customCellBlock((MCTableBaseCell *)cell, data);
    return [data cellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SPPublishEditDescribeData *data = _cellDescribeDatas[indexPath.section][indexPath.row];
    if (data.selectCellBlock) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        data.selectCellBlock((MCTableBaseCell *)cell, data);
    }
}


#pragma mark - UITableViewDataSource.

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _cellDescribeDatas.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _cellDescribeDatas[section].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SPPublishEditDescribeData *data = _cellDescribeDatas[indexPath.section][indexPath.row];
    UITableViewCell *cell = [_tableView dequeueReusableCellWithClassType:data.cellClass];
    data.customCellBlock((MCTableBaseCell *)cell, data);
    return cell;
}


#pragma mark - SPPublishEditFinishCellDelegate.

- (void)editFinishedAndBack:(SPPulishEditFinishCell *)cell {
    
}

- (void)editFinishedAndPublish:(SPPulishEditFinishCell *)cell {
    
}


#pragma mark - UIAlertViewDelegate.

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == SPPublishEditAlertTypeCity) {
        if (buttonIndex != 0) {
            _captureCity = [alertView textFieldAtIndex:0].text;
            [self refreshInfo];
        }
    } else {
        if (buttonIndex != 0) {
            _captureScenery = [alertView textFieldAtIndex:0].text;
            [self refreshInfo];
        }
    }
}


#pragma mark - Actions.

- (void)dismiss {
    if ([_delegate respondsToSelector:@selector(editDismissed:)]) {
        [_delegate editDismissed:self];
    }
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)refreshInfo {
    [self loadCellDescribeDatas];
    [_tableView reloadData];
}

@end
