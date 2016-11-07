//
//  UIView+SPToast.m
//  StandardizationPractice
//
//  Created by Baitianyu on 24/10/2016.
//  Copyright © 2016 Netease. All rights reserved.
//

#import "UIView+SPToast.h"
#import "UIView+HTToast.h"

@implementation UIView (SPToast)

- (void)sp_showToastWithMessage:(NSString *)message {
    [self makeToast:message duration:0.25 position:HTToastPositionCenter];
}

@end
