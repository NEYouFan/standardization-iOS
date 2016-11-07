//
//  SPThemeSizes.h
//  StandardizationPractice
//
//  Created by Baitianyu on 18/10/2016.
//  Copyright © 2016 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

extern CGFloat const kStatusBarHeight;
extern CGFloat const kNavigationBarHeight;
extern CGFloat const kTabBarHeight;
extern CGFloat const kSegmentsViewHeight;
extern CGFloat const kRefreshViewHeight;
extern CGFloat const kLoadMoreViewHeight;
extern CGFloat const kTableViewFooterHeight;
extern CGFloat const kTableViewHeaderHeight;
extern CGFloat const kLeftMargin;
extern CGFloat const kRightMargin;
extern CGFloat const kLeftMargin35;
extern CGFloat const kRightMargin35;
extern CGFloat const kTopMargin;
extern CGFloat const kBottomMargin;
extern CGFloat const kSearchTopMargin;
extern CGFloat const kSearchBottomMargin;

@interface SPThemeSizes : NSObject

+ (CGFloat)screenHeight;
+ (CGFloat)screenWidth;
+ (CGSize)screenSize;
+ (CGFloat)lineWidth;
+ (CGFloat)cellGap;
+ (CGFloat)leftMargin;
+ (CGFloat)rightMargin;
+ (CGFloat)cornerRadiusSize;
+ (UIFont *)naviTitleFont;
+ (CGFloat)titleIconGap;
+ (UIFont *)refreshingIndicateFont;

@end
