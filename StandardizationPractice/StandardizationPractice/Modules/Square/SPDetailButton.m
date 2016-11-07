//
//  SPDetailBotton.m
//  StandardizationPractice
//
//  Created by 陶泽宇 on 2016/10/24.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import "SPDetailButton.h"
#import "SPThemeColors.h"
#import "SPSquareSizes.h"
#import <HTCommonUtility/UIView+Frame.h>
#import "Masonry.h"

@interface SPDetailButton ()


@end

@implementation SPDetailButton

+ (instancetype)buttonWithType:(UIButtonType)buttonType title:(NSString *)title{
    SPDetailButton * button = [SPDetailButton buttonWithType:buttonType];
    
    button.icon = [[UIImageView alloc] init];
    button.icon.y = 17;
    button.icon.x = button.x;
    button.icon.width = 16;
    button.icon.height =16;
    [button addSubview:button.icon];
    
    button.titleLab = [[UILabel alloc] init];
    button.titleLab.textAlignment = NSTextAlignmentLeft;
    button.titleLab.font = [SPSquareSizes detailButtonTextFont];
    button.titleLab.textColor = [SPThemeColors lightTextColor];
    button.titleLab.text = title;
    [button addSubview:button.titleLab];
    [button.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(button);
        make.bottom.equalTo(button);
        make.left.equalTo(button).with.offset(16+10);
        make.right.equalTo(button);
    }];
    
    return button;
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    self.titleLab.textColor = [SPThemeColors lightTextColorClicked];
    return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    self.titleLab.textColor = [SPThemeColors lightTextColor];
}

@end
