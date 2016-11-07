//
//  UIViewController+SPNavigationBar.m
//  StandardizationPractice
//
//  Created by Baitianyu on 19/10/2016.
//  Copyright © 2016 Netease. All rights reserved.
//

#import "UIViewController+SPNavigationBar.h"
#import "UINavigationBar+HT.h"
#import "UIImage+ImageWithColor.h"
#import "ColorUtils.h"
#import <HTCommonUtility/UIView+Frame.h>
#import <Masonry/Masonry.h>
#import "UIViewController+HTRouterUtils.h"
#import "SPThemeSizes.h"
#import "SPThemeColors.h"
#import "SPSearchSizes.h"
#import "SPSearchColors.h"

@implementation SPBaseViewController (SPNavigationBar)

- (void)sp_applyDefaultNavigationBarStyle {
    self.statusBarStyle = SPStatusBarStyleLightContent;
    [self.navigationController.navigationBar setBarTintColor:[SPThemeColors naviBackgroundColor]];
    self.navigationController.navigationBar.translucent = NO;
    
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[SPThemeColors naviForegroundColor], NSForegroundColorAttributeName, [SPThemeSizes naviTitleFont], NSFontAttributeName, nil]];
}

- (void)sp_applyTransparentNavigationBarStyle {
    self.statusBarStyle = SPStatusBarStyleLightContent;
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)sp_applyTransparentNavigationBarDarkStatus {
    self.statusBarStyle = SPStatusBarStyleDefault;
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)sp_addNavigationLeftBackItem {
    UIImage *leftBackImage = [UIImage imageNamed:@"navi_back"];
    UIImage *leftBackHighlightImage = [UIImage imageNamed:@"navi_back_highlight"];
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 17, 26)];
    [backButton setBackgroundImage:leftBackImage forState:UIControlStateNormal];
    [backButton setBackgroundImage:leftBackHighlightImage forState:UIControlStateHighlighted];
    [backButton addTarget:self action:@selector(ht_back) forControlEvents:UIControlEventTouchUpInside];
    
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:backButton]];
}

- (UIButton *)sp_addNavigationRightSettingItem {
    UIImage *settingImage = [UIImage imageNamed:@"navi_setting"];
    UIImage *settingHighlightImage = [UIImage imageNamed:@"navi_setting_highlight"];
    
    UIButton *settingButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [settingButton setBackgroundImage:settingImage forState:UIControlStateNormal];
    [settingButton setBackgroundImage:settingHighlightImage forState:UIControlStateHighlighted];
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:settingButton]];
    
    return settingButton;
}

- (UIView *)sp_addNavigationMidViewWithTitle:(NSString *)title image:(UIImage *)image{
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(30, 0, [SPThemeSizes screenWidth] - 60, kNavigationBarHeight)];
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = title;
    titleLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:18.0];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [SPThemeColors naviForegroundColor];
    [titleLabel sizeToFit];
    titleLabel.height = kNavigationBarHeight;
    
    UIImageView *iconView = [[UIImageView alloc] initWithImage:image];
    iconView.width = 14;
    iconView.height = 16;
    iconView.x = (titleView.width - (iconView.width + 7 + titleLabel.width))/2;
    iconView.y = (kNavigationBarHeight - iconView.height)/2;
    titleLabel.x = iconView.x + iconView.width + 7;
    titleLabel.y = 0;
    
    [titleView addSubview:iconView];
    [titleView addSubview:titleLabel];
    self.navigationItem.titleView = titleView;

    return titleView;
}


- (UISearchBar *)sp_addNavigationSearchItem {
    UISearchBar *searchBar = [[UISearchBar alloc]init];
    searchBar.searchBarStyle = UISearchBarStyleDefault;
    [searchBar setShowsCancelButton:NO]; //显示右侧取消按钮
    searchBar.backgroundColor = [SPThemeColors naviBackgroundColor];
    [searchBar setBarTintColor:[SPThemeColors naviBackgroundColor]];
    [searchBar setImage:[UIImage imageNamed:@"search_search"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    
    searchBar.delegate = (id<UISearchBarDelegate>)self;
    [searchBar setPlaceholder:@"搜索搜索城市或者景区名"];
    [searchBar sizeToFit];
    
    //将搜索条放在一个UIView上
    UIView *searchView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [SPThemeSizes screenWidth], kNavigationBarHeight)];
    searchView.backgroundColor = [SPThemeColors naviBackgroundColor];
    [searchView addSubview:searchBar];
    
    [self setTextColor:[SPSearchColors searchTextColor]
                  font:[UIFont fontWithName:@"Arial-BoldMT" size:12.f]
                  with:searchBar.subviews];
    
    [searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(searchView).with.offset(32.5);
        make.top.and.bottom.equalTo(searchView);
        make.right.equalTo(searchView.mas_right).with.offset(-32.5);
    }];
    
    self.navigationItem.titleView = searchView;
    return searchBar;
}

- (UIButton *)sp_addNavigationRightCloseItem {
    UIImage *closeImage = [UIImage imageNamed:@"navi_close"];
    UIImage *closeHighlightImage = [UIImage imageNamed:@"navi_close_highlight"];
    
    UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [closeButton setBackgroundImage:closeImage forState:UIControlStateNormal];
    [closeButton setBackgroundImage:closeHighlightImage forState:UIControlStateHighlighted];
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:closeButton]];
    
    return closeButton;
}


#pragma mark - Private Methods.

- (void)setTextColor:(UIColor*)color font:(UIFont *)font with:(NSArray *)subviews {
    for (UIView *v in subviews) {
        for(id subview in v.subviews) {
            if ([subview isKindOfClass:[UITextField class]]) {
                ((UITextField *)subview).textColor = color;
                ((UITextField *)subview).font = font;
                [subview setValue:color forKeyPath:@"_placeholderLabel.textColor"];
                [subview setValue:font forKeyPath:@"_placeholderLabel.font"];
            }
        }
    }
}

@end
