//
//  UIView+HTToast.m
//  Toast
//
//  Copyright 2014 Charles Scalesse.
//


#import "UIView+HTToast.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

/*
 *  CONFIGURE THESE VALUES TO ADJUST LOOK & FEEL,
 *  DISPLAY DURATION, ETC.
 */

// associative reference keys
static const NSString * HTToastTimerKey         = @"HTToastTimerKey";
static const NSString * HTToastActivityViewKey  = @"HTToastActivityViewKey";
static const NSString * HTToastTapCallbackKey   = @"HTToastTapCallbackKey";
static const NSString * HTToastShowAnimationKey = @"HTToastShowAnimationKey";
static const NSString * HTToastHideAnimationKey = @"HTToastHideAnimationKey";
// positions
NSString * const HTToastPositionTop             = @"top";
NSString * const HTToastPositionCenter          = @"center";
NSString * const HTToastPositionBottom          = @"bottom";



@interface UIView (ToastPrivate)

- (void)toastTimerDidFinish:(NSTimer *)timer;
- (void)handleToastTapped:(UITapGestureRecognizer *)recognizer;
- (CGPoint)centerPointForPosition:(id)position withToast:(UIView *)toast;
- (UIView *)viewForMessage:(NSString *)message title:(NSString *)title image:(UIImage *)image;
- (CGSize)sizeForString:(NSString *)string font:(UIFont *)font constrainedToSize:(CGSize)constrainedSize lineBreakMode:(NSLineBreakMode)lineBreakMode;

@end


@implementation UIView (HTToast)

#pragma mark - Toast Methods

- (void)makeToast:(NSString *)message
{
    [self makeToast:message duration:3.0 position:nil title:nil image:nil];
}

- (void)makeToast:(NSString *)message duration:(NSTimeInterval)duration position:(id)position
{
    [self makeToast:message duration:duration position:position title:nil image:nil];
}

- (void)makeToast:(NSString *)message duration:(NSTimeInterval)duration position:(id)position title:(NSString *)title
{
    [self makeToast:message duration:duration position:position title:title image:nil];
}

- (void)makeToast:(NSString *)message duration:(NSTimeInterval)duration position:(id)position image:(UIImage *)image
{
    [self makeToast:message duration:duration position:position title:nil image:image];
}

- (void)makeToast:(NSString *)message duration:(NSTimeInterval)duration  position:(id)position title:(NSString *)title image:(UIImage *)image
{
    UIView *toast = [self viewForMessage:message title:title image:image];
    [self showToast:toast duration:duration position:position];
}

- (void)showToast:(UIView *)toast
{
    [self showToast:toast duration:3.0 position:nil];
}


- (void)showToast:(UIView *)toast duration:(NSTimeInterval)duration position:(id)position
{
    [self showToast:toast duration:duration position:position tapCallback:nil];
}


- (void)showToast:(UIView *)toast duration:(NSTimeInterval)duration position:(id)position
      tapCallback:(void(^)(void))tapCallback
{
    /**
     *  传递默认动画的block
     */
    [self showToast:toast position:position showWithAnimationBlock:^(UIView *view, UIView *toast) {
        toast.alpha = 0;
        [UIView animateWithDuration:0.4
                              delay:0.0
                            options:(UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction)
                         animations:^{
                             toast.alpha = 1.0;
                         } completion:^(BOOL finished) {
                             NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:duration target:self selector:@selector(toastTimerDidFinish:) userInfo:toast repeats:NO];
                             // associate the timer with the toast view
                             objc_setAssociatedObject (toast, &HTToastTimerKey, timer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                             objc_setAssociatedObject (toast, &HTToastTapCallbackKey, tapCallback, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                         }];
    } hideWithAnimationBlock:^(UIView *view, UIView *toast) {
        
        [UIView animateWithDuration:0.4
                              delay:0.0
                            options:(UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState)
                         animations:^{
                             toast.alpha = 0.0;
                         } completion:^(BOOL finished) {
                             [toast removeFromSuperview];
                         }];
    }];
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:toast action:@selector(handleToastTapped:)];
    [toast addGestureRecognizer:recognizer];
    toast.userInteractionEnabled = YES;
    toast.exclusiveTouch = YES;
    
}

#pragma mark - custom  make animation
- (void)makeToast:(NSString *)message showWithAnimationBlock:(animationBlock)showAnimationBlock hideWithAnimationBlock:(animationBlock)hideAnimationBlock
{
    [self makeToast:message position:nil image:nil title:nil showWithAnimationBlock:showAnimationBlock hideWithAnimationBlock:hideAnimationBlock];
}

- (void)makeToast:(NSString *)message position:(id)position showWithAnimationBlock:(animationBlock)showAnimationBlock hideWithAnimationBlock:(animationBlock)hideAnimationBlock
{
    [self makeToast:message position:position image:nil title:nil showWithAnimationBlock:showAnimationBlock hideWithAnimationBlock:hideAnimationBlock];
}
- (void)makeToast:(NSString *)message position:(id)position title:(NSString *)title showWithAnimationBlock:(animationBlock)showAnimationBlock hideWithAnimationBlock:(animationBlock)hideAnimationBlock
{
    [self makeToast:message position:position image:nil title:title showWithAnimationBlock:showAnimationBlock hideWithAnimationBlock:hideAnimationBlock];
}

- (void)makeToast:(NSString *)message position:(id)position image:(UIImage *)image showWithAnimationBlock:(animationBlock)showAnimationBlock hideWithAnimationBlock:(animationBlock)hideAnimationBlock
{
    [self makeToast:message position:position image:image title:nil showWithAnimationBlock:showAnimationBlock hideWithAnimationBlock:hideAnimationBlock];
}

- (void)makeToast:(NSString *)message position:(id)position image:(UIImage *)image title:(NSString *)title showWithAnimationBlock:(animationBlock)showAnimationBlock hideWithAnimationBlock:(animationBlock)hideAnimationBlock
{
    UIView *toast = [self viewForMessage:message title:title image:image];
    [self showToast:toast position:position showWithAnimationBlock:showAnimationBlock hideWithAnimationBlock:hideAnimationBlock];
}

#pragma mark - show toast

- (void)showToast:(UIView *)toast showWithAnimationBlock:(animationBlock)showAnimationBlock hideWithAnimationBlock:(animationBlock)hideAnimationBlock
{
    [self showToast:toast position:HTToastPositionCenter showWithAnimationBlock:showAnimationBlock hideWithAnimationBlock:hideAnimationBlock];
}

- (void)showToast:(UIView *)toast position:(id)position showWithAnimationBlock:(animationBlock)showAnimationBlock hideWithAnimationBlock:(animationBlock)hideAnimationBlock
{
    toast.center = [self centerPointForPosition:position withToast:toast];
    [self addSubview:toast];
    showAnimationBlock(self, toast);
    /**
     *  存储hide动画。在(void)hideToast:(UIView *)toast调用
     */
    objc_setAssociatedObject(toast, &HTToastHideAnimationKey, hideAnimationBlock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}



#pragma mark - custom hide toast

- (void)hideToast:(UIView *)toast
{
    animationBlock hideBlock = objc_getAssociatedObject(toast, &HTToastHideAnimationKey);
    if (hideBlock) {
        hideBlock(self,toast);
    }
}


#pragma mark - Events

- (void)toastTimerDidFinish:(NSTimer *)timer {
    [self hideToast:(UIView *)timer.userInfo];
}

- (void)handleToastTapped:(UITapGestureRecognizer *)recognizer {
    NSTimer *timer = (NSTimer *)objc_getAssociatedObject(self, &HTToastTimerKey);
    [timer invalidate];
    
    void (^callback)(void) = objc_getAssociatedObject(self, &HTToastTapCallbackKey);
    if (callback) {
        callback();
    }
    [self hideToast:recognizer.view];
}

#pragma mark - Toast Activity Methods

- (void)makeToastActivity
{
    [self makeToastActivityWithMessage:nil position:@"center"];
}

- (void)makeToastActivityWithMessage:(NSString *)message
{
    [self makeToastActivityWithMessage:message position:@"center"];
}

- (void)makeToastActivityWithMessage:(NSString *)message position:(id)position
{
    // sanity
    UIView *existingActivityView = (UIView *)objc_getAssociatedObject(self, &HTToastActivityViewKey);
    if (existingActivityView != nil) return;
    UIActivityIndicatorView *activityIndicatorView;
    UIView *activityView;
    
    if (message){
        UILabel *messageLabel = [[UILabel alloc] init];
        messageLabel.text = message;
        messageLabel.textColor = [UIColor whiteColor];
        [messageLabel sizeToFit];
        activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        activityView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2*activityIndicatorView.bounds.size.width+messageLabel.bounds.size.width + activityIndicatorView.bounds.size.width/2,80)];
        
        activityIndicatorView.center = CGPointMake(activityIndicatorView.bounds.size.width, activityView.bounds.size.height / 2);;
        messageLabel.center = CGPointMake(activityIndicatorView.bounds.size.width*2 + messageLabel.bounds.size.width/2, activityView.bounds.size.height / 2);
        [activityView addSubview:messageLabel];
    }else{
        activityView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
        activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        activityIndicatorView.center = CGPointMake(activityView.bounds.size.width/2, activityView.bounds.size.height / 2);
    }
    activityView.center = [self centerPointForPosition:position withToast:activityView];
    
    activityView.backgroundColor = [[UIColor clearColor] colorWithAlphaComponent:0.8];
    activityView.alpha = 0.0;
    activityView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
    activityView.layer.cornerRadius = 10;
    
    
    [activityView addSubview:activityIndicatorView];
    [activityIndicatorView startAnimating];
    
    // associate the activity view with self
    objc_setAssociatedObject (self, &HTToastActivityViewKey, activityView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self addSubview:activityView];
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         activityView.alpha = 1.0;
                     } completion:nil];
}

- (void)hideToastActivity
{
    UIView *existingActivityView = (UIView *)objc_getAssociatedObject(self, &HTToastActivityViewKey);
    if (existingActivityView != nil) {
        [UIView animateWithDuration:0.4
                              delay:0.0
                            options:(UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState)
                         animations:^{
                             existingActivityView.alpha = 0.0;
                         } completion:^(BOOL finished) {
                             [existingActivityView removeFromSuperview];
                             objc_setAssociatedObject (self, &HTToastActivityViewKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                         }];
    }
}

#pragma mark - Helpers

- (CGPoint)centerPointForPosition:(id)point withToast:(UIView *)toast
{
    if([point isKindOfClass:[NSString class]]) {
        if([point caseInsensitiveCompare:HTToastPositionTop] == NSOrderedSame) {
            return CGPointMake(self.bounds.size.width/2, (toast.frame.size.height / 2) + 10);
        } else if([point caseInsensitiveCompare:HTToastPositionCenter] == NSOrderedSame) {
            return CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
        }
    } else if ([point isKindOfClass:[NSValue class]]) {
        return [point CGPointValue];
    }
    
    // default to bottom
    return CGPointMake(self.bounds.size.width/2, (self.bounds.size.height - (toast.frame.size.height / 2)) - 10);
}

- (CGSize)sizeForString:(NSString *)string font:(UIFont *)font constrainedToSize:(CGSize)constrainedSize lineBreakMode:(NSLineBreakMode)lineBreakMode
{
    if ([string respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineBreakMode = lineBreakMode;
        NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle};
        CGRect boundingRect = [string boundingRectWithSize:constrainedSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
        return CGSizeMake(ceilf(boundingRect.size.width), ceilf(boundingRect.size.height));
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return [string sizeWithFont:font constrainedToSize:constrainedSize lineBreakMode:lineBreakMode];
#pragma clang diagnostic pop
}


/**
 *  用来创建默认的toast
 *
 *  @param message 文本信息
 *  @param title   标题信息
 *  @param image   图片信息
 *
 *  @return 返回创建后的toast
 */
- (UIView *)viewForMessage:(NSString *)message title:(NSString *)title image:(UIImage *)image
{
    // sanity
    if((message == nil) && (title == nil) && (image == nil)) return nil;
    // dynamically build a toast view with any combination of message, title, & image.
    UILabel *messageLabel = nil;
    UILabel *titleLabel = nil;
    UIImageView *imageView = nil;
    
    // create the parent view
    UIView *wrapperView = [[UIView alloc] init];
    wrapperView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
    wrapperView.layer.cornerRadius = 10;
    
    wrapperView.backgroundColor = [[UIColor blackColor]
                                   colorWithAlphaComponent:0.8];
    
    if(image != nil) {
        imageView = [[UIImageView alloc] initWithImage:image];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.frame = CGRectMake(10, 10, 80, 80);
    }
    
    CGFloat imageWidth, imageHeight, imageLeft;
    
    // the imageView frame values will be used to size & position the other views
    if(imageView != nil) {
        imageWidth = imageView.bounds.size.width;
        imageHeight = imageView.bounds.size.height;
        imageLeft = 10;
    } else {
        imageWidth = imageHeight = imageLeft = 0.0;
    }
    
    if (title != nil) {
        titleLabel = [[UILabel alloc] init];
        titleLabel.numberOfLines = 0;
        titleLabel.font = [UIFont boldSystemFontOfSize:16];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.alpha = 1.0;
        titleLabel.text = title;
        
        // size the title label according to the length of the text
        CGSize maxSizeTitle = CGSizeMake((self.bounds.size.width * 0.8) - imageWidth, self.bounds.size.height * 0.8);
        CGSize expectedSizeTitle = [self sizeForString:title font:titleLabel.font constrainedToSize:maxSizeTitle lineBreakMode:titleLabel.lineBreakMode];
        titleLabel.frame = CGRectMake(0.0, 0.0, expectedSizeTitle.width, expectedSizeTitle.height);
    }
    
    if (message != nil) {
        messageLabel = [[UILabel alloc] init];
        messageLabel.numberOfLines = 0;
        messageLabel.font = [UIFont systemFontOfSize:16];
        messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
        messageLabel.textColor = [UIColor whiteColor];
        messageLabel.backgroundColor = [UIColor clearColor];
        messageLabel.alpha = 1.0;
        messageLabel.text = message;
        
        // size the message label according to the length of the text
        CGSize maxSizeMessage = CGSizeMake((self.bounds.size.width * 0.8) - imageWidth, self.bounds.size.height * 0.8);
        CGSize expectedSizeMessage = [self sizeForString:message font:messageLabel.font constrainedToSize:maxSizeMessage lineBreakMode:messageLabel.lineBreakMode];
        messageLabel.frame = CGRectMake(0.0, 0.0, expectedSizeMessage.width, expectedSizeMessage.height);
    }
    
    // titleLabel frame values
    CGFloat titleWidth, titleHeight, titleTop, titleLeft;
    
    if(titleLabel != nil) {
        titleWidth = titleLabel.bounds.size.width;
        titleHeight = titleLabel.bounds.size.height;
        titleTop = 10;
        titleLeft = imageLeft + imageWidth + 10;
    } else {
        titleWidth = titleHeight = titleTop = titleLeft = 0.0;
    }
    
    // messageLabel frame values
    CGFloat messageWidth, messageHeight, messageLeft, messageTop;
    
    if(messageLabel != nil) {
        messageWidth = messageLabel.bounds.size.width;
        messageHeight = messageLabel.bounds.size.height;
        messageLeft = imageLeft + imageWidth + 10;
        messageTop = titleTop + titleHeight + 10;
    } else {
        messageWidth = messageHeight = messageLeft = messageTop = 0.0;
    }
    
    
    CGFloat longerWidth = MAX(titleWidth, messageWidth);
    CGFloat longerLeft = MAX(titleLeft, messageLeft);
    
    // wrapper width uses the longerWidth or the image width, whatever is larger. same logic applies to the wrapper height
    CGFloat wrapperWidth = MAX((imageWidth + (10 * 2)), (longerLeft + longerWidth + 10));
    CGFloat wrapperHeight = MAX((messageTop + messageHeight + 10), (imageHeight + (10 * 2)));
    
    wrapperView.frame = CGRectMake(0.0, 0.0, wrapperWidth, wrapperHeight);
    
    if(titleLabel != nil) {
        titleLabel.frame = CGRectMake(titleLeft, titleTop, titleWidth, titleHeight);
        [wrapperView addSubview:titleLabel];
    }
    
    if(messageLabel != nil) {
        messageLabel.frame = CGRectMake(messageLeft, messageTop, messageWidth, messageHeight);
        [wrapperView addSubview:messageLabel];
        /**
         *  使得图文出现时居中显示（原本为显示在右上角文字，若有title则按原来规则）
         */
        if (imageView != nil && titleLabel == nil) {
            messageLabel.center = CGPointMake(messageLabel.center.x, wrapperHeight/2);
        }
    }
    
    if(imageView != nil) {
        [wrapperView addSubview:imageView];
    }
    
    return wrapperView;
}

@end



