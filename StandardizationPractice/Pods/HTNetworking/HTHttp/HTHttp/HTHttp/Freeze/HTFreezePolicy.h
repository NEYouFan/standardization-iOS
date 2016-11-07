//
//  HTFreezePolicy.h
//  Pods
//
//  Created by Wangliping on 15/10/29.
//
//

#import <Foundation/Foundation.h>
#import "HTFreezePolicyProtocol.h"

@interface HTFreezePolicy : NSObject <HTFreezePolicyProtocol>

+ (BOOL)canSend:(HTFrozenRequest *)frozenRequest;

+ (BOOL)canDelete:(HTFrozenRequest *)frozenRequest;

@end
