//
//  HTCommonUtility.h
//  HTCommonUtility
//
//  Created by NetEase on 15/9/1.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HTCommonUtility : NSObject

/**
 *  设置指定路径的文件不备份到iCloud.
 *
 *  @param path 文件路径
 */
+ (void)addDoNotBackupAttribute:(NSString *)path;

/**
 *  计算md5值
 *
 *  @param string 计算结果
 *
 *  @return 传入的字符串
 */
+ (NSString *)md5StringFromString:(NSString *)string;

/**
 *  应用版本号
 *
 *  @return 应用版本号
 */
+ (NSString *)appVersionString;

@end
