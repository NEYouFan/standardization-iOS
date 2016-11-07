//
//  SPGetUserRequest.m
//
//  Created by Netease
//
//  Auto build by NEI Builder

#import "SPGetUserRequest.h"
#import "HTNetworking.h"
#import "SPModels.h"

@implementation SPGetUserRequest

+ (RKRequestMethod)requestMethod {
    return RKRequestMethodGET;
}

+ (NSString *)requestUrl {
    return @"/user";
}

+ (RKMapping *)responseMapping {
    return [SPUser ht_modelMapping];
}

+ (NSString *)keyPath {
    return @"data";
}

- (NSDictionary *)requestParams {
    NSDictionary *dic = [self ht_modelToJSONObject];
    if ([dic isKindOfClass:[NSDictionary class]] && [dic count] > 0) {
        return dic;
    }
    
    return nil;
}
@end