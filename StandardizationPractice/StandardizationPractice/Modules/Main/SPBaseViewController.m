//
//  SPBaseViewController.m
//  StandardizationPractice
//
//  Created by Baitianyu on 18/10/2016.
//  Copyright © 2016 Netease. All rights reserved.
//

#import "SPBaseViewController.h"
#import "HTBaseRequest.h"

@interface SPBaseViewController ()

@property (nonatomic, strong) NSPointerArray *needCancelRequests;
@property (nonatomic, assign) SPStatusBarStyle lastStatusBarStyle;

@end

@implementation SPBaseViewController

#pragma mark - Life cycle.

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [SPThemeColors backgroundColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_statusBarStyle != SPStatusBarStyleInvalid) {
        _lastStatusBarStyle = [self currentStatusBarStyle];
        [UIApplication sharedApplication].statusBarStyle = [self convertStatusBarStyle:_statusBarStyle];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.statusBarStyle != SPStatusBarStyleInvalid) {
        [UIApplication sharedApplication].statusBarStyle = [self convertStatusBarStyle:_lastStatusBarStyle];
    }
}

- (void)dealloc {
    for (HTBaseRequest *request in _needCancelRequests) {
        if (request) {
            [request cancel];
        }
    }
}


#pragma mark - Public methods.

- (void)cancelRequestWhenControllerDealloc:(HTBaseRequest *)request {
    if (!_needCancelRequests) {
        _needCancelRequests = [NSPointerArray weakObjectsPointerArray];
    }
    [_needCancelRequests addPointer:(__bridge void * _Nullable)request];
}

- (void)clearRequests {
    for (HTBaseRequest *request in _needCancelRequests) {
        if (request) {
            [request cancel];
        }
    }
}


#pragma mark - Private methods.

- (SPStatusBarStyle)currentStatusBarStyle {
    if ([UIApplication sharedApplication].statusBarStyle == UIStatusBarStyleDefault) {
        return SPStatusBarStyleDefault;
    } else if ([UIApplication sharedApplication].statusBarStyle == UIStatusBarStyleLightContent) {
        return SPStatusBarStyleLightContent;
    } else {
        return SPStatusBarStyleLightContent;
    }
}

- (UIStatusBarStyle)convertStatusBarStyle:(SPStatusBarStyle)style {
    if (style == SPStatusBarStyleDefault) {
        return UIStatusBarStyleDefault;
    } else if (style == SPStatusBarStyleLightContent) {
        return UIStatusBarStyleLightContent;
    } else {
        return UIStatusBarStyleLightContent;
    }
}

@end
