//
//  HTRefreshViewLogger.h
//  Pods
//
//  Created by Bai_tianyu on 9/30/15.
//
//

#ifndef HTRefreshViewLogger_h
#define HTRefreshViewLogger_h

#import "HTLog.h"

#if DEBUG
#define LOG_LEVEL_HT_CONTROLLER_ROUTER DDLogLevelOff//DDLogLevelAll
#else
#define LOG_LEVEL_HT_CONTROLLER_ROUTER 0
#endif

#define LOG_MODULE_HT_CONTROLLER_ROUTER  @"HTRefreshView"

#define HTRefreshViewLogError(frmt, ...)   HT_LOG_MAYBE(NO,                LOG_LEVEL_HT_CONTROLLER_ROUTER, DDLogFlagError,   0, LOG_MODULE_HT_CONTROLLER_ROUTER, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)

#define HTRefreshViewLogWarn(frmt, ...)    HT_LOG_MAYBE(LOG_ASYNC_ENABLED, LOG_LEVEL_HT_CONTROLLER_ROUTER, DDLogFlagWarning, 0, LOG_MODULE_HT_CONTROLLER_ROUTER, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)

#define HTRefreshViewLogInfo(frmt, ...)    HT_LOG_MAYBE(LOG_ASYNC_ENABLED, LOG_LEVEL_HT_CONTROLLER_ROUTER, DDLogFlagInfo,    0, LOG_MODULE_HT_CONTROLLER_ROUTER, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)

#define HTRefreshViewLogDebug(frmt, ...)   HT_LOG_MAYBE(LOG_ASYNC_ENABLED, LOG_LEVEL_HT_CONTROLLER_ROUTER, DDLogFlagDebug,   0, LOG_MODULE_HT_CONTROLLER_ROUTER, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)

#define HTRefreshViewLogVerbose(frmt, ...) HT_LOG_MAYBE(LOG_ASYNC_ENABLED, LOG_LEVEL_HT_CONTROLLER_ROUTER, DDLogFlagVerbose, 0, LOG_MODULE_HT_CONTROLLER_ROUTER, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)


#endif /* HTRefreshViewLogger_h */
