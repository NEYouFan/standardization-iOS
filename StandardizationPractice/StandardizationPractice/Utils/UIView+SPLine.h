//
//  UIView+SPLine.h
//  StandardizationPractice
//
//  Created by Baitianyu on 18/10/2016.
//  Copyright © 2016 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (SPLine)

+ (instancetype)sp_line;

- (UIView *)sp_addBottomLineWithLeftMargin:(CGFloat)leftMargin rightMargin:(CGFloat)rightMargin;
- (UIView *)sp_addBottomLineWithLeftMargin:(CGFloat)leftMargin rightMargin:(CGFloat)rightMargin lineColor:(UIColor *)color;

- (UIView *)sp_addTopLineWithLeftMargin:(CGFloat)leftMargin rightMargin:(CGFloat)rightMargin;
- (UIView *)sp_addTopLineWithLeftMargin:(CGFloat)leftMargin rightOffset:(CGFloat)rightMargin lineColor:(UIColor *)color;

- (UIView *)sp_addVerticalMiddleLineWithTopMargin:(CGFloat)topMargin
                                     bottomMargin:(CGFloat)bottomMargin;
- (UIView *)sp_addVerticalHeadLineWithTopMargin:(CGFloat)topMargin
                                   bottomMargin:(CGFloat)bottomMargin;
- (UIView *)sp_addVerticalTailLineWithTopMargin:(CGFloat)topMargin
                                   bottomMargin:(CGFloat)bottomMargin;

- (UIView *)sp_addHorizontalMiddleLineWithLeftMargin:(CGFloat)leftMargin
                                         rightMargin:(CGFloat)rightMargin;
- (UIView *)sp_addHorizontalTopLineWithLeftMargin:(CGFloat)leftMargin
                                      rightMargin:(CGFloat)rightMargin;
- (UIView *)sp_addHorizontalBottomLineWithLeftMargin:(CGFloat)leftMargin
                                         rightMargin:(CGFloat)rightMargin;

- (void)sp_removeTopLine;
- (void)sp_removeBottomLine;

- (void)sp_removeHorizontalMiddleLine;
- (void)sp_removeHorizontalTopLine;
- (void)sp_removeHorizontalBottomLine;

- (void)sp_removeVerticalMiddleLine;
- (void)sp_removeVerticalHeadLine;
- (void)sp_removeVerticalTailLine;

@end
