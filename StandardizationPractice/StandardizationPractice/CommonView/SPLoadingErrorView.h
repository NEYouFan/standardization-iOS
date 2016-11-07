//
//  SPLoadingErrorView.h
//  StandardizationPractice
//
//  Created by Baitianyu on 19/10/2016.
//  Copyright © 2016 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SPLoadingErrorView;

@protocol SPLoadingErrorDelegate <NSObject>

@optional
- (void)loadingReload:(SPLoadingErrorView *)view;

@end


@interface SPLoadingErrorView : UIView

@property (nonatomic, weak) id<SPLoadingErrorDelegate> delegate;

@end
