//
//  SPPublishSizes.h
//  StandardizationPractice
//
//  Created by Baitianyu on 27/10/2016.
//  Copyright © 2016 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SPPublishSizes : NSObject

+ (CGFloat)previewLayerHeight;
+ (CGFloat)captureButtonLeftMargin;
+ (CGFloat)photoButtonRightMargin;
+ (CGFloat)previewButtonGap;
+ (CGFloat)buttonTitleGap;
+ (UIFont *)titleFont;
+ (CGFloat)editImageHeight;
+ (CGFloat)editImageCellVerticalMargin;
+ (CGFloat)editInputTextViewHeight;
+ (CGFloat)editPublishButtonTopMargin;
+ (CGFloat)editPublishButtonLeftMargin;
+ (UIFont *)editDescribeTextViewFont;
+ (CGFloat)editTitleTextViewGap;
+ (CGFloat)albumChooserCellHeight;
+ (CGSize)albumChooserThumbnailSize;
+ (UIFont *)albumChooserGroupNameFont;
+ (CGFloat)albumChooserThumbnailGroupGap;

@end
