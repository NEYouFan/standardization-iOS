//
//  UINavigationBar+HT.m
//  CustomNavigationBar
//
//  Created by zp on 15/8/4.
//  Copyright (c) 2015年 zp. All rights reserved.
//

#import "UINavigationBar+HT.h"
#import "UIImage+ImageWithColor.h"
@implementation UINavigationBar (HT)

#pragma mark - bg color
- (UIView*)ht_getBackgroundView
{
   return (UIView*)self.subviews.firstObject;
}

- (void)ht_setBackgroundColor:(UIColor*)color
{
   //这里必须设置为透明的图，设置为nil也不起作用
   [self setBackgroundImage:[UIImage imageWithColor:[UIColor clearColor] size:CGSizeMake(1, 1)] forBarMetrics:UIBarMetricsDefault];
   
   UIView *bgView = [self ht_getBackgroundView];
   bgView.backgroundColor = color;
}

#pragma mark - shadow view
- (void)ht_hideShadowImage:(BOOL)bHidden
{
   UIView *bgView = [self ht_getBackgroundView];
   UIView *lineView = bgView.subviews.lastObject;
   if (CGRectGetHeight(lineView.frame) <= 1)
   {
      lineView.hidden = bHidden;
   }
}

@end
