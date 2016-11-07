//
//  HTModalWindow.m
//  Pods
//
//  Created by jw-mbp on 9/1/15.
//
//

#import "HTModalWindow.h"

@implementation HTModalWindow
{
    HTModalWindow * __HTModalWindowHolder;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)show
{
    /**
     *  这里虽然会产生retain cycle 但是在hide的时候就会消失
     */
    __HTModalWindowHolder = self;
    [self makeKeyAndVisible];
    [self showAnimationWithCompletionBlock:nil];
}

- (void)hide
{
    [self hideAnimationWithCompletionBlock:^{
        __HTModalWindowHolder.hidden = YES;
        __HTModalWindowHolder = nil;
    }];
    
}

- (void)showAnimationWithCompletionBlock:(CompleteBlock)completeBlock
{
    if (completeBlock) {
        completeBlock();
    }
}

- (void)hideAnimationWithCompletionBlock:(CompleteBlock)completeBlock
{
    if (completeBlock) {
        completeBlock();
    }
}


@end
