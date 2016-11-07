//
//  HTFreezePolicy.m
//  Pods
//
//  Created by Wangliping on 15/10/29.
//
//

#import "HTFreezePolicy.h"
#import "HTFrozenRequest.h"
#import "HTHTTPDate.h"

@implementation HTFreezePolicy

+ (BOOL)canSend:(HTFrozenRequest *)frozenRequest {
    NSURLRequest *request = frozenRequest.request;
    if (nil == request) {
        return NO;
    }
    
    if ([frozenRequest isDateInvalid] || [frozenRequest isExpired]) {
        return NO;
    }
    
    NSDate *now = [[HTHTTPDate sharedInstance] now];
    if (NSOrderedAscending == [now compare:frozenRequest.createDate]) {
        // 当前时间早于创建时间, 不重新发送.
        return NO;
    }
    
    return YES;
}

+ (BOOL)canDelete:(HTFrozenRequest *)frozenRequest {
    // 默认策略：不重新发送则删除，不保留.
    return ![self canSend:frozenRequest];
}

@end
