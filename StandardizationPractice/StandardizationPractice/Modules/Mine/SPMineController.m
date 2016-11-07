//
//  SPMineController.m
//  StandardizationPractice
//
//  Created by Baitianyu on 18/10/2016.
//  Copyright © 2016 Netease. All rights reserved.
//

#import "SPMineController.h"
#import "UIViewController+SPNavigationBar.h"
#import "SPMineCellDescribeData.h"
#import "SPMineOperationCell.h"
#import "SPMineHeaderInfoCell.h"
#import "UITableView+MCRegisterCellClass.h"
#import "HTControllerRouteInfo.h"
#import "HTControllerRouter.h"
#import "HTContainerViewController.h"
#import "UINavigationBar+HT.h"
#import "HTNavigationPanProtocol.h"
#import "UIViewController+HTRouter.h"
#import "HTNavigationController.h"
#import "AppDelegate.h"
#import "SPUserDataManager.h"
#import "SPMineSettingController.h"
#import "SPLoginController.h"

@interface SPMineController () <UITableViewDelegate, UITableViewDataSource, SPMineHeaderInfoCellDelegate, SPMineSettingControllerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<NSArray<SPMineCellDescribeData *> *> *cellDescribeDatas;
@property (nonatomic, strong) UIButton *settingButton;

@end

@implementation SPMineController

#pragma mark - Life cycle.

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadSubviews];
    [self loadCellDescribeDatas];
    [self sp_applyTransparentNavigationBarStyle];
    _settingButton = [self sp_addNavigationRightSettingItem];
    [_settingButton addTarget:self action:@selector(setting:) forControlEvents:UIControlEventTouchUpInside];
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
    [_tableView registerCellClasses:@[[SPMineHeaderInfoCell class],
                                      [SPMineOperationCell class]]];
}


#pragma mark - Load datas.

- (void)loadCellDescribeDatas {
    @SPWeakSelf(self);
    SPMineCellDescribeData *headerInfoCellData = [[SPMineCellDescribeData alloc] init];
    headerInfoCellData.cellClass = [SPMineHeaderInfoCell class];
    headerInfoCellData.delegate = self;
    
    SPMineCellDescribeData *myPublishCellData = [[SPMineCellDescribeData alloc] init];
    myPublishCellData.cellClass = [SPMineOperationCell class];
    myPublishCellData.iconName = @"my_publish";
    myPublishCellData.title = @"我的发布:";
    myPublishCellData.selectCellBlock = ^(MCTableBaseCell *cell, MCTableBaseDescribeData *describeData) {
        [weakSelf pushNextControllerWithUrl:@"standardization://mine/publish"];
    };

    SPMineCellDescribeData *myCollectionCellData = [[SPMineCellDescribeData alloc] init];
    myCollectionCellData.cellClass = [SPMineOperationCell class];
    myCollectionCellData.iconName = @"my_collection";
    myCollectionCellData.title = @"我的收藏:";
    myCollectionCellData.selectCellBlock = ^(MCTableBaseCell *cell, MCTableBaseDescribeData *describeData) {
        [weakSelf pushNextControllerWithUrl:@"standardization://mine/collection"];
    };

    SPMineCellDescribeData *myPreferenceCellData = [[SPMineCellDescribeData alloc] init];
    myPreferenceCellData.cellClass = [SPMineOperationCell class];
    myPreferenceCellData.iconName = @"my_preference";
    myPreferenceCellData.title = @"我的偏好:";
    myPreferenceCellData.selectCellBlock = ^(MCTableBaseCell *cell, MCTableBaseDescribeData *describeData) {
        [weakSelf pushNextControllerWithUrl:@"standardization://mine/preference"];
    };

    SPMineCellDescribeData *inviteFriendsCellData = [[SPMineCellDescribeData alloc] init];
    inviteFriendsCellData.cellClass = [SPMineOperationCell class];
    inviteFriendsCellData.iconName = @"invite_friends";
    inviteFriendsCellData.title = @"邀请好友:";
    inviteFriendsCellData.selectCellBlock = ^(MCTableBaseCell *cell, MCTableBaseDescribeData *describeData) {
        [weakSelf pushNextControllerWithUrl:@"standardization://mine/invitefriends"];
    };

    _cellDescribeDatas = @[@[headerInfoCellData,
                             myPublishCellData,
                             myCollectionCellData,
                             myPreferenceCellData,
                             inviteFriendsCellData]];
}


#pragma mark - UITableViewDataSource.

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _cellDescribeDatas.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _cellDescribeDatas[section].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SPMineCellDescribeData *data = _cellDescribeDatas[indexPath.section][indexPath.row];
    UITableViewCell *cell = [_tableView dequeueReusableCellWithClassType:data.cellClass];
    data.customCellBlock((MCTableBaseCell *)cell, data);
    return cell;
}


#pragma mark - UITableViewDelegate.

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    SPMineCellDescribeData *data = _cellDescribeDatas[indexPath.section][indexPath.row];
    UITableViewCell *cell = [_tableView dequeueReusableCellWithClassType:data.cellClass];
    data.customCellBlock((MCTableBaseCell *)cell, data);
    return [data cellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SPMineCellDescribeData *data = _cellDescribeDatas[indexPath.section][indexPath.row];
    if (data.selectCellBlock) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        data.selectCellBlock((MCTableBaseCell *)cell, data);
    }
}


#pragma mark - SPMineHeaderInfoCellDelegate.

- (void)loginOrRegister:(SPMineHeaderInfoCell *)cell {
    [SPLoginController showLoginControllerWithSuccessBlock:^{
        [SPUserDataManager sharedInstance].alreadyLogin = YES;
        [self reloadInfo];
    } cancelBlock:^{
        
    }];
}


#pragma mark - SPMineSettingControllerDelegate.

- (void)refreshUser:(SPMineSettingController *)settingController {
    [self reloadInfo];
}


#pragma mark - actions.

- (void)reloadInfo {
    [self loadCellDescribeDatas];
    [_tableView reloadData];
}

- (void)pushNextControllerWithUrl:(NSString *)controllerUrl {
    HTControllerRouteParam *param = [[HTControllerRouteParam alloc] init];
    param.url = controllerUrl;
    param.launchMode = HTControllerLaunchModePushNavigation;
    param.fromViewController = [SPAPPDELEGATE() rootNavigationController];
    param.delegate = self;
    
    [[HTControllerRouter sharedRouter] route:param];
}

- (void)setting:(id)sender {
    [self pushNextControllerWithUrl:@"standardization://mine/setting"];
}

@end
