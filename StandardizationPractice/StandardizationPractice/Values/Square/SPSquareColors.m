//
//  SPSquareColors.m
//  StandardizationPractice
//
//  Created by 陶泽宇 on 2016/10/27.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import "SPSquareColors.h"
#import <HTCommonUtility/ColorUtils.h>

@implementation SPSquareColors

+ (UIColor *)titleLabelTextColor{
    return [UIColor colorWithRGBValue:0xffffff];
}

+ (UIColor *)numberLabelTextColor{
    return [UIColor colorWithRGBValue:0xfeae53];
}

+ (UIColor *)locationLabelTextColor{
    return [UIColor colorWithRGBValue:0xacacac];
}

+ (UIColor *)userNameColor{
    return [UIColor colorWithRGBValue:0xACACAC];
}

+ (UIColor *)detailTextColor{
    return [UIColor colorWithRGBValue:0x999999];
}


+ (UIColor *)squareBackgroundColor{
    return [UIColor colorWithRGBValue:0xe7e7e7];
}

+ (UIColor *)cellSelectedColor{
    return [UIColor colorWithRGBValue:0x000000 alpha:0.3];
}



@end
