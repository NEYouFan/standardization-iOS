//
//  UIView+SPLine.m
//  StandardizationPractice
//
//  Created by Baitianyu on 18/10/2016.
//  Copyright © 2016 Netease. All rights reserved.
//

#import <objc/runtime.h>
#import "UIView+SPLine.h"
#import "UIImage+ImageWithColor.h"
#import "Masonry.h"
#import "UIView+Frame.h"

static char const *kTopLineKey;
static char const *kBottomLineKey;

static char const *kHorizontalMiddleLineKey;
static char const *kHorizontalTopLineKey;
static char const *kHorizontalBottomLineKey;

static char const *kVerticalMiddleLineKey;
static char const *kVerticalHeadLineKey;
static char const *kVerticalTailLineKey;

@implementation UIView (SPLine)

#pragma mark - Class methods.

+ (instancetype)sp_line {
    UIView *line = [[UIView alloc] init];
    line.frame = CGRectMake(0, 0, [SPThemeSizes lineWidth], [SPThemeSizes lineWidth]);
    line.backgroundColor = [SPThemeColors lineColor];
    return line;
}


#pragma mark - Bottom line.

- (UIView *)sp_addBottomLineWithLeftMargin:(CGFloat)leftMargin rightMargin:(CGFloat)rightMargin {
    UIView *line = [self sp_getCellLineByKey:&kBottomLineKey];
    [line removeFromSuperview];
    [self addSubview:line];
    
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self);
        make.left.equalTo(self).with.offset(leftMargin);
        make.right.equalTo(self).with.offset(-rightMargin);
        make.height.equalTo(@([SPThemeSizes lineWidth]));
    }];
    
    return line;
}

- (UIView *)sp_addBottomLineWithLeftMargin:(CGFloat)leftMargin
                               rightMargin:(CGFloat)rightMargin
                                 lineColor:(UIColor *)color {
    UIView *line = [self sp_getCellLineByKey:&kBottomLineKey];
    [line removeFromSuperview];
    [self addSubview:line];
    line.backgroundColor = color;
    
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self);
        make.left.equalTo(self).with.offset(leftMargin);
        make.right.equalTo(self).with.offset(-rightMargin);
        make.height.equalTo(@([SPThemeSizes lineWidth]));
    }];
    
    return line;
}

- (void)sp_removeBottomLine {
    UIView *line = [self sp_getCellLineByKey:&kBottomLineKey];
    [line removeFromSuperview];
}


#pragma mark - Top line.

- (UIView *)sp_addTopLineWithLeftMargin:(CGFloat)leftMargin rightMargin:(CGFloat)rightMargin {
    UIView *line = [self sp_getCellLineByKey:&kTopLineKey];
    [line removeFromSuperview];
    [self addSubview:line];
    
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.left.equalTo(self).with.offset(leftMargin);
        make.right.equalTo(self).with.offset(-rightMargin);
        make.height.equalTo(@([SPThemeSizes lineWidth]));
    }];
    
    return line;
}

- (UIView *)sp_addTopLineWithLeftMargin:(CGFloat)leftMargin
                            rightOffset:(CGFloat)rightMargin
                              lineColor:(UIColor *)color {
    UIView *line = [self sp_getCellLineByKey:&kTopLineKey];
    [line removeFromSuperview];
    [self addSubview:line];
    line.backgroundColor = color;
    
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.left.equalTo(self).with.offset(leftMargin);
        make.right.equalTo(self).with.offset(-rightMargin);
        make.height.equalTo(@([SPThemeSizes lineWidth]));
    }];
    
    return line;
}

- (void)sp_removeTopLine {
    UIView *line = [self sp_getCellLineByKey:&kTopLineKey];
    [line removeFromSuperview];
}


#pragma mark - Horizontal middle line.

- (UIView *)sp_addHorizontalTopLineWithLeftMargin:(CGFloat)leftMargin
                                      rightMargin:(CGFloat)rightMargin {
    UIView *line = [self sp_getCellLineByKey:&kHorizontalTopLineKey];
    [line removeFromSuperview];
    [self addSubview:line];
    
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.left.equalTo(self).with.offset(leftMargin);
        make.width.equalTo(self.mas_height).with.offset(-leftMargin-rightMargin);
        make.height.equalTo(@([SPThemeSizes lineWidth]));
    }];
    
    return line;
}

- (UIView *)sp_addHorizontalMiddleLineWithLeftMargin:(CGFloat)leftMargin
                                         rightMargin:(CGFloat)rightMargin {
    UIView *line = [self sp_getCellLineByKey:&kHorizontalMiddleLineKey];
    [line removeFromSuperview];
    [self addSubview:line];
    
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.left.equalTo(self).with.offset(leftMargin);
        make.right.equalTo(self).with.offset(-rightMargin);
        make.height.equalTo(@([SPThemeSizes lineWidth]));
    }];
    
    return line;
}

- (UIView *)sp_addHorizontalBottomLineWithLeftMargin:(CGFloat)leftMargin
                                         rightMargin:(CGFloat)rightMargin {
    UIView *line = [self sp_getCellLineByKey:&kHorizontalBottomLineKey];
    [line removeFromSuperview];
    [self addSubview:line];
    
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self);
        make.left.equalTo(self).with.offset(leftMargin);
        make.width.equalTo(self.mas_height).with.offset(-leftMargin-rightMargin);
        make.height.equalTo(@([SPThemeSizes lineWidth]));
    }];
    
    return line;
}

- (void)sp_removeHorizontalMiddleLine {
    UIView *line = [self sp_getCellLineByKey:&kHorizontalMiddleLineKey];
    [line removeFromSuperview];
}

- (void)sp_removeHorizontalTopLine {
    UIView *line = [self sp_getCellLineByKey:&kHorizontalTopLineKey];
    [line removeFromSuperview];
}

- (void)sp_removeHorizontalBottomLine {
    UIView *line = [self sp_getCellLineByKey:&kHorizontalBottomLineKey];
    [line removeFromSuperview];
}


#pragma mark - Vertical middle line.

- (UIView *)sp_addVerticalHeadLineWithTopMargin:(CGFloat)topMargin
                                   bottomMargin:(CGFloat)bottomMargin {
    UIView *line = [self sp_getCellLineByKey:&kVerticalHeadLineKey];
    [line removeFromSuperview];
    [self addSubview:line];
    
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.top.equalTo(self).with.offset(topMargin);
        make.height.equalTo(self.mas_height).with.offset(-bottomMargin-topMargin);
        make.width.equalTo(@([SPThemeSizes lineWidth]));
    }];
    
    return line;
}

- (UIView *)sp_addVerticalMiddleLineWithTopMargin:(CGFloat)topMargin
                                     bottomMargin:(CGFloat)bottomMargin {
    UIView *line = [self sp_getCellLineByKey:&kVerticalMiddleLineKey];
    [line removeFromSuperview];
    [self addSubview:line];
    
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self).with.offset(topMargin);
        make.height.equalTo(self.mas_height).with.offset(-bottomMargin-topMargin);
        make.width.equalTo(@([SPThemeSizes lineWidth]));
    }];
    
    return line;
}

- (UIView *)sp_addVerticalTailLineWithTopMargin:(CGFloat)topMargin
                                   bottomMargin:(CGFloat)bottomMargin {
    UIView *line = [self sp_getCellLineByKey:&kVerticalTailLineKey];
    [line removeFromSuperview];
    [self addSubview:line];
    
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self);
        make.top.equalTo(self).with.offset(topMargin);
        make.height.equalTo(self.mas_height).with.offset(-bottomMargin-topMargin);
        make.width.equalTo(@([SPThemeSizes lineWidth]));
    }];
    
    return line;
}

- (void)sp_removeVerticalMiddleLine {
    UIView *line = [self sp_getCellLineByKey:&kVerticalMiddleLineKey];
    [line removeFromSuperview];
}

- (void)sp_removeVerticalHeadLine {
    UIView *line = [self sp_getCellLineByKey:&kVerticalHeadLineKey];
    [line removeFromSuperview];
}

- (void)sp_removeVerticalTailLine {
    UIView *line = [self sp_getCellLineByKey:&kVerticalTailLineKey];
    [line removeFromSuperview];
}


#pragma mark - Private methods.

- (UIView *)sp_getCellLineByKey:(void *)key {
    UIView *line = objc_getAssociatedObject(self, key);
    if (!line) {
        line = [UIView sp_line];
        objc_setAssociatedObject(self, key, line, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return line;
}

@end
