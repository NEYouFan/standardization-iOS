//
//  SPNetworking.m
//  StandardizationPractice
//
//  Created by 陶泽宇 on 2016/10/20.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import "SPNetworking.h"
#import <HTNetworking/HTNetworking.h>

@implementation SPNetworking

+ (void)SPNetworkInit{
    NSURL *baseURL = [NSURL URLWithString:@"http://localhost:3000"];
    HTNetworkingInit(baseURL);
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"text/plain"];
}

@end
