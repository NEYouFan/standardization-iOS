//
//  SPPublishController.m
//  StandardizationPractice
//
//  Created by Baitianyu on 18/10/2016.
//  Copyright © 2016 Netease. All rights reserved.
//

#import "SPPublishController.h"
#import "UIViewController+SPNavigationBar.h"
#import "UIView+Frame.h"
#import "SPPublishSizes.h"
#import "UIView+SPLoading.h"
#import "SPPublishColors.h"
#import "SPPublishEditController.h"
#import "UIView+SPToast.h"
#import "HTControllerRouteInfo.h"
#import "HTControllerRouter.h"
#import "HTContainerViewController.h"
#import "UINavigationBar+HT.h"
#import "HTNavigationPanProtocol.h"
#import "UIViewController+HTRouter.h"
#import "HTNavigationController.h"
#import "AppDelegate.h"
#import "SPAlbumChooserController.h"
@import AVFoundation;

static const char *kSessionQueueIdentifier = "com.netease.standardization.capture";

@interface SPPublishController () <SPPublishEditControllerDelegate, SPImagePickerDismissDelegate>
// 此页面就不用 scrollView 了，照相页面可滚动没有意义
@property (nonatomic, strong) UIView *previewLayerView;
@property (nonatomic, strong) UIButton *captureButton;
@property (nonatomic, strong) UIButton *openPhotosButton;
@property (nonatomic, strong) UILabel *captureLabel;
@property (nonatomic, strong) UILabel *openPhotoLabel;

// Capture
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureDevice *backDevice;
@property (nonatomic, strong) AVCaptureDevice *frontDevice;
@property (nonatomic, strong) AVCaptureDeviceInput *backDeviceInput;
@property (nonatomic, strong) AVCaptureDeviceInput *frontDeviceInput;
@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

@end

@implementation SPPublishController

#pragma mark - Life cycle.

- (void)viewDidLoad {
    [super viewDidLoad];
    [self sp_applyDefaultNavigationBarStyle];
    [self sp_addNavigationMidViewWithTitle:@"发布" image:[UIImage imageNamed:@"publish_logo"]];
    [self loadSubviews];
#if !(TARGET_IPHONE_SIMULATOR)
    [self configCamera];
#else

#endif
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
#if !(TARGET_IPHONE_SIMULATOR)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self stopSession];
    });
#else
    
#endif
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
#if !(TARGET_IPHONE_SIMULATOR)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self startSession];
    });
#else
    
#endif
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    _previewLayerView.width = self.view.width;
    _previewLayerView.height = [SPPublishSizes previewLayerHeight];
    _previewLayerView.y = 0;
    _previewLayerView.x = 0;

    _previewLayer.frame = _previewLayerView.bounds;
    
    _captureButton.x = [SPPublishSizes captureButtonLeftMargin];
    _captureButton.y = _previewLayerView.bottom + [SPPublishSizes previewButtonGap];
    
    _openPhotosButton.tail = self.view.width - [SPPublishSizes photoButtonRightMargin];
    _openPhotosButton.middleY = _captureButton.middleY;
    
    _captureLabel.middleX = _captureButton.middleX;
    _captureLabel.y = _captureButton.bottom + [SPPublishSizes buttonTitleGap];
    
    _openPhotoLabel.middleX = _openPhotosButton.middleX;
    _openPhotoLabel.middleY = _captureLabel.middleY;
}


#pragma mark - Load views.

- (void)loadSubviews {
    _previewLayerView = [[UIView alloc] init];
    _previewLayerView.backgroundColor = [SPPublishColors waitingBackgroundColor];
    [self.view addSubview:_previewLayerView];
    
    _captureButton = [[UIButton alloc] init];
    [_captureButton setBackgroundImage:[UIImage imageNamed:@"camera"] forState:UIControlStateNormal];
    [_captureButton setBackgroundImage:[UIImage imageNamed:@"camera_highlight"] forState:UIControlStateHighlighted];
    [_captureButton sizeToFit];
    [_captureButton addTarget:self action:@selector(captureButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_captureButton];
    
    _openPhotosButton = [[UIButton alloc] init];
    [_openPhotosButton setBackgroundImage:[UIImage imageNamed:@"photos"] forState:UIControlStateNormal];
    [_openPhotosButton setBackgroundImage:[UIImage imageNamed:@"photos_highlight"] forState:UIControlStateHighlighted];
    [_openPhotosButton sizeToFit];
    [_openPhotosButton addTarget:self action:@selector(openPhotosButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_openPhotosButton];
    
#if (TARGET_IPHONE_SIMULATOR)
    _captureButton.userInteractionEnabled = NO;
#else
    
#endif
    
    _captureLabel = [[UILabel alloc] init];
    _captureLabel.text = @"拍照";
    _captureLabel.font = [SPPublishSizes titleFont];
    _captureLabel.textColor = [SPThemeColors lightTextColor];
    [_captureLabel sizeToFit];
    [self.view addSubview:_captureLabel];
    
    _openPhotoLabel = [[UILabel alloc] init];
    _openPhotoLabel.text = @"相册";
    _openPhotoLabel.font = [SPPublishSizes titleFont];
    _openPhotoLabel.textColor = [SPThemeColors lightTextColor];
    [_openPhotoLabel sizeToFit];
    [self.view addSubview:_openPhotoLabel];
}


#pragma mark - Capture.

- (void)configCamera {
    _captureSession = [[AVCaptureSession alloc] init];
    _captureSession.sessionPreset = AVCaptureSessionPresetPhoto;
    for (AVCaptureDevice *device in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
        if (device.position == AVCaptureDevicePositionBack) {
            _backDevice = device;
        } else if (device.position == AVCaptureDevicePositionFront) {
            _frontDevice = device;
        }
    }
    
    _backDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:_backDevice error:nil];
    _stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    
    if ([_captureSession canAddInput:_backDeviceInput]) {
        [_captureSession addInput:_backDeviceInput];
    }
    if ([_captureSession canAddOutput:_stillImageOutput]) {
        [_captureSession addOutput:_stillImageOutput];
    }
    
    _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [_previewLayerView.layer addSublayer:_previewLayer];
}

- (void)startSession {
    dispatch_queue_t queue = dispatch_queue_create(kSessionQueueIdentifier, DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{
        if (![_captureSession isRunning]) {
            [_captureSession startRunning];
        }
    });
}

- (void)stopSession {
    dispatch_queue_t queue = dispatch_queue_create(kSessionQueueIdentifier, DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{
        if ([_captureSession isRunning]) {
            [_captureSession stopRunning];
        }
    });
}


#pragma mark - Actions.

- (void)captureButtonClicked:(id)sender {
    [[UIApplication sharedApplication].keyWindow sp_showLoadingWithBackgroundColor:[SPPublishColors waitingBackgroundColor]];
    dispatch_queue_t queue = dispatch_queue_create(kSessionQueueIdentifier, DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{
        AVCaptureConnection *connection = [self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
        
        [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:connection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            
            NSDictionary *metaData = (__bridge_transfer NSDictionary *)CMCopyDictionaryOfAttachments(nil, imageDataSampleBuffer,kCMAttachmentMode_ShouldPropagate);
            NSLog(@"%@", metaData);
            
            UIImage *image = [UIImage imageWithData:imageData];
            UIImageWriteToSavedPhotosAlbum(image, self, @selector(savePhotoComplete:didFinishSavingWithError:contextInfo:), nil);
        }];
    });
}

- (void)savePhotoComplete:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    [[UIApplication sharedApplication].keyWindow sp_hideLoading];
    HTControllerRouteParam *param = [[HTControllerRouteParam alloc] init];
    param.url = @"standardization://publish/edit";
    param.launchMode = HTControllerLaunchModePresentNavigation;
    param.fromViewController = [SPAPPDELEGATE() rootNavigationController];
    param.params = image;
    param.delegate = self;
    
    [[HTControllerRouter sharedRouter] route:param];
}

- (void)openPhotosButtonClicked:(id)sender {
    HTControllerRouteParam *param = [[HTControllerRouteParam alloc] init];
    param.url = @"standardization://publish/photochooser";
    param.launchMode = HTControllerLaunchModePresentNavigation;
    param.fromViewController = [SPAPPDELEGATE() rootNavigationController];
    param.delegate = self;
    param.params = @(YES);
    
    [[HTControllerRouter sharedRouter] route:param];
}


#pragma mark - SPPublishEditControllerDelegate.

- (void)editDismissed:(SPPublishEditController *)editController {
    [self startSession];
}


#pragma mark - SPImagePickerDismissDelegate.

- (void)imagePickerDismiss:(SPBaseViewController *)imagePickerController {
    [self startSession];
}

@end
