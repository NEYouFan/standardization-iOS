//
//  SPTestRefreshingController.m
//  StandardizationPractice
//
//  Created by Baitianyu on 27/10/2016.
//  Copyright © 2016 Netease. All rights reserved.
//

#import "SPTestRefreshingController.h"
#import "SPLoadMoreView.h"
#import "SPRefreshView.h"
#import "UIView+SPLine.h"
#import "UIViewController+SPNavigationBar.h"

@interface SPTestRefreshingController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) SPRefreshView *refreshView;
@property (nonatomic, strong) SPLoadMoreView *loadmoreView;
@property (nonatomic, strong) NSMutableArray<NSNumber *> *data;

@end

@implementation SPTestRefreshingController

#pragma mark - Life cycle.

- (void)viewDidLoad {
    [super viewDidLoad];
    [self sp_applyDefaultNavigationBarStyle];
    [self sp_addNavigationLeftBackItem];
    [self loadSubviews];
    [self loadData];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    _tableView.frame = self.view.bounds;
    _refreshView.bounds = CGRectMake(0, 0, [SPThemeSizes screenWidth], kRefreshViewHeight);
    _loadmoreView.bounds = CGRectMake(0, 0, [SPThemeSizes screenWidth], kLoadMoreViewHeight);
}


#pragma mark - Load data.

- (void)loadData {
    _data = [[NSMutableArray alloc] init];
    for (int i = 0; i < 20; i++) {
        [_data addObject:@(i)];
    }
}

- (void)refreshData {
    @SPWeakSelf(self);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf loadData];
        [weakSelf.tableView reloadData];
        [weakSelf.refreshView endRefresh:YES];
        weakSelf.loadmoreView.refreshEnabled = YES;
        weakSelf.loadmoreView.hiddenRefresh = NO;
    });
}

- (void)loadmoreData {
    @SPWeakSelf(self);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
        for (int i = 0; i < 5; i++) {
            [weakSelf.data addObject:@(weakSelf.data.count)];
            NSIndexPath *newPath = [NSIndexPath indexPathForRow:(weakSelf.data.count - 1) inSection:0];
            [indexPaths addObject:newPath];
        }
        
        [weakSelf.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];

        [weakSelf.loadmoreView endRefresh:YES];
        
        if (_data.count > 40) {
            weakSelf.loadmoreView.refreshEnabled = NO;
            weakSelf.loadmoreView.hiddenRefresh = YES;
        }
    });
}


#pragma mark - Load views.

- (void)loadSubviews {
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = [SPThemeColors backgroundColor];
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
    [self.view addSubview:_tableView];
    
    @SPWeakSelf(self);
    _refreshView = [[SPRefreshView alloc] initWithScrollView:_tableView
                                                   direction:HTRefreshDirectionTop
                                            followScrollView:YES];
    [_refreshView addRefreshingHandler:^(HTRefreshView *view) {
        [weakSelf refreshData];
    }];
    
    _loadmoreView = [[SPLoadMoreView alloc] initWithScrollView:_tableView
                                                     direction:HTRefreshDirectionBottom
                                              followScrollView:YES];
    _loadmoreView.triggerLoadMoreMode = HTTriggerLoadMoreModeAutoTrigger;
    [_tableView ht_setOriginalContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    [_loadmoreView addRefreshingHandler:^(HTRefreshView *view) {
        [weakSelf loadmoreData];
    }];
}


#pragma mark - UITableViewDataSource.

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class])];
    cell.textLabel.text = [NSString stringWithFormat:@"%ld", (long)[_data[indexPath.row] integerValue]];
    [cell.contentView sp_addBottomLineWithLeftMargin:0 rightMargin:0];
    return cell;
}


#pragma mark - UITableViewDelegate.

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
