//
//  HTHTTPDate.m
//  Pods
//
//  Created by Wangliping on 15/12/1.
//
//

#import <HTHttp/Support/HTHTTPDate.h>

@implementation HTHTTPDate

+ (instancetype)sharedInstance {
    static HTHTTPDate *sharedDate = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        sharedDate = [[HTHTTPDate alloc] init];
    });
    
    return sharedDate;
}

- (NSDate *)now {
    NSDate *currentTime = [_delegate respondsToSelector:@selector(htGetCurrentTime)] ? [_delegate htGetCurrentTime] : [NSDate date];
    return currentTime;
}

@end
