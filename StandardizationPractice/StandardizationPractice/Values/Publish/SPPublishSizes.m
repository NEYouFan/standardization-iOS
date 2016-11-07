//
//  SPPublishSizes.m
//  StandardizationPractice
//
//  Created by Baitianyu on 27/10/2016.
//  Copyright © 2016 Netease. All rights reserved.
//

#import "SPPublishSizes.h"

@implementation SPPublishSizes

+ (CGFloat)previewLayerHeight {
    return 350;
}

+ (CGFloat)captureButtonLeftMargin {
    return 72;
}

+ (CGFloat)photoButtonRightMargin {
    return 72;
}

+ (CGFloat)previewButtonGap {
    return 20;
}

+ (CGFloat)buttonTitleGap {
    return 7;
}

+ (UIFont *)titleFont {
    return [UIFont systemFontOfSize:16];
}

+ (CGFloat)editImageHeight {
    return 257;
}

+ (CGFloat)editImageCellVerticalMargin {
    return 23;
}

+ (CGFloat)editInputTextViewHeight {
    return 129;
}

+ (CGFloat)editPublishButtonTopMargin {
    return 20;
}

+ (CGFloat)editPublishButtonLeftMargin {
    return 62;
}

+ (UIFont *)editDescribeTextViewFont {
    return [UIFont systemFontOfSize:13];
}

+ (CGFloat)editTitleTextViewGap {
    return 15;
}

+ (CGFloat)albumChooserCellHeight {
    return 85;
}

+ (CGSize)albumChooserThumbnailSize {
    return CGSizeMake(65, 65);
}

+ (UIFont *)albumChooserGroupNameFont {
    return [UIFont systemFontOfSize:17];
}

+ (CGFloat)albumChooserThumbnailGroupGap {
    return 20;
}

@end
