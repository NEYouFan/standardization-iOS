//
//  HTHttpLog.h
//  HTHttp
//
//  Created by NetEase on 15/9/2.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#ifndef HTHttp_HTHttpLog_h
#define HTHttp_HTHttpLog_h

#import "CocoaLumberjack.h"

////////////////////////////////////////////////////////////////
//Module Macro
////////////////////////////////////////////////////////////////
#if DEBUG

#define LOG_LEVEL_HTTP  DDLogLevelAll

#else

#define LOG_LEVEL_HTTP DDLogLevelOff

#endif

#define LOG_MODULE_HTTP       @"HTHTTPModule"

#define LOG_MACR(isAsynchronous, lvl, flg, ctx, atag, fnct, frmt, ...) \
[DDLog log : isAsynchronous                                     \
level : lvl                                                \
flag : flg                                                \
context : ctx                                                \
file : __FILE__                                           \
function : fnct                                               \
line : __LINE__                                           \
tag : atag                                               \
format : (frmt), ## __VA_ARGS__]

#define LOG_MODULE_MAYBE(async, lvl, flg, ctx, tag, fnct, frmt, ...) \
do { if(lvl & flg) LOG_MACR(async, lvl, flg, ctx, tag, fnct, frmt, ##__VA_ARGS__); } while(0)

#ifndef LOG_ASYNC_ENABLED
#define LOG_ASYNC_ENABLED YES
#endif

#define HTLogHTTPError(frmt, ...)   LOG_MODULE_MAYBE(NO,                LOG_LEVEL_HTTP, DDLogFlagError,   0, LOG_MODULE_HTTP, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define HTLogHTTPWarn(frmt, ...)    LOG_MODULE_MAYBE(LOG_ASYNC_ENABLED, LOG_LEVEL_HTTP, DDLogFlagWarning, 0, LOG_MODULE_HTTP, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define HTLogHTTPInfo(frmt, ...)    LOG_MODULE_MAYBE(LOG_ASYNC_ENABLED, LOG_LEVEL_HTTP, DDLogFlagInfo,    0, LOG_MODULE_HTTP, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define HTLogHTTPDebug(frmt, ...)   LOG_MODULE_MAYBE(LOG_ASYNC_ENABLED, LOG_LEVEL_HTTP, DDLogFlagDebug,   0, LOG_MODULE_HTTP, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define HTLogHTTPVerbose(frmt, ...) LOG_MODULE_MAYBE(LOG_ASYNC_ENABLED, LOG_LEVEL_HTTP, DDLogFlagVerbose, 0, LOG_MODULE_HTTP, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)



#endif
