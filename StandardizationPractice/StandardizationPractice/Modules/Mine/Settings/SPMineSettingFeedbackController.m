//
//  SPMineSettingFeedbackController.m
//  StandardizationPractice
//
//  Created by Baitianyu on 21/10/2016.
//  Copyright © 2016 Netease. All rights reserved.
//

#import "SPMineSettingFeedbackController.h"
#import "UIViewController+SPNavigationBar.h"
#import "UIView+Frame.h"
#import "SPMineSizes.h"
#import "SPRefreshView.h"
#import "SPTestRefreshingController.h"

@interface SPMineSettingFeedbackController ()

// 对于这种基本不太会变化且控件比较少的页面，可以直接将子view添加到一个 scrollview 中
@property (nonatomic, strong) UIScrollView *backScrollView;
@property (nonatomic, strong) UILabel *indicationLabel;
@property (nonatomic, strong) UITextView *inputTextView;
@property (nonatomic, strong) UIButton *sendButton;
@property (nonatomic, strong) SPRefreshView *refreshView;

@end

@implementation SPMineSettingFeedbackController

#pragma mark - Life cycle.

- (void)viewDidLoad {
    [super viewDidLoad];
    [self sp_applyDefaultNavigationBarStyle];
    [self sp_addNavigationLeftBackItem];
    self.title = @"反馈";
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self loadSubviews];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    _backScrollView.frame = self.view.bounds;
    _backScrollView.contentSize = CGSizeMake(_backScrollView.frame.size.width,
                                             _backScrollView.frame.size.height + 1);
    
    _indicationLabel.x = [SPThemeSizes leftMargin];
    _indicationLabel.y = [SPMineSizes indicationTopMargin];

    _inputTextView.x = [SPThemeSizes leftMargin];
    _inputTextView.y = [SPMineSizes textViewTopMargin];
    _inputTextView.width = [SPThemeSizes screenWidth] - [SPThemeSizes leftMargin] - [SPThemeSizes rightMargin];
    _inputTextView.height = [SPMineSizes textViewHeight];
    
    _sendButton.tail = [SPThemeSizes screenWidth] - [SPThemeSizes rightMargin];
    _sendButton.y = _inputTextView.bottom + [SPMineSizes textViewSendButtonGap];
}


#pragma mark - Load views.

- (void)loadSubviews {
    _backScrollView = [[UIScrollView alloc] init];
    _backScrollView.backgroundColor = [SPThemeColors backgroundColor];
    [self.view addSubview:_backScrollView];
    
    _indicationLabel = [[UILabel alloc] init];
    _indicationLabel.text = @"写点什么给我们";
    _indicationLabel.font = [SPMineSizes feedbackIndicationFont];
    _indicationLabel.textColor = [SPThemeColors lightTextColor];
    [_indicationLabel sizeToFit];
    [_backScrollView addSubview:_indicationLabel];

    _inputTextView = [[UITextView alloc] init];
    _inputTextView.layer.masksToBounds = YES;
    _inputTextView.textColor = [SPThemeColors lightTextColor];
    _inputTextView.font = [SPMineSizes feedbackTextViewFont];
    _inputTextView.layer.cornerRadius = [SPThemeSizes cornerRadiusSize];
    _inputTextView.layer.borderColor = [SPThemeColors lineColor].CGColor;
    _inputTextView.layer.borderWidth = [SPThemeSizes lineWidth];
    [_backScrollView addSubview:_inputTextView];

    // 发送按钮
    _sendButton = [[UIButton alloc] init];
    [_sendButton setImage:[UIImage imageNamed:@"feedback_send"] forState:UIControlStateNormal];
    [_sendButton setImage:[UIImage imageNamed:@"feedback_send_highlight"] forState:UIControlStateHighlighted];
    [_sendButton addTarget:self action:@selector(sendFeedback:) forControlEvents:UIControlEventTouchUpInside];
    [_sendButton sizeToFit];
    [_backScrollView addSubview:_sendButton];
}


#pragma mark - Actions.

- (void)sendFeedback:(id)sender {
    // 测试 refreshview
    SPTestRefreshingController *testRefreshControlelr = [[SPTestRefreshingController alloc] init];
    [self.navigationController pushViewController:testRefreshControlelr animated:YES];
}

- (void)testRefresh {
    @SPWeakSelf(self);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf.refreshView endRefresh:YES];
    });
}

@end
