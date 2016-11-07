//
//  HTCommonLog.h
//  HTCommonUtility
//
//  Created by NetEase on 15/9/2.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#ifndef HTCommonUtility_HTLog_h
#define HTCommonUtility_HTLog_h

#import "CocoaLumberjack.h"

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

#define HT_LOG_MAYBE(async, lvl, flg, ctx, tag, fnct, frmt, ...) \
do { if(lvl & flg) LOG_MACR(async, lvl, flg, ctx, tag, fnct, frmt, ##__VA_ARGS__); } while(0)

#ifndef LOG_ASYNC_ENABLED
#define LOG_ASYNC_ENABLED YES
#endif

#pragma mark - Module Log Macro
/**
 *  Module Log Macro
 */
#define __HTModuleLogConvert(isAsyn, logLevel, logFlag, logModuleName, frmt, ...) \
HT_LOG_MAYBE(isAsyn, logLevel, logFlag,   0, logModuleName, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#endif
