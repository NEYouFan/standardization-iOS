//
//  SPAlbumChooserController.m
//  StandardizationPractice
//
//  Created by Baitianyu on 31/10/2016.
//  Copyright © 2016 Netease. All rights reserved.
//

#import "SPAlbumChooserController.h"
#import "UIViewController+SPNavigationBar.h"
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "HTAsset.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "SPAlbumChooserCell.h"
#import "SPAlbumChooserCellViewModel.h"
#import "HTControllerRouteInfo.h"
#import "HTControllerRouter.h"
#import "HTContainerViewController.h"
#import "UINavigationBar+HT.h"
#import "HTNavigationPanProtocol.h"
#import "UIViewController+HTRouter.h"

@interface SPAlbumChooserController () <UITableViewDelegate,
                                        UITableViewDataSource,
                                        HTRouteTargetProtocol,
                                        HTContainerViewControllerProtocol>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic,strong) NSArray<ALAssetsGroup *> *assetsGroups;
@property (nonatomic, strong) ALAssetsLibrary* library;
@property (nonatomic, strong) PHAssetCollection *assetCollection;

@end

@implementation SPAlbumChooserController
@synthesize containerController;

#pragma mark - Router

+ (HTControllerRouterConfig*)configureRouter {
    HT_EXPORT();
    HTControllerRouterConfig *config = [[HTControllerRouterConfig alloc] initWithUrlPath:[self urlPath]];
    return config;
}

+ (NSString*)urlPath {
    return @"standardization://publish/photochooser";
}

- (void)receiveRoute:(HTControllerRouteParam*)param {
    self.pushImagePicker = [param.params boolValue];
    self.delegate = param.delegate;
}


#pragma mark - Life cycle.

- (void)viewDidLoad {
    [super viewDidLoad];
    [self sp_applyDefaultNavigationBarStyle];
    _closeButton = [self sp_addNavigationRightCloseItem];
    [_closeButton addTarget:self action:@selector(closeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.title = @"图库";
    [self loadAssetsGroups];
    [self loadSubviews];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    _tableView.frame = self.view.bounds;
}


#pragma mark - Load views.

- (void)loadSubviews {
    _tableView = [[UITableView alloc] init];
    _tableView.backgroundColor = [SPThemeColors backgroundColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView registerClass:[SPAlbumChooserCell class] forCellReuseIdentifier:NSStringFromClass([SPAlbumChooserCell class])];
    [self.view addSubview:_tableView];
}


#pragma mark - Load data.

- (void)loadAssetsGroups {
    @SPWeakSelf(self);
    _library = [[ALAssetsLibrary alloc] init];
    __block NSMutableArray* assetsGroups = [[NSMutableArray alloc]init];
    [_library enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (group) {
            [group setAssetsFilter:[HTAssetsHelper assetsFilterFromType:HTAssetsTypePhoto]];
            [assetsGroups addObject:group];
        } else {
            *stop = YES;
        }
        if (stop) {
            if (weakSelf.pushImagePicker && assetsGroups.count > 0) {
                weakSelf.pushImagePicker = NO;
                [weakSelf pushImagePickerWithGroup:assetsGroups[0] animated:NO];
            }
            weakSelf.assetsGroups = assetsGroups;
            [weakSelf.tableView reloadData];
        }
    } failureBlock:^(NSError *error) {
        NSLog(@"%@",error);
    }];
}


#pragma mark - UITableViewDelegate.

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView fd_heightForCellWithIdentifier:NSStringFromClass([SPAlbumChooserCell class])
                                    cacheByIndexPath:indexPath
                                       configuration:^(SPAlbumChooserCell* cell) {
                                           cell.fd_enforceFrameLayout = YES;
                                       }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self pushImagePickerWithGroup:_assetsGroups[indexPath.row] animated:YES];
}


#pragma mark - UITableViewDataSource.

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _assetsGroups.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass( [SPAlbumChooserCell class])];

    ALAssetsGroup* group = _assetsGroups[indexPath.row];
    SPAlbumChooserCellViewModel *viewModel = [[SPAlbumChooserCellViewModel alloc] initWithAssetsGroup:group];
    ((SPAlbumChooserCell *)cell).viewModel = viewModel;
    return cell;
}


#pragma mark - Actions.

- (void)pushImagePickerWithGroup:(ALAssetsGroup *)group animated:(BOOL)animated {
    SPImagePickerController *imagePickerController = [[SPImagePickerController alloc] init];
    imagePickerController.assetGroup = group;
    imagePickerController.naviTitle = [group valueForProperty:ALAssetsGroupPropertyName];
    imagePickerController.delegate = _delegate;
    [self.navigationController pushViewController:imagePickerController animated:animated];
}

- (void)closeButtonClicked:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    [_delegate imagePickerDismiss:self];
}

@end
