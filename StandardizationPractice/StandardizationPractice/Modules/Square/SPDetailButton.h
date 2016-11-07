//
//  SPDetailBotton.h
//  StandardizationPractice
//
//  Created by 陶泽宇 on 2016/10/24.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SPDetailButton : UIButton

+ (instancetype)buttonWithType:(UIButtonType)buttonType title:(NSString *)title;

@property (nonatomic, strong) UIImageView *icon;
@property (nonatomic, strong) UILabel *titleLab;

@end
