//
//  HTImageView.h
//  HTImageView
//
//  Created by cxq on 15/7/14.
//  Copyright (c) 2015年 cxq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDWebImageManager.h"
#import "SDWebImageDownloader.h"
#import "UIImageView+WebCache.h"

@interface HTImageView : UIImageView

@property (nonatomic, getter=isImages) BOOL isImages;
@property (nonatomic, getter=isAutoPlay) BOOL autoPlay;
@property (nonatomic, assign) BOOL fadeInWithCacheTypeDisk;

/**
 *  遮罩效果所使用的Layer
 */
@property (nonatomic, strong) CALayer *maskLayer;

/**
 *  设置图片默认图和加载错误显示的图片
 *
 *  @param normalMode       UIViewContentMode类型，默认为UIViewContentModeScaleToFill
 *  @param placeHodlerImage 默认图片
 *  @param placeHolderMode  默认图片Mode类型,默认为UIViewContentModeCenter
 *  @param errorImage       加载错误显示图片
 *  @param errorMode        加载错误显示图片Mode类型,默认为UIViewContentModeCenter
 */
- (void)setNormalImageContentMode:(UIViewContentMode)normalMode
                 placeHodlerImage:(UIImage *)placeHodlerImage
                      contentMode:(UIViewContentMode)placeHolderMode
                       errorImage:(UIImage *)errorImage
                      contentMode:(UIViewContentMode)errorMode;

/**
 *  图片的渐现效果
 *
 *  @param fadeInEnable   是否渐现的标志
 *  @param duartion 渐现动画持续时间
 */
- (void)setFadeInAnimationEnable:(BOOL)fadeInEnable duration:(NSTimeInterval)duartion;

/**
 *  设置是否有遮罩
 *
 *  @param color  遮罩的颜色
 *  @param radius 遮罩的圆角半径
 *
 *  @return 返回遮罩的Layer
 */
- (void)setMaskLayerColor:(UIColor *)color radius:(NSUInteger)radius;

/**
 *  设置图片，通过URL，其它属性为默认属性
 *
 *  @param url
 */
- (void)setImageWithUrl:(NSURL *)url;

/**
 *  通过url设置图片，完成后进行数据处理
 *
 *  @param url            获取图片的url地址
 *  @param completedBlock 下载完成后进行的处理
 */
- (void)setImageWithUrl:(NSURL *)url completed:(SDWebImageCompletionBlock)completedBlock;

/**
 *  设置图片，通过URL，同时设置SDWebImageOptions属性
 *
 *  @param url
 *  @param option 用来选择图片下载方式
 */
- (void)setImageWithUrl:(NSURL *)url
                options:(SDWebImageOptions)option;

/**
 *  设置图片，通过URL,同时设置SDWebImageOptions属性,完成后回调completedBlock
 *
 *  @param url
 *  @param option         用来选择图片下载方式
 *  @param completedBlock 用来处理下载完成后的事件
 */
- (void)setImageWithUrl:(NSURL *)url
                options:(SDWebImageOptions)option
              completed:(SDWebImageCompletionBlock)completedBlock;

/**
 *  设置图片，通过URL,同时设置SDWebImageOptions属性,完成后回调completedBlock,并且可以获取进度
 *
 *  @param url
 *  @param option         用来选择图片下载方式
 *  @param progressBlock  进度回调，进行数据处理
 *  @param completedBlock 用来处理下载完成后的事件
 */
- (void)setImageWithUrl:(NSURL *)url
                options:(SDWebImageOptions)option
               progress:(SDWebImageDownloaderProgressBlock)progressBlock
              completed:(SDWebImageCompletionBlock)completedBlock;

/**
 *  清除图片渐现动画效果
 *
 *  @param imageView
 */
- (void)removeFadeInAnimation;

/**
 *  设置GIF自动循环播放次数
 *
 *  @param autoRepeatCount 自动播放次数
 */
- (void)setAutoRepeatCount:(NSUInteger)autoRepeatCount;

/**
 *  设置GIF图是否自动开始播放
 *
 *  @param autoPlay 布尔值
 */
- (void)setAutoPlay:(BOOL)autoPlay;


@end
