//
//  SPMineSizes.m
//  StandardizationPractice
//
//  Created by Baitianyu on 19/10/2016.
//  Copyright © 2016 Netease. All rights reserved.
//

#import "SPMineSizes.h"

@implementation SPMineSizes

+ (UIFont *)mineTitleFont {
    return [UIFont systemFontOfSize:15];
}

+ (UIFont *)userNameFont {
    return [UIFont systemFontOfSize:13];
}

+ (CGFloat)headerIconWidth {
    return 69;
}

+ (CGSize)loginButtonSize {
    return CGSizeMake(130, 45);
}

+ (CGSize)logoutButtonSize {
    return CGSizeMake(214, 35);
}

+ (UIFont *)feedbackIndicationFont {
    return [UIFont systemFontOfSize:13];
}

+ (CGFloat)indicationTopMargin {
    return 20;
}

+ (CGFloat)textViewTopMargin {
    return 43;
}

+ (CGFloat)textViewHeight {
    return 134;
}

+ (CGFloat)textViewSendButtonGap {
    return 38;
}

+ (UIFont *)feedbackTextViewFont {
    return [UIFont systemFontOfSize:13];
}

@end
