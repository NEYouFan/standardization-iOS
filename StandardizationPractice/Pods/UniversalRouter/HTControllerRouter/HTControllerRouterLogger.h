//
//  HTControllerRouterLogger.h
//  Pods
//
//  Created by zp on 15/9/9.
//
//

#ifndef Pods_HTControllerRouterLogger_h
#define Pods_HTControllerRouterLogger_h

#import "HTLog.h"
#if DEBUG
#define LOG_LEVEL_HT_CONTROLLER_ROUTER DDLogLevelAll//DDLogLevelOff//DDLogLevelAll
#else
#define LOG_LEVEL_HT_CONTROLLER_ROUTER 0
#endif

#define LOG_MODULE_HT_CONTROLLER_ROUTER  @"ControllerRouter"

#define HTControllerRouterLogError(frmt, ...)   HT_LOG_MAYBE(NO,                LOG_LEVEL_HT_CONTROLLER_ROUTER, DDLogFlagError,   0, LOG_MODULE_HT_CONTROLLER_ROUTER, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define HTControllerRouterLogWarn(frmt, ...)    HT_LOG_MAYBE(LOG_ASYNC_ENABLED, LOG_LEVEL_HT_CONTROLLER_ROUTER, DDLogFlagWarning, 0, LOG_MODULE_HT_CONTROLLER_ROUTER, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define HTControllerRouterLogInfo(frmt, ...)    HT_LOG_MAYBE(LOG_ASYNC_ENABLED, LOG_LEVEL_HT_CONTROLLER_ROUTER, DDLogFlagInfo,    0, LOG_MODULE_HT_CONTROLLER_ROUTER, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define HTControllerRouterLogDebug(frmt, ...)   HT_LOG_MAYBE(LOG_ASYNC_ENABLED, LOG_LEVEL_HT_CONTROLLER_ROUTER, DDLogFlagDebug,   0, LOG_MODULE_HT_CONTROLLER_ROUTER, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define HTControllerRouterLogVerbose(frmt, ...) HT_LOG_MAYBE(LOG_ASYNC_ENABLED, LOG_LEVEL_HT_CONTROLLER_ROUTER, DDLogFlagVerbose, 0, LOG_MODULE_HT_CONTROLLER_ROUTER, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)

#endif
