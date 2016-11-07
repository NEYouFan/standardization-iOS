//
//  SPPublishEditController.h
//  StandardizationPractice
//
//  Created by Baitianyu on 27/10/2016.
//  Copyright © 2016 Netease. All rights reserved.
//

#import "SPBaseViewController.h"

typedef NS_ENUM(NSInteger, SPPublishEditAlertType) {
    SPPublishEditAlertTypeNone = 0,
    SPPublishEditAlertTypeCity,
    SPPublishEditAlertTypeScenery
};

@class SPPublishEditController;

@protocol SPPublishEditControllerDelegate <NSObject>

@optional
- (void)editDismissed:(SPPublishEditController *)editController;

@end

@interface SPPublishEditController : SPBaseViewController

@property (nonatomic, strong) UIImage *publishImage;
@property (nonatomic, weak) id<SPPublishEditControllerDelegate> delegate;

@end
