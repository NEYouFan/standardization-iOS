//
//  SPDetailPhotoViewController.m
//  StandardizationPractice
//
//  Created by 陶泽宇 on 2016/10/21.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import "SPDetailPhotoViewController.h"
#import "HTControllerRouteInfo.h"
#import "HTControllerRouter.h"
#import "HTContainerViewController.h"
#import "UINavigationBar+HT.h"
#import "HTNavigationPanProtocol.h"
#import "UIViewController+HTRouter.h"
#import "SPThemeSizes.h"
#import "SPSquareSizes.h"
#import "SPSquareColors.h"
#import "SPThemeColors.h"
#import "SPMacros.h"
#import "SPModels.h"
#import "UIView+SPLoading.h"
#import "UIView+SPLine.h"
#import <HTCommonUtility/UIView+Frame.h>
#import "UIViewController+SPNavigationBar.h"
#import <HTImageView/HTImageView.h>
#import "SPDetailButton.h"
#import "UIButton+SPEnlargeButtonTouchArea.h"
#import "SPSharePopUpView.h"
#import <MBProgressHUD/MBProgressHUD.h>

const CGFloat kHeaderViewHeight = 63;
const CGFloat kBottomViewHeight = 50;
const CGFloat kPhotoViewHeight = 313;
const CGFloat kLocationLabelHeight = 42;
const CGFloat kReasonViewHeight = 136;

@interface SPDetailPhotoViewController ()  <HTRouteTargetProtocol, HTContainerViewControllerProtocol,HTNavigationBackPanGestureProtocol>

@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) SPPhoto *photoData;
@property (nonatomic, strong) UIImageView *userIcon;
@property (nonatomic, strong) UILabel *userNameLabel;
@property (nonatomic, strong) UIScrollView * scrollView;
@property (nonatomic, strong) HTImageView *photoView;
@property (nonatomic, strong) UILabel *locationLabel;
@property (nonatomic, strong) UIView *reasonView;
@property (nonatomic, strong) UITextView *reasonTextView;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) SPDetailButton *favButton;
@property (nonatomic, strong) UIButton *moreButton;

@end

@implementation SPDetailPhotoViewController
@synthesize containerController;

#pragma mark  Router
+ (HTControllerRouterConfig *)configureRouter {
    HT_EXPORT();
    HTControllerRouterConfig *config = [[HTControllerRouterConfig alloc] initWithUrlPath:[self urlPath]];
    return config;
}

+ (NSString *)urlPath {
    return @"standardization://photoDetail";
}

- (void)receiveRoute:(HTControllerRouteParam *)param {
    if ([param.params isKindOfClass:[NSDictionary class]]) {
        self.photoData = [param.params valueForKey:@"photo"];
    }
}



#pragma mark  Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self sp_applyDefaultNavigationBarStyle];
    [self sp_addNavigationLeftBackItem];
    self.title = @"详情";
    
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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark  Load SubViews
- (void)loadSubviews{
    self.view.backgroundColor = [UIColor whiteColor];
    [self loadScrollView];
    [self loadBottomView];
}

- (void)loadScrollView{
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.frame = CGRectMake(0, 0, [SPThemeSizes screenWidth], ([SPThemeSizes screenHeight] - kStatusBarHeight - kNavigationBarHeight - kBottomViewHeight));
    _scrollView.contentSize = CGSizeMake([SPThemeSizes screenWidth], kHeaderViewHeight + kPhotoViewHeight + kLocationLabelHeight + kReasonViewHeight);
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.scrollEnabled = YES;
    [self loadHeaderView];
    [self loadPhotoView];
    [self loadLocationView];
    [self loadReasonView];
    [self.view addSubview:_scrollView];
}

- (void)loadHeaderView{
    _headerView = [[UIView alloc] init];
    _headerView.frame =  CGRectMake(0, 0, [SPThemeSizes screenWidth], kHeaderViewHeight);
    [_scrollView addSubview:_headerView];

    _userIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"detail_user_avatar"]];
    _userIcon.frame = CGRectMake(14, 15.5, 32, 32);
    [_headerView addSubview:_userIcon];
    
    _userNameLabel = [[UILabel alloc] init];
    _userNameLabel.x = _userIcon.x + _userIcon.width + 9;
    _userNameLabel.y =  0;
    _userNameLabel.height = 63;
    _userNameLabel.width = [SPThemeSizes screenWidth] - _userNameLabel.x - _userNameLabel.width - 14;
    _userNameLabel.font = [SPSquareSizes detailUserNameLabelFont];
    _userNameLabel.textColor = [SPSquareColors userNameColor];
    _userNameLabel.textAlignment = NSTextAlignmentLeft;
    
    [_headerView addSubview:_userNameLabel];
}

- (void)loadPhotoView{
    _photoView = [[HTImageView alloc] init];
    _photoView.frame = CGRectMake(0, _headerView.bottom, [SPThemeSizes screenWidth], kPhotoViewHeight);
    [_photoView setImageWithUrl:[NSURL URLWithString:_photoData.imageUrl]];
    [_scrollView addSubview:_photoView];
}

- (void)loadLocationView{
    _locationLabel = [[UILabel alloc] init];
    _locationLabel.frame = CGRectMake(14, _photoView.bottom, [SPThemeSizes screenWidth] - 14*2, kLocationLabelHeight);
    _locationLabel.textColor = [SPThemeColors lightTextColor];
    _locationLabel.font = [SPSquareSizes detailLocationLabelFont];
    _locationLabel.textAlignment = NSTextAlignmentRight;
    [_scrollView addSubview:_locationLabel];
    
}

- (void)loadReasonView{
    _reasonView = [[UIView alloc] init];
    _reasonView.frame = CGRectMake(0, _locationLabel.bottom, [SPThemeSizes screenWidth], kReasonViewHeight);
    [_reasonView sp_addTopLineWithLeftMargin:0 rightMargin:0];
    
    UIImageView *middleLabel = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"detail_reason"]];
    middleLabel.width = 75;
    middleLabel.height = 18;
    middleLabel.middleY = 25;
    middleLabel.middleX = [SPThemeSizes screenWidth]/2;
    
    UIImageView *leftLine = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"detail_left_line"]];
    leftLine.x = 20.5;
    leftLine.middleY = 25;
    leftLine.width = ([SPThemeSizes screenWidth] - 41 - 22 - middleLabel.width)/2;
    leftLine.height = 6;
    
    UIImageView *rightLine = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"detail_right_line"]];
    rightLine.width = leftLine.width;
    rightLine.x = [SPThemeSizes screenWidth] - rightLine.width - 20.5;
    rightLine.height = leftLine.height;
    rightLine.middleY = leftLine.middleY;
    
    [_reasonView addSubview:middleLabel];
    [_reasonView addSubview:leftLine];
    [_reasonView addSubview:rightLine];
    
    _reasonTextView = [[UITextView alloc] init];
    _reasonTextView.editable = NO;
    _reasonTextView.frame = CGRectMake(31, 50, [SPThemeSizes screenWidth] - 62, kReasonViewHeight-50);
    _reasonTextView.font = [SPSquareSizes detailReasonLabelFont];
    _reasonTextView.textColor = [SPThemeColors lightTextColor];
    [_reasonView addSubview:_reasonTextView];
    
    [_scrollView addSubview:_reasonView];
    
}

- (void)loadBottomView{
    _bottomView = [[UIView alloc] init];
    _bottomView.frame = CGRectMake(0, [SPThemeSizes screenHeight] - kBottomViewHeight -64, [SPThemeSizes screenWidth], kBottomViewHeight);
    [_bottomView sp_addTopLineWithLeftMargin:0 rightMargin:0];

    _favButton = [SPDetailButton buttonWithType:UIButtonTypeCustom title:@"收藏"];
    _favButton.x = 22;
    _favButton.width = 54;
    _favButton.y = 0;
    _favButton.height = _bottomView.height;
    [_favButton addTarget:self action:@selector(clickFavButton:) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:_favButton];
    
    SPDetailButton *downloadButton = [SPDetailButton buttonWithType:UIButtonTypeCustom title:@"下载"];
    downloadButton.x = _favButton.x + _favButton.width + 45;
    downloadButton.y = 0;
    downloadButton.width = 54;
    downloadButton.height = _bottomView.height;
    downloadButton.icon.image = [UIImage imageNamed:@"detail_download"];
    [downloadButton addTarget:self action:@selector(clickDownloadButton:) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:downloadButton];
    
    _moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_moreButton setImage:[UIImage imageNamed:@"detail_more_unclicked"] forState:UIControlStateNormal];
    [_moreButton setImage:[UIImage imageNamed:@"detail_more_click"] forState:UIControlStateHighlighted];
    [_moreButton addTarget:self action:@selector(clickMoreButton:) forControlEvents:UIControlEventTouchUpInside];
    _moreButton.width = 28;
    _moreButton.height = 8;
    _moreButton.x = [SPThemeSizes screenWidth] - _moreButton.width - 22;
    _moreButton.y = (kBottomViewHeight - _moreButton.height)/2;
    [_moreButton enlargeTouchAreaWithTop:20 right:10 bottom:20 left:10];
    [_bottomView addSubview:_moreButton];
    
    [self.view addSubview:_bottomView];
    [self.view bringSubviewToFront:_bottomView];
}

#pragma mark  Load Data
- (void)loadData{
    _userNameLabel.text = _photoData.posterName;
    _locationLabel.text = [NSString stringWithFormat:@"%@    %@", _photoData.province, _photoData.location];
    _reasonTextView.text = [NSString stringWithFormat:@"     %@", _photoData.reason];
    NSString *favImageStr = _photoData.favorite ? @"detail_fav" : @"detail_unfav";
    _favButton.icon.image = [UIImage imageNamed:favImageStr];

    [self.view setNeedsLayout];
}


#pragma mark Button Event
- (void)clickFavButton:(id)sender{
    if (![sender isKindOfClass:[SPDetailButton class]]) {
        return;
    }
    _photoData.favorite = !_photoData.favorite;
    NSString *favImageStr = _photoData.favorite ? @"detail_fav" : @"detail_unfav";
    _favButton.icon.image = [UIImage imageNamed:favImageStr];
}

- (void)clickDownloadButton:(id)sender{
    UIImageWriteToSavedPhotosAlbum(_photoView.image, self, @selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:), nil);
}

- (void)clickMoreButton:(id)sender{
    [SPSharePopUpView sharedInstance].contents = [self shareContents];
    [[SPSharePopUpView sharedInstance] show];
}



#pragma mark  Public Methods


#pragma mark  Private Methods
- (void)imageSavedToPhotosAlbum:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    NSString * message = nil;
    if (!error) {
        message = @"成功保存到相册";
    }else
        
    {
        message = [error description];
    }
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.label.text = message;
    HUD.mode = MBProgressHUDModeText;
    
    //指定距离中心点的X轴和Y轴的位置，不指定则在屏幕中间显示
    //    HUD.yOffset = 100.0f;
    //    HUD.xOffset = 100.0f;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [HUD showAnimated:YES];
        [HUD hideAnimated:YES afterDelay:2.f];
        NSLog(@"message is %@",message);
    });
    
}

#pragma mark Private Methods
- (NSArray *)shareContents{
    SPShareContentData *content1 =  [[SPShareContentData alloc] init];
    content1.title = @"微信";
    content1.image = [UIImage imageNamed:@"share_weixin"];
    content1.imagePressed = [UIImage imageNamed:@"share_weixin_pressed"];
    
    SPShareContentData *content2 =  [[SPShareContentData alloc] init];
    content2.title = @"易信";
    content2.image = [UIImage imageNamed:@"share_yixin"];
    content2.imagePressed = [UIImage imageNamed:@"share_yixin_pressed"];
    return @[content1, content2];
}


@end
