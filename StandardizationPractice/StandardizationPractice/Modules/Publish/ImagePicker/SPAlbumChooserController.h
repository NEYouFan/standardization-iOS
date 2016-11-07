//
//  SPAlbumChooserController.h
//  StandardizationPractice
//
//  Created by Baitianyu on 31/10/2016.
//  Copyright © 2016 Netease. All rights reserved.
//

#import "SPBaseViewController.h"
#import "SPImagePickerController.h"

@interface SPAlbumChooserController : SPBaseViewController

@property (nonatomic, assign) BOOL pushImagePicker;
@property (nonatomic, weak) id<SPImagePickerDismissDelegate> delegate;

@end
