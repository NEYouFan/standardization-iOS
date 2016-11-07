//
//  SPSearchController.m
//  StandardizationPractice
//
//  Created by Baitianyu on 18/10/2016.
//  Copyright © 2016 Netease. All rights reserved.
//

#import "SPSearchController.h"
#import "HTControllerRouteInfo.h"
#import "HTControllerRouter.h"
#import "HTContainerViewController.h"
#import "HTNavigationController.h"
#import "UINavigationBar+HT.h"
#import "HTNavigationPanProtocol.h"
#import "UIViewController+HTRouter.h"
#import "SPThemeSizes.h"
#import "SPThemeColors.h"
#import "SPMacros.h"
#import "UIViewController+SPNavigationBar.h"
#import "SPSearchTableViewCell.h"
#import "SPSearchHeaderTableViewCell.h"
#import "UITableView+MCRegisterCellClass.h"
#import "SPSearchHistoryManager.h"
#import <HTCommonUtility/UIView+Frame.h>
#import "AppDelegate.h"


@interface SPSearchController ()<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate>

@property (nonatomic, copy) NSArray *data;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, assign) BOOL isSearching;

@end

@implementation SPSearchController


#pragma mark  Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self sp_applyDefaultNavigationBarStyle];
    _searchBar = [self sp_addNavigationSearchItem];
    [self loadSubviews];
    [self loadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    _tableView.frame = CGRectMake(0, 0, [SPThemeSizes screenWidth], [SPThemeSizes screenHeight] - kStatusBarHeight - kNavigationBarHeight);
}


#pragma mark  Load SubViews
- (void)loadSubviews{
    _tableView = [[UITableView alloc] init];
    _tableView.backgroundColor = [SPThemeColors backgroundColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    self.automaticallyAdjustsScrollViewInsets = false;
    [_tableView registerCellClasses:@[[SPSearchHeaderTableViewCell class],
                                      [SPSearchTableViewCell class]]];
    [self.view addSubview:_tableView];
}


#pragma mark  Load Data
- (void)loadData{
    @SPWeakSelf(self);
    [[SPSearchHistoryManager sharedManager] loadHistory:^(NSArray *result) {
        _data = result;
        [weakSelf.tableView reloadData];
    }];
}

- (void)searchData:(NSString *)searchWord{
    @SPWeakSelf(self);
    [[SPSearchHistoryManager sharedManager] selectFromHistory:searchWord completion:^(NSArray *result) {
        _data = result;
        [weakSelf.tableView reloadData];
    }];
}

#pragma mark  TableView Delegate && DataSource


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _data.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        SPSearchHeaderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SPSearchHeaderTableViewCell class])];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (self.isSearching) {
            cell.cellType = SPSearchHeaderCellType_Guess;
        }else{
            cell.cellType = SPSearchHeaderCellType_History;
        }
        return cell;
    }
    SPSearchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SPSearchTableViewCell class])];
    cell.data = _data[indexPath.row-1];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return kSearchHeaderCellHeight;
    }
    return kSearchCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        return;
    }
    HTControllerRouteParam *param = [[HTControllerRouteParam alloc] init];
    param.url = @"standardization://square";
    param.launchMode = HTControllerLaunchModePushNavigation;
    param.fromViewController = [SPAPPDELEGATE() rootNavigationController];
    param.delegate = self;
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithCapacity:2];
    [params setObject:@"搜索结果" forKey:@"title"];
    [params setObject:@(YES) forKey:@"hasNoTabbar"];
    param.params = params;
    [[HTControllerRouter sharedRouter] route:param];
}


#pragma mark  UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if ([searchText isEqualToString:@""] || searchText == nil) {
        _isSearching = NO;
        [self loadData];
    }else{
        _isSearching = YES;
        [self searchData:searchText];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [[SPSearchHistoryManager sharedManager] addHistory:searchBar.text];
    HTControllerRouteParam *param = [[HTControllerRouteParam alloc] init];
    param.url = @"standardization://square";
    param.launchMode = HTControllerLaunchModePushNavigation;
    param.fromViewController = [SPAPPDELEGATE() rootNavigationController];
    param.delegate = self;
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithCapacity:2];
    [params setObject:@"搜索结果" forKey:@"title"];
    [params setObject:@(YES) forKey:@"hasNoTabbar"];
    param.params = params;
    [[HTControllerRouter sharedRouter] route:param];
}


#pragma mark  Public Methods


#pragma mark  Private Methods


@end
