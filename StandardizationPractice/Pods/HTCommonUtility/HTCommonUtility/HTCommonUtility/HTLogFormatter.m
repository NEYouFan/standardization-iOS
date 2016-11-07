//
//  HTModuleFormatter.m
//  HTCommonUtility
//
//  Created by NetEase on 15/9/2.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "HTLogFormatter.h"
#import "CocoaLumberjack.h"
@implementation HTLogFormatter

- (NSString *)formatLogMessage:(DDLogMessage *)logMessage {
    if (logMessage->_tag) {
        //存在module名，需要打印出来
        return [NSString stringWithFormat:@"%@: %@",logMessage->_tag, logMessage->_message];
    } else {
        return logMessage->_message;
    }
}

@end

void HTLogInit()
{
#if DEBUG
    //debug版本，打开ASL和TTY，使用ModuleFormatter输出 module名
    DDTTYLogger.sharedInstance.logFormatter = [HTLogFormatter new];
    [DDLog addLogger:DDTTYLogger.sharedInstance];
    [DDLog addLogger:DDASLLogger.sharedInstance];
    [[DDTTYLogger sharedInstance] setColorsEnabled:YES];
#else
    //release版，关闭ASL，打开TTY和file logger，将所有log level设置为error
    [DDLog addLogger:DDASLLogger.sharedInstance];
    
    DDFileLogger * fileLogger = [[DDFileLogger alloc] init];
    
    fileLogger.maximumFileSize = 1024 * 1;  //  1 KB
    fileLogger.rollingFrequency = 60;       // 60 Seconds
    
    fileLogger.logFileManager.maximumNumberOfLogFiles = 4;
    
    [DDLog addLogger:fileLogger withLevel:DDLogLevelError];
#endif
}
