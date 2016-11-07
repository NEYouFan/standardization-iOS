//
//  SPThemeSizes.m
//  StandardizationPractice
//
//  Created by Baitianyu on 18/10/2016.
//  Copyright © 2016 Netease. All rights reserved.
//

#import "SPThemeSizes.h"

CGFloat const kStatusBarHeight = 20;
CGFloat const kNavigationBarHeight = 44;
CGFloat const kTabBarHeight = 49;
CGFloat const kSegmentsViewHeight = 49;
CGFloat const kRefreshViewHeight = 62;
CGFloat const kLoadMoreViewHeight = 62;
CGFloat const kTableViewFooterHeight = 40;
CGFloat const kTableViewHeaderHeight = 13;
CGFloat const kLeftMargin = 12;
CGFloat const kRightMargin = 12;
CGFloat const kLeftMargin35 = 35;
CGFloat const kRightMargin35 = 35;
CGFloat const kTopMargin = 15;
CGFloat const kBottomMargin = 15;
CGFloat const kSearchTopMargin = 10;
CGFloat const kSearchBottomMargin = 10;

@implementation SPThemeSizes

+ (CGFloat)screenHeight {
    return [UIScreen mainScreen].bounds.size.height;
}

+ (CGFloat)screenWidth {
    return [UIScreen mainScreen].bounds.size.width;
}

+ (CGSize)screenSize {
    return [UIScreen mainScreen].bounds.size;
}

+ (CGFloat)lineWidth {
    return 1.0/[UIScreen mainScreen].scale;
}

+ (CGFloat)cellGap {
    return 10.0;
}

+ (CGFloat)leftMargin {
    return 10;
}

+ (CGFloat)rightMargin {
    return 10;
}

+ (CGFloat)cornerRadiusSize {
    return 2;
}

+ (UIFont *)naviTitleFont {
    return [UIFont systemFontOfSize:18];
}

+ (CGFloat)titleIconGap {
    return 10;
}

+ (UIFont *)refreshingIndicateFont {
    return [UIFont systemFontOfSize:16];
}

@end
