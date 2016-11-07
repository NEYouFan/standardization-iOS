//
//  SPThemeColors.m
//  StandardizationPractice
//
//  Created by Baitianyu on 18/10/2016.
//  Copyright © 2016 Netease. All rights reserved.
//

#import "SPThemeColors.h"
#import "ColorUtils.h"

@implementation SPThemeColors

+ (UIColor *)themeColor {
    return [UIColor colorWithRGBValue:0x607D8B];
}

+ (UIColor *)lineColor {
    return [UIColor colorWithRGBValue:0xCBCBCB];
}

+ (UIColor *)backgroundColor {
    return [UIColor whiteColor];
}

+ (UIColor *)lightTextColor {
    return [UIColor colorWithRGBValue:0x999999];
}

+ (UIColor *)lightTextColorClicked {
    return [UIColor colorWithRGBValue:0xbbbbbb];
}

+ (UIColor *)darkTextColor {
    return [UIColor blackColor];
}

+ (UIColor *)placeholderTextColor {
    return [UIColor colorWithRGBValue:0xDBDBDB];
}

+ (UIColor *)naviBackgroundColor {
    return [UIColor colorWithRGBValue:0x607d8b];
}

+ (UIColor *)buttonColor {
    return [UIColor colorWithRGBValue:0x607d8b];
}

+ (UIColor *)highlightButtonColor {
    return [UIColor colorWithRGBValue:0xBCCED7];
}

+ (UIColor *)naviForegroundColor {
    return [UIColor whiteColor];
}

+ (UIColor *)buttonTitleColor {
    return [UIColor whiteColor];
}



@end
