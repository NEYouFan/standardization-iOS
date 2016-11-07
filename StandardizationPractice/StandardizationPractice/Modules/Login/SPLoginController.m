//
//  SPLoginController.m
//  StandardizationPractice
//
//  Created by Baitianyu on 18/10/2016.
//  Copyright © 2016 Netease. All rights reserved.
//

#import "SPLoginController.h"
#import "UIViewController+SPNavigationBar.h"
#import "UIView+Frame.h"
#import "HTControllerRouteInfo.h"
#import "HTControllerRouter.h"
#import "HTContainerViewController.h"
#import "UINavigationBar+HT.h"
#import "HTNavigationPanProtocol.h"
#import "UIViewController+HTRouter.h"
#import "SPLoginInputView.h"
#import "SPKeyboardSequence.h"
#import "AppDelegate.h"
#import "HTNavigationController.h"
#import "UIView+SPLoading.h"
#import "UIView+SPToast.h"
#import "SPUserDataManager.h"
#import "SPLoginSizes.h"
#import "SPLoginColors.h"
#import "SPLoginInputViewModel.h"

static NSString *const kSuccessBlockKey = @"successBlock";
static NSString *const kCancelBlockKey = @"cancelBlock";

@interface SPLoginController () <HTRouteTargetProtocol,
                                 HTContainerViewControllerProtocol,
                                 UITextFieldDelegate,
                                 UITextViewDelegate>

@property (nonatomic, strong) UIScrollView *containerView;
@property (nonatomic, strong) SPLoginInputView *userNameInputView;
@property (nonatomic, strong) SPLoginInputView *passwordInputView;
@property (nonatomic, strong) UIButton *loginButton;
@property (nonatomic, strong) UILabel *registerLabel;
@property (nonatomic, strong) UIButton *registerButton;
@property (nonatomic, strong) SPKeyboardSequence *keyboardSequenceManager;
@property (nonatomic, strong) UIButton *closeButton;

@property (nonatomic, copy) void (^successBlock)();
@property (nonatomic, copy) void (^cancelBlock)();

@end

@implementation SPLoginController
@synthesize containerController;

#pragma mark - Router

+ (HTControllerRouterConfig*)configureRouter {
    HT_EXPORT();
    HTControllerRouterConfig *config = [[HTControllerRouterConfig alloc] initWithUrlPath:[self urlPath]];
    return config;
}

+ (NSString*)urlPath {
    return @"standardzation://login";
}

- (void)receiveRoute:(HTControllerRouteParam*)param {
    if ([param.params objectForKey:kSuccessBlockKey]) {
        _successBlock = [param.params objectForKey:kSuccessBlockKey];
    }
    if ([param.params objectForKey:kCancelBlockKey]) {
        _cancelBlock = [param.params objectForKey:kCancelBlockKey];
    }
}


#pragma mark - Life cycle.

- (void)viewDidLoad {
    [super viewDidLoad];
    [self sp_applyTransparentNavigationBarDarkStatus];
    self.view.backgroundColor = [SPThemeColors backgroundColor];
    _closeButton = [self sp_addNavigationRightCloseItem];
    [_closeButton addTarget:self action:@selector(closeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self loadSubviews];
    [self configKeyboard];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    _containerView.frame = self.view.bounds;
    
    _userNameInputView.width = _containerView.width - 2 * [SPLoginSizes inputViewSideMargin];
    _userNameInputView.height = [SPLoginSizes inputViewHeight];
    _userNameInputView.x = [SPLoginSizes inputViewSideMargin];
    _userNameInputView.y = [SPLoginSizes inputViewTopMargin] + kNavigationBarHeight + kStatusBarHeight;
    
    _passwordInputView.size = _userNameInputView.size;
    _passwordInputView.x = _userNameInputView.x;
    _passwordInputView.y = _userNameInputView.bottom;

    _loginButton.y = _passwordInputView.y;
    _loginButton.tail = _containerView.width - [SPLoginSizes loginIconRightMargin];
    
    _registerLabel.middleX = _containerView.width / 2;
    _registerLabel.bottom = _containerView.height - [SPLoginSizes registerLabelBottomMargin];
    
    _registerButton.middleX = _containerView.width / 2;
    _registerButton.bottom = _registerLabel.y - [SPLoginSizes registerIconLabelGap];
}


#pragma mark - Load views.

- (void)loadSubviews {
    _containerView = [[UIScrollView alloc] init];
    [self.view addSubview:_containerView];
    
    _userNameInputView = [[SPLoginInputView alloc] init];
    SPLoginInputViewModel *userNameViewModel = [[SPLoginInputViewModel alloc] initWithImageName:@"user_name" placeholder:@"邮箱" optionString:nil];
    _userNameInputView.viewModel = userNameViewModel;
    [_containerView addSubview:_userNameInputView];
    
    _passwordInputView = [[SPLoginInputView alloc] init];
    SPLoginInputViewModel *passwordViewModel = [[SPLoginInputViewModel alloc] initWithImageName:@"password" placeholder:@"密码" optionString:@"忘记密码"];
    _passwordInputView.viewModel = passwordViewModel;
    [_containerView addSubview:_passwordInputView];
    
    _loginButton = [[UIButton alloc] init];
    [_loginButton setBackgroundImage:[UIImage imageNamed:@"login"] forState:UIControlStateNormal];
    [_loginButton setBackgroundImage:[UIImage imageNamed:@"login_highlight"] forState:UIControlStateHighlighted];
    [_loginButton addTarget:self action:@selector(loginUser:) forControlEvents:UIControlEventTouchUpInside];
    [_loginButton sizeToFit];
    [_containerView addSubview:_loginButton];
    
    _registerButton = [[UIButton alloc] init];
    [_registerButton setBackgroundImage:[UIImage imageNamed:@"register"] forState:UIControlStateNormal];
    [_registerButton setBackgroundImage:[UIImage imageNamed:@"register_highlight"] forState:UIControlStateHighlighted];
    [_registerButton addTarget:self action:@selector(registerUser:) forControlEvents:UIControlEventTouchUpInside];
    [_registerButton sizeToFit];
    [_containerView addSubview:_registerButton];
    
    _registerLabel = [[UILabel alloc] init];
    _registerLabel.text = @"使用电子邮件注册";
    _registerLabel.font = [SPLoginSizes registerFont];
    _registerLabel.textColor = [SPThemeColors lightTextColor];
    [_registerLabel sizeToFit];
    [_containerView addSubview:_registerLabel];
}


#pragma mark - Actions.

- (void)loginUser:(id)sender {
    [self login];
}

- (void)login {
    @SPWeakSelf(self);
    if (_userNameInputView.text.length < 8 || _passwordInputView.text.length < 6) {
        [self.view sp_showToastWithMessage:@"请填写合法用户名和密码"];
        return;
    }
    
    [self.view sp_showLoadingWithBackgroundColor:[UIColor clearColor]];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf.view sp_hideLoading];
        [SPUserDataManager sharedInstance].userName = _userNameInputView.text;
        if (weakSelf.successBlock) {
            weakSelf.successBlock();
        }
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    });
}

- (void)registerUser:(id)sender {
    
}

- (void)closeButtonClicked:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Config keyboard.

- (void)configKeyboard {
    _keyboardSequenceManager = [[SPKeyboardSequence alloc] init];
    _keyboardSequenceManager.delegate = self;
    [_keyboardSequenceManager addTextFieldView:_userNameInputView.inputTextField];
    [_keyboardSequenceManager addTextFieldView:_passwordInputView.inputTextField returnKeyType:UIReturnKeyGo];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == _passwordInputView.inputTextField){
        [self login];
    }
    
    return YES;
}


#pragma mark - Public methods.

+ (void)showLoginControllerWithSuccessBlock:(void (^)(void))successBlock
                                cancelBlock:(void (^)(void))cancelBlock {
    __weak __block UIViewController *loginController;
    HTControllerRouteParam *param = [[HTControllerRouteParam alloc] init];
    param.url = [self urlPath];
    param.launchMode = HTControllerLaunchModePresentNavigation;
    
    NSMutableDictionary *paramDic = [[NSMutableDictionary alloc] init];
    [paramDic setObject:^(){
        [loginController dismissViewControllerAnimated:YES
                                            completion:^{
                                                if (successBlock) {
                                                    successBlock();
                                                }
                                            }];
    } forKey:kSuccessBlockKey];
    
    if (nil != cancelBlock) {
        [paramDic setObject:cancelBlock forKey:kCancelBlockKey];
    }
    
    param.params = [paramDic copy];
    param.fromViewController = SPAPPDELEGATE().rootNavigationController;
    loginController = [[HTControllerRouter sharedRouter] route:param];
}

@end
