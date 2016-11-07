//
//  SPGetPhotolistRequest.m
//
//  Created by Netease
//
//  Auto build by NEI Builder

#import "SPGetPhotolistRequest.h"
#import "HTNetworking.h"
#import "SPModels.h"

@implementation SPGetPhotolistRequest

+ (RKRequestMethod)requestMethod {
    return RKRequestMethodGET;
}

+ (NSString *)requestUrl {
    return @"/photolist";
}

+ (RKMapping *)responseMapping {
    return [SPPhotolist ht_modelMapping];
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