//
//  HTModuleFormatter.h
//  HTCommonUtility
//
//  Created by NetEase on 15/9/2.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDLog.h"
@protocol DDLogFormatter;
/**
 *  处理HTLog添加的module功能
 *  使用[DDLogMessage]->_tag存储module名
 *  
 *  自定义log输入结果，使用DDLogMessage的属性拼接字符串
 */
@interface HTLogFormatter : NSObject <DDLogFormatter>

@end

