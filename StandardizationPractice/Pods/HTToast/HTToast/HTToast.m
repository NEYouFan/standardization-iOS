//
//  HTToast.m
//  Pods
//
//  Created by cxq on 15/9/1.
//
//

#import "HTToast.h"

@implementation HTToast

+ (void)showToastWithMessage:(NSString *)message
{
    [self showToastWithMessage:message duration:3 position:HTToastPositionCenter];
}

+ (void)showToastWithView:(UIView *)toast
{
    [self showToastWithView:toast duration:3 position:HTToastPositionCenter];
}

+ (void)showToastWithMessage:(NSString *)message duration:(NSTimeInterval)duration
{
    [self showToastWithMessage:message duration:duration position:HTToastPositionCenter];
}

+ (void)showToastWithView:(UIView *)toast duration:(NSTimeInterval)duration
{
    [self showToastWithView:toast duration:duration position:HTToastPositionCenter];
}

+ (void)showToastWithMessage:(NSString *)message duration:(NSTimeInterval)duration position:(id)position
{
    [[[UIApplication sharedApplication] keyWindow] makeToast:message duration:duration position:position title:nil image:nil];
}

+ (void)showToastWithView:(UIView *)toast duration:(NSTimeInterval)duration position:(id)position
{
    [[[UIApplication sharedApplication] keyWindow] showToast:toast duration:duration position:position];
}


@end
