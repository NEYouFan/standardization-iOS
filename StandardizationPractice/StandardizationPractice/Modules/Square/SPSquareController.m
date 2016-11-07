//
//  SPSquareController.m
//  StandardizationPractice
//
//  Created by Baitianyu on 18/10/2016.
//  Copyright © 2016 Netease. All rights reserved.
//

#import "SPSquareController.h"
#import "HTControllerRouteInfo.h"
#import "HTControllerRouter.h"
#import "HTContainerViewController.h"
#import "HTNavigationController.h"
#import "UINavigationBar+HT.h"
#import "HTNavigationPanProtocol.h"
#import "UIViewController+HTRouter.h"
#import "SPThemeSizes.h"
#import "SPThemeColors.h"
#import "SPSquareColors.h"
#import "SPMacros.h"
#import "SPBaseRequest.h"
#import "SPRequests.h"
#import "SPModels.h"
#import "SPSquareTableViewCell.h"
#import "UIView+SPLoading.h"
#import "UIViewController+SPNavigationBar.h"
#import "SPRefreshView.h"
#import "SPLoadMoreView.h"
#import "AppDelegate.h"
#import <HTCommonUtility/UIView+Frame.h>

static const NSInteger kInitialPageOffset = 0;
static const NSInteger kRequestLimit = 20;


@interface SPSquareController ()<UITableViewDelegate,UITableViewDataSource,HTRouteTargetProtocol,HTContainerViewControllerProtocol>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSMutableArray *data;  //页面总data
@property (nonatomic, copy) NSArray *photolist; // 一次请求之后返回的data
@property (nonatomic, strong) SPRefreshView *refreshView;
@property (nonatomic, strong) SPLoadMoreView *loadMoreView;
@property (nonatomic, assign) NSInteger offset;
@property (nonatomic, assign) BOOL hasMore;
@property (nonatomic, assign) BOOL hasNoTabbar;
@property (nonatomic, copy) NSString *navigationTitle;

@end

@implementation SPSquareController
@synthesize containerController;


#pragma mark  Router
+ (HTControllerRouterConfig *)configureRouter {
    HT_EXPORT();
    HTControllerRouterConfig *config = [[HTControllerRouterConfig alloc] initWithUrlPath:[self urlPath]];
    return config;
}

+ (NSString *)urlPath {
    return @"standardization://square";
}

- (void)receiveRoute:(HTControllerRouteParam *)param {
    if ([param.params isKindOfClass:[NSDictionary class]]) {
        self.navigationTitle = [param.params valueForKey:@"title"];
        self.hasNoTabbar = [[param.params valueForKey:@"hasNoTabbar"] boolValue];
    }
}

#pragma mark  Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    _data = [NSMutableArray array];
    _photolist = [NSArray array];
    _offset = kInitialPageOffset;
    [self sp_applyDefaultNavigationBarStyle];
    if (!self.hasNoTabbar) {
        [self sp_addNavigationMidViewWithTitle:@"热门" image:[UIImage imageNamed:@"square_hot_icon"]];
    }else{
        [self sp_addNavigationLeftBackItem];
        self.title = self.navigationTitle;
    }
    [self loadSubviews];
    [self loadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    _tableView.frame = CGRectMake(0, 0, [SPThemeSizes screenWidth], [SPThemeSizes screenHeight] - kStatusBarHeight - kNavigationBarHeight - kTabBarHeight);
    if (self.hasNoTabbar) {
        _tableView.height += kTabBarHeight;
    }
    _refreshView.bounds = CGRectMake(0, 0, [SPThemeSizes screenWidth], kRefreshViewHeight);
    _loadMoreView.bounds = CGRectMake(0, 0, [SPThemeSizes screenWidth], kLoadMoreViewHeight);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark  Load SubViews

- (void)loadSubviews{
    _tableView = [[UITableView alloc] init];
    _tableView.backgroundColor = [SPSquareColors squareBackgroundColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    self.automaticallyAdjustsScrollViewInsets = false;
    [_tableView ht_setOriginalContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    [_tableView registerClass:[SPSquareTableViewCell class] forCellReuseIdentifier:NSStringFromClass([SPSquareTableViewCell class])];
    [self.view addSubview:_tableView];
    
    
    @SPWeakSelf(self)
    _refreshView = [[SPRefreshView alloc] initWithScrollView:_tableView
                                                   direction:HTRefreshDirectionTop
                                            followScrollView:YES];
    [_refreshView addRefreshingHandler:^(HTRefreshView *view) {
        [weakSelf refreshData];
    }];
    
    _loadMoreView = [[SPLoadMoreView alloc] initWithScrollView:_tableView
                                                     direction:HTRefreshDirectionBottom
                                              followScrollView:YES];
    _loadMoreView.triggerLoadMoreMode = HTTriggerLoadMoreModeAutoTrigger;
    [_tableView ht_setOriginalContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    [_loadMoreView addRefreshingHandler:^(HTRefreshView *view) {
        [weakSelf loadMoreData];
    }];
}

#pragma mark  Load Data

- (void)loadDataWithSuccess:(void (^)(void))success
                    failure:(void (^)(NSError *error))failure {
    @SPWeakSelf(self);
    SPGetPhotolistRequest * request = [[SPGetPhotolistRequest alloc] init];
    request.limit = kRequestLimit;
    request.offset = _offset;
    [self cancelRequestWhenControllerDealloc:request];
    [request startWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        weakSelf.photolist = ((SPPhotolist *)mappingResult.firstObject).photolist;
        weakSelf.hasMore = ((SPPhotolist *)mappingResult.firstObject).hasMore;
        if (success) {
            success();
        }
        if (weakSelf.hasMore) {
            weakSelf.loadMoreView.refreshEnabled = YES;
            weakSelf.loadMoreView.hiddenRefresh = NO;
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)loadData {
    [self.view sp_showLoading];
    @SPWeakSelf(self);
    [self loadDataWithSuccess:^{
        weakSelf.offset += [weakSelf.photolist count];
        [weakSelf.data addObjectsFromArray:weakSelf.photolist];
        if ([weakSelf.data count] == 0) {
            [weakSelf.view sp_hideLoadingEmpty];
        }else{
            [weakSelf.view sp_hideLoading];
            [weakSelf.tableView reloadData];
        }
    } failure:^(NSError *error) {
        [weakSelf.view sp_showLoadingError:^{
            [weakSelf loadData];
        }];
    }];
}

- (void)loadMoreData {
    [self clearRequests];
    
    @SPWeakSelf(self);
    [self loadDataWithSuccess:^{
        weakSelf.offset += [weakSelf.photolist count];
        [weakSelf.data addObjectsFromArray:weakSelf.photolist];
        [weakSelf.loadMoreView endRefresh:YES];
        [weakSelf.tableView reloadData];
        if (_data.count > 20) {
            weakSelf.loadMoreView.refreshEnabled = NO;
            weakSelf.loadMoreView.hiddenRefresh = YES;
        }
    } failure:^(NSError *error) {
        if (_data.count > 20) {
            weakSelf.loadMoreView.refreshEnabled = NO;
            weakSelf.loadMoreView.hiddenRefresh = YES;
        }
        [weakSelf.loadMoreView endRefresh:YES];
    }];
}

- (void)refreshData{
    @SPWeakSelf(self);
    _offset = kInitialPageOffset;
    [self loadDataWithSuccess:^{
        [weakSelf.data removeAllObjects];
        [weakSelf.data addObjectsFromArray:weakSelf.photolist];
        [weakSelf.tableView reloadData];
        [weakSelf.refreshView endRefresh:YES];
        weakSelf.loadMoreView.refreshEnabled = YES;
        weakSelf.loadMoreView.hiddenRefresh = NO;
    } failure:^(NSError *error) {
        [weakSelf.view sp_showLoadingError:^{
            [weakSelf.refreshView endRefresh:YES];
            [weakSelf loadData];
        }];
    }];

}

#pragma mark  TableView Delegate && DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SPSquareTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SPSquareTableViewCell class])];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.data = _data[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kSquareCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    HTControllerRouteParam *param = [[HTControllerRouteParam alloc] init];
    param.url = @"standardization://photoDetail";
    param.launchMode = HTControllerLaunchModePushNavigation;
    param.fromViewController = [SPAPPDELEGATE() rootNavigationController];
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithCapacity:1];
    [params setObject:_data[indexPath.row] forKey:@"photo"];
    param.params = params;
    [[HTControllerRouter sharedRouter] route:param];
}



#pragma mark  Public Methods


#pragma mark  Private Methods


@end
