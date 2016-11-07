//
//  SPLoginController.h
//  StandardizationPractice
//
//  Created by Baitianyu on 18/10/2016.
//  Copyright © 2016 Netease. All rights reserved.
//

#import "SPBaseViewController.h"

@protocol SPLoginDelegate <NSObject>

@required
- (void)loginSuccess;

@optional
- (void)loginFailed;

@end

@interface SPLoginController : SPBaseViewController

@property (nonatomic, assign) id<SPLoginDelegate> delegate;

+ (void)showLoginControllerWithSuccessBlock:(void (^)(void))successBlock
                                cancelBlock:(void (^)(void))cancelBlock;

@end
