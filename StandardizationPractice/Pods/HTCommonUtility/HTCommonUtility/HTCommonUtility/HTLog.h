//
//  HTCommonUtilityLog.h
//  HTCommonUtility
//
//  Created by NetEase on 15/9/2.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#ifndef HTCommonUtility_HTCommonUtilityLog_h
#define HTCommonUtility_HTCommonUtilityLog_h

#import "HTCommonLog.h"
#import "HTLogFormatter.h"
/**
 *  初始化Logger对象，启用HTLog
 *  DEBUG下，打开苹果日志和控制台日志
 *  RELEASE下，关闭苹果日志(NSLog)，打开控制台日志和文件日志,文件日志大小
 *  限制在1kb，最多4个文件，每1分钟保存一次，只保存error日志
 */
void HTLogInit();

////////////////////////////////////////////////////////////////
//Module Macro
////////////////////////////////////////////////////////////////
/**
 *  日志打印基于CocoaLumberjack
 *
 *  日志处理对象DDTTYLogger放在application的AppDelegate.m中初始化
 *
 *  该模块声明一条新的Log需要注意的内容包括：
 *  1.当前需要打印的log level，如LOG_LEVEL_COMMON
 *
 *  2.log module name,自定义的模块名，如LOG_MODULE_COMMON 
 *  会被打印在日志的开头，建议使用module做流程打印
 *
 *  3.log flag,用于和log level做按位与运算，返回为真时才会触发日志打印
 *  HTLog的文档https://git.hz.netease.com/hzzhangping/heartouch/blob/master/docs/%E6%97%A5%E5%BF%97/Lumberjack%E4%BD%BF%E7%94%A8%E6%89%8B%E5%86%8C.md
 */

/*---------------log level----------------*/

#if DEBUG

//默认关闭HTLog，防止影响用户的日志打印。
#define HT_LOG_LEVEL_COMMON  DDLogLevelOff

#else //

#define HT_LOG_LEVEL_COMMON 0

#endif //

/*---------------custom log declare----------------*/
#define HTLogError(frmt, ...)   HT_LOG_MAYBE(NO,                HT_LOG_LEVEL_COMMON, DDLogFlagError,   0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define HTLogWarn(frmt, ...)    HT_LOG_MAYBE(LOG_ASYNC_ENABLED, HT_LOG_LEVEL_COMMON, DDLogFlagWarning, 0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define HTLogInfo(frmt, ...)    HT_LOG_MAYBE(LOG_ASYNC_ENABLED, HT_LOG_LEVEL_COMMON, DDLogFlagInfo,    0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define HTLogDebug(frmt, ...)   HT_LOG_MAYBE(LOG_ASYNC_ENABLED, HT_LOG_LEVEL_COMMON, DDLogFlagDebug,   0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define HTLogVerbose(frmt, ...) HT_LOG_MAYBE(LOG_ASYNC_ENABLED, HT_LOG_LEVEL_COMMON, DDLogFlagVerbose, 0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#endif
