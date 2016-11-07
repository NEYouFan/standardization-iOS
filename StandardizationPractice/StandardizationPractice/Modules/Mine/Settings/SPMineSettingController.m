//
//  SPMineSettingController.m
//  StandardizationPractice
//
//  Created by Baitianyu on 21/10/2016.
//  Copyright © 2016 Netease. All rights reserved.
//

#import "SPMineSettingController.h"
#import "UIViewController+SPNavigationBar.h"
#import "SPMineSettingCellDescribeData.h"
#import "SPMineSettingSwitchCell.h"
#import "SPMineSettingCommonCell.h"
#import "SPMineSettingLogoutCell.h"
#import "UITableView+MCRegisterCellClass.h"
#import "SPUserDataManager.h"
#import "HTControllerRouteInfo.h"
#import "HTControllerRouter.h"
#import "HTContainerViewController.h"
#import "UINavigationBar+HT.h"
#import "HTNavigationPanProtocol.h"
#import "UIViewController+HTRouter.h"
#import "SPMineSettingFeedbackController.h"
#import "UIView+SPToast.h"

@interface SPMineSettingController () <UITableViewDelegate,
                                        UITableViewDataSource,
                                        UIAlertViewDelegate,
                                        UIActionSheetDelegate,
                                        HTRouteTargetProtocol,
                                        HTContainerViewControllerProtocol,
                                        HTNavigationBackPanGestureProtocol,
                                        SPMineSettingLogoutDelegate,
                                        SPMineSettingSwitchDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<NSMutableArray<SPMineSettingCellDescribeData *> *> *cellDescribeDatas;

@end

@implementation SPMineSettingController
@synthesize containerController;

#pragma mark - Router

+ (HTControllerRouterConfig*)configureRouter {
    HT_EXPORT();
    HTControllerRouterConfig *config = [[HTControllerRouterConfig alloc] initWithUrlPath:[self urlPath]];
    return config;
}

+ (NSString*)urlPath {
    return @"standardization://mine/setting";
}

- (void)receiveRoute:(HTControllerRouteParam*)param {
    self.delegate = param.delegate;
}


#pragma mark - Life cycle.

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadSubviews];
    [self loadCellDescribeDatas];
    [self sp_applyDefaultNavigationBarStyle];
    [self sp_addNavigationLeftBackItem];
    self.title = @"设置";
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
    [_tableView registerCellClasses:@[[SPMineSettingSwitchCell class],
                                      [SPMineSettingCommonCell class],
                                      [SPMineSettingLogoutCell class]]];
}


#pragma mark - Load datas.

- (void)loadCellDescribeDatas {
    @SPWeakSelf(self);
    // 修改用户名
    SPMineSettingCellDescribeData *userNameCellData = [[SPMineSettingCellDescribeData alloc] init];
    userNameCellData.title = @"修改用户名";
    if ([SPUserDataManager sharedInstance].alreadyLogin) {
        userNameCellData.rightTitle = [SPUserDataManager sharedInstance].userName;
    } else {
        userNameCellData.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    userNameCellData.cellClass = [SPMineSettingCommonCell class];
    userNameCellData.selectCellBlock = ^(MCTableBaseCell *cell, MCTableBaseDescribeData *describeData) {
        if ([SPUserDataManager sharedInstance].alreadyLogin) {
            UIAlertView *alertView;
            alertView = [[UIAlertView alloc] initWithTitle:@"请输入新昵称"
                                                   message:nil
                                                  delegate:self
                                         cancelButtonTitle:@"取消"
                                         otherButtonTitles:@"确定", nil];
            alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
            [alertView show];
        } else {
            [weakSelf.view sp_showToastWithMessage:@"请先进行登录"];
        }
   };
    
    // 反馈
    SPMineSettingCellDescribeData *feedbackCellData = [[SPMineSettingCellDescribeData alloc] init];
    feedbackCellData.cellClass = [SPMineSettingCommonCell class];
    feedbackCellData.title = @"意见反馈";
    feedbackCellData.selectCellBlock = ^(MCTableBaseCell *cell, MCTableBaseDescribeData *describeData) {
        SPMineSettingFeedbackController *feedback = [[SPMineSettingFeedbackController alloc] init];
        [weakSelf.navigationController pushViewController:feedback animated:YES];
    };
    
    // 保留原始图片
    SPMineSettingCellDescribeData *saveOriginCellData = [[SPMineSettingCellDescribeData alloc] init];
    saveOriginCellData.cellClass = [SPMineSettingSwitchCell class];
    saveOriginCellData.title = @"保存原始图片";
    saveOriginCellData.switchOn = [SPUserDataManager sharedInstance].saveOriginalPicture;
    saveOriginCellData.switchDelegate = self;
    
    // 清除缓存
    SPMineSettingCellDescribeData *clearCacheCellData = [[SPMineSettingCellDescribeData alloc] init];
    clearCacheCellData.cellClass = [SPMineSettingCommonCell class];
    clearCacheCellData.title = @"清除缓存";
    clearCacheCellData.rightTitle = [NSString stringWithFormat:@"%.2fM", [SPUserDataManager sharedInstance].cacheSize / 1024];
    clearCacheCellData.selectCellBlock = ^(MCTableBaseCell *cell, MCTableBaseDescribeData *describeData) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:@"取消"
                                                   destructiveButtonTitle:@"确认清除"
                                                        otherButtonTitles:nil, nil];
        actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
        actionSheet.tag = SPMineSettingActionTypeClearCache;
        [actionSheet showInView:self.view];
    };
    
    // 退出登录
    SPMineSettingCellDescribeData *logoutCellData = [[SPMineSettingCellDescribeData alloc] init];
    logoutCellData.cellClass = [SPMineSettingLogoutCell class];
    logoutCellData.logoutDelegate = self;
    
    NSMutableArray *firstSection = [[NSMutableArray alloc] initWithObjects:userNameCellData, feedbackCellData, saveOriginCellData, clearCacheCellData, nil];
    if ([SPUserDataManager sharedInstance].alreadyLogin) {
        [firstSection addObject:logoutCellData];
    }
    _cellDescribeDatas = [[NSMutableArray alloc] init];
    [_cellDescribeDatas addObject:firstSection];
}


#pragma mark - UITableViewDataSource.

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _cellDescribeDatas.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _cellDescribeDatas[section].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SPMineSettingCellDescribeData *data = _cellDescribeDatas[indexPath.section][indexPath.row];
    UITableViewCell *cell = [_tableView dequeueReusableCellWithClassType:data.cellClass];
    data.customCellBlock((MCTableBaseCell *)cell, data);
    return cell;
}


#pragma mark - UITableViewDelegate.

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    SPMineSettingCellDescribeData *data = _cellDescribeDatas[indexPath.section][indexPath.row];
    UITableViewCell *cell = [_tableView dequeueReusableCellWithClassType:data.cellClass];
    data.customCellBlock((MCTableBaseCell *)cell, data);
    return [data cellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SPMineSettingCellDescribeData *data = _cellDescribeDatas[indexPath.section][indexPath.row];
    if (data.selectCellBlock) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        data.selectCellBlock((MCTableBaseCell *)cell, data);
    }
}


#pragma mark - SPMineSettingLogoutDelegate.

- (void)logout:(SPMineSettingLogoutCell *)cell {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"取消"
                                               destructiveButtonTitle:@"确认退出"
                                                    otherButtonTitles:nil, nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    actionSheet.tag = SPMineSettingActionTypeLogout;
    [actionSheet showInView:self.view];
}


#pragma mark - SPMineSettingSwitchDelegate.

- (void)switchChanged:(BOOL)switchOn {
    [SPUserDataManager sharedInstance].saveOriginalPicture = switchOn;
}


#pragma mark - UIAlertViewDelegate.

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != 0) {
        if ([SPUserDataManager sharedInstance].alreadyLogin && [alertView textFieldAtIndex:0].text.length > 0) {
            [SPUserDataManager sharedInstance].userName = [alertView textFieldAtIndex:0].text;
            [self refreshInfo];
            [_delegate refreshUser:self];
        }
    }
}


#pragma mark - UIActionSheetDelegate.

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        switch (actionSheet.tag) {
            case SPMineSettingActionTypeLogout:
                //TODO: 退出登录的逻辑
                [SPUserDataManager sharedInstance].alreadyLogin = NO;
                [self refreshInfo];
                [_delegate refreshUser:self];
                break;
            case SPMineSettingActionTypeClearCache:
                [[SPUserDataManager sharedInstance] clearCache];
                [self refreshInfo];
                break;
            default:
                break;
        }
    }
}


#pragma mark - Actions.

- (void)refreshInfo {
    [self loadCellDescribeDatas];
    [_tableView reloadData];
}

@end
