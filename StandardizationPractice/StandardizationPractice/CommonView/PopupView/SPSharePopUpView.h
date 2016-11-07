//
//  SPSharePopUpView.h
//  StandardizationPractice
//
//  Created by 陶泽宇 on 2016/10/27.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SPShareContentData :NSObject

@property(nonatomic, copy) NSString *title;
@property(nonatomic, strong) UIImage *image;
@property(nonatomic, strong) UIImage *imagePressed;

@end

@interface SPSharePopUpView : UIView

@property(nonatomic, strong)NSArray *contents;

+ (instancetype)sharedInstance;

- (void)show;

- (void)dismiss;

@end
