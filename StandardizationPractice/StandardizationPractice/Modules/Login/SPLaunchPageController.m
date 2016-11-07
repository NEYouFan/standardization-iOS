//
//  SPLaunchPageController.m
//  StandardizationPractice
//
//  Created by Baitianyu on 18/10/2016.
//  Copyright © 2016 Netease. All rights reserved.
//

#import "SPLaunchPageController.h"

@interface SPLaunchPageController ()

@property (nonatomic, strong) UIImageView *backGroundImageView;

@end

@implementation SPLaunchPageController

#pragma mark - Life cycle.

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [SPThemeColors backgroundColor];
    [self loadSubviews];
    [self scheduleDismiss];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    _backGroundImageView.frame = self.view.bounds;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}


#pragma mark - Load views.

- (void)loadSubviews {
    _backGroundImageView = [[UIImageView alloc] init];
    
    NSString *launchImageName;
    CGFloat screenHeight = [SPThemeSizes screenHeight];
    
    if (screenHeight == 480) {
        launchImageName = @"LaunchImage-700@2x.png";
    } else if (screenHeight == 568) {
        launchImageName = @"LaunchImage-700-568h@2x.png";
    } else if (screenHeight == 667) {
        launchImageName = @"LaunchImage-800-667h@2x.png";
    } else {
        launchImageName = @"LaunchImage-800-Portrait-736h@3x.png";
    }
    
    _backGroundImageView.image = [UIImage imageNamed:launchImageName];
    [self.view addSubview:_backGroundImageView];
}


#pragma mark - Actions.

- (void)scheduleDismiss {
    @SPWeakSelf(self);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_delegate launchPageControllerDidDisappear:weakSelf];
    });
}

@end
