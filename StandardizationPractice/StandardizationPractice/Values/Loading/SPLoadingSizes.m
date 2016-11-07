//
//  SPLoadingSizes.m
//  StandardizationPractice
//
//  Created by Baitianyu on 21/10/2016.
//  Copyright © 2016 Netease. All rights reserved.
//

#import "SPLoadingSizes.h"

@implementation SPLoadingSizes

+ (UIFont *)loadingIndicateFont {
    return [UIFont systemFontOfSize:16];
}

+ (CGFloat)titleReloadButtonGap {
    return 26;
}

+ (CGSize)reloadButtonSize {
    return CGSizeMake(122, 31);
}

+ (CGFloat)refreshingIconLabelGap {
    return 5;
}

@end
