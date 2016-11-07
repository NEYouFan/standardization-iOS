//
//  SPTabBarController.m
//  StandardizationPractice
//
//  Created by Baitianyu on 18/10/2016.
//  Copyright © 2016 Netease. All rights reserved.
//

#import "SPTabBarController.h"
#import "HTSegmentsView.h"
#import "MCBlurView.h"
#import "HTNavigationController.h"
#import "SPTabBarItem.h"
#import "UIImage+ImageWithColor.h"
#import "HTContainerViewController.h"
#import "SPMineController.h"
#import "SPSquareController.h"
#import "SPSearchController.h"
#import "SPPublishController.h"

@interface SPTabBarController () <HTSegmentsViewDelegate, HTSegmentsViewDatasource>

@property (nonatomic, strong) HTSegmentsView *segmentsTabbar;
@property (nonatomic, strong) MCBlurView *bgView;

@property (nonatomic, strong) NSMutableArray *icons;
@property (nonatomic, strong) NSMutableArray *selectedIcons;

@property (nonatomic,assign) NSInteger unreadMessageCount;

@end

@implementation SPTabBarController

#pragma mark - Life cycle.

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self loadTabBar];
        [self loadControllers];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [self clearUITabbarItem]; // Should be called after viewDidload.
    [super viewDidAppear:animated];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    _segmentsTabbar.frame = self.tabBar.bounds;
    _bgView.frame = self.tabBar.bounds;
}


#pragma mark - Load views.

- (void)loadTabBar {
    _icons = [NSMutableArray arrayWithArray:@[@"tab_square",
                                              @"tab_search",
                                              @"tab_publish",
                                              @"tab_mine"]];
    _selectedIcons = [NSMutableArray arrayWithArray:@[@"tab_square_selected",
                                                      @"tab_search_selected",
                                                      @"tab_publish_selected",
                                                      @"tab_mine_selected"]];
    
    // Load tabbar item.
    [self loadSegmentsView];
}

- (void)loadSegmentsView {
    _bgView = [[MCBlurView alloc] initWithStyle:MCBlurStyleWhite];
    [self.tabBar addSubview:_bgView];
    
    _segmentsTabbar = [[HTHorizontalSegmentsView alloc] initWithSelectedIndex:0];
    _segmentsTabbar.segmentsDataSource = self;
    _segmentsTabbar.segmentsDelegate = self;
    _segmentsTabbar.backgroundColor = [UIColor clearColor];
    [self.tabBar addSubview:_segmentsTabbar];
}

- (void)clearUITabbarItem {
    //清理原来的tabbar的内容
    for (UIView *subView in self.tabBar.subviews) {
        if ([subView isKindOfClass:MCBlurView.class] ||
            [subView isKindOfClass:HTHorizontalSegmentsView.class] ||
            CGRectGetHeight(subView.frame) <= 2 ||
            [subView isKindOfClass:[UIImageView class]]) {
            continue;
        }
        
        subView.hidden = YES;
        subView.alpha = 0;
    }

    self.tabBar.backgroundImage = [UIImage imageWithColor:[UIColor clearColor]];
}


#pragma mark - Load Tabs.

- (void)loadControllers {
    NSMutableArray *tabViewControllers = [[NSMutableArray alloc] init];
    
    // Square tab
    SPSquareController *squareController = [[SPSquareController alloc] init];
    HTContainerViewController *containerController = [[HTContainerViewController alloc] initWithRootViewController:squareController];
    [tabViewControllers addObject:containerController];
    
    // Search tab
    SPSearchController *searchController = [[SPSearchController alloc] init];
    containerController = [[HTContainerViewController alloc] initWithRootViewController:searchController];
    [tabViewControllers addObject:containerController];
    
    // Publish tab
    SPPublishController *publishController = [[SPPublishController alloc] init];
    containerController = [[HTContainerViewController alloc] initWithRootViewController:publishController];
    [tabViewControllers addObject:containerController];
    
    // Mine tab
    SPMineController *mineController = [[SPMineController alloc] init];
    containerController = [[HTContainerViewController alloc] initWithRootViewController:mineController];
    [tabViewControllers addObject:containerController];
    
    self.viewControllers = tabViewControllers;
}


#pragma mark - HTSegmentsViewDelegate

- (BOOL)segmentsView:(HTSegmentsView*)segmentsView shouldSelectedAtIndex:(NSUInteger)index {
    BOOL shouldSelected = YES;
    
    if ([self.delegate respondsToSelector:@selector(tabBarController:shouldSelectViewController:)]) {
        shouldSelected = [self.delegate tabBarController:self shouldSelectViewController:self.viewControllers[index]];
    }
    return shouldSelected;
}

- (void)segmentsView:(HTSegmentsView*)segmentsView didSelectedAtIndex:(NSUInteger)index {
    [super setSelectedIndex:index];
    
    if ([self.delegate respondsToSelector:@selector(tabBarController:didSelectViewController:)]) {
        [self.delegate tabBarController:self didSelectViewController:self.viewControllers[index]];
    }
}


#pragma mark - HTSegmentsViewDatasource

- (NSUInteger)numberOfCellsInSegementsView:(HTSegmentsView*)segmentsView {
    return _icons.count;
}

- (HTSegmentsCellView*)segmentsView:(HTSegmentsView*)segmentsView cellForIndex:(NSUInteger)index {
    SPTabBarItem *itemCell = [[SPTabBarItem alloc] initWithIcon:_icons[index]
                                                    selectedIcon:_selectedIcons[index]];
    return itemCell;
}

- (CGSize)segmentsView:(HTSegmentsView*)segmentsView cellSizeForIndex:(NSUInteger)index {
    CGFloat screenWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
    return CGSizeMake(screenWidth/_icons.count, CGRectGetHeight(self.tabBar.bounds));
}

@end
