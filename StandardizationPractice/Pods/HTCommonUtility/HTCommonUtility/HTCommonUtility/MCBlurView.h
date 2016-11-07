//
//  MCBlurView.h
//  NeteaseMusic
//
//  Created by Chengyin on 14-8-25.
//
//

#import <UIKit/UIKit.h>

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

#define isIOS8 SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")
#define isIOS7 SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")

typedef NS_ENUM(NSUInteger, MCBlurStyle)
{
    MCBlurStyleWhite,
    MCBlurStyleBlack,
};

@interface MCBlurView : UIView

@property (nonatomic,readonly) MCBlurStyle style;
@property (nonatomic,retain) UIColor *blurTintColor;
@property (nonatomic,retain) UIColor *unblurTintColor;

- (instancetype)initWithStyle:(MCBlurStyle)style;

@end
