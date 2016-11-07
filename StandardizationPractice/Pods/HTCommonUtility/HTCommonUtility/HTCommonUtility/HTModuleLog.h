//
//  HTModuleDogDemo.h
//  HTLogDemo
//
//  Created by 志强 on 15/10/12.
//  Copyright © 2015年 NetEase. All rights reserved.
//
#import "HTCommonLog.h"
/**
 *  模块日志打印 Module Plan A
 *
 *  基于CocoaLumberjack两个地方
 *  (1):DDLogFormatter协议提供的接口：
 *  - (NSString *)formatLogMessage:(DDLogMessage *)logMessage
 *  (2):DDLogMessage的_tag参数
 *  存在缺点：需要拼接字符串来输出'2015-10-13 00:22:14:029 HTLogDemo[71161:4592048]'这样的格式
 *
 *  该模块声明一条新的Log需要注意的内容包括：
 *  1.当前需要打印的log level，如LOG_LEVEL_COMMON
 *
 *  2.log module name,自定义的模块名，如nil
 *  会被打印在日志的开头，建议使用module做流程打印
 *
 *  3.log flag,用于和log level做按位与运算，返回为真时才会触发日志打印
 *  HTLog的文档https://git.hz.netease.com/hzzhangping/heartouch/blob/master/docs/%E6%97%A5%E5%BF%97/Lumberjack%E4%BD%BF%E7%94%A8%E6%89%8B%E5%86%8C.md
 */
#if DEBUG

#define LOG_LEVEL_MODULE1 DDLogLevelAll

#else

#define LOG_LEVEL_MODULE1 0

#endif

/*---------------log module name----------------*/
#define LOG_MODULE_MODULE1       @"Module1"


#define HTLogModule1Error(frmt, ...) \
__HTModuleLogConvert(NO,                LOG_LEVEL_MODULE1, DDLogFlagError, LOG_MODULE_MODULE1, frmt, ##__VA_ARGS__)

#define HTLogModule1Warn(frmt, ...) \
__HTModuleLogConvert(LOG_ASYNC_ENABLED, LOG_LEVEL_MODULE1, DDLogFlagWarning, LOG_MODULE_MODULE1, frmt, ##__VA_ARGS__)

#define HTLogModule1Info(frmt, ...) \
__HTModuleLogConvert(LOG_ASYNC_ENABLED, LOG_LEVEL_MODULE1, DDLogFlagInfo, LOG_MODULE_MODULE1, frmt, ##__VA_ARGS__)

#define HTLogModule1Debug(frmt, ...) \
__HTModuleLogConvert(LOG_ASYNC_ENABLED, LOG_LEVEL_MODULE1, DDLogFlagDebug, LOG_MODULE_MODULE1, frmt, ##__VA_ARGS__)

#define HTLogModule1Verbose(frmt, ...) \
__HTModuleLogConvert(LOG_ASYNC_ENABLED, LOG_LEVEL_MODULE1, DDLogFlagVerbose, LOG_MODULE_MODULE1, frmt, ##__VA_ARGS__)


