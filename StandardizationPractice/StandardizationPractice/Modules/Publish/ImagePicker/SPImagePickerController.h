//
//  SPImagePickerController.h
//  StandardizationPractice
//
//  Created by Baitianyu on 31/10/2016.
//  Copyright © 2016 Netease. All rights reserved.
//

#import "SPBaseViewController.h"
#import "HTAssetsPickerView.h"

@protocol SPImagePickerDismissDelegate <NSObject>

@required
- (void)imagePickerDismiss:(SPBaseViewController *)imagePickerController;

@end

@interface SPImagePickerController : SPBaseViewController

@property (nonatomic,strong) HTAssetsPickerView* assetsPicker;

@property (nonatomic, copy) NSString *naviTitle;
@property (nonatomic, strong) ALAssetsGroup *assetGroup;
@property (nonatomic, weak) id<SPImagePickerDismissDelegate> delegate;

@end
