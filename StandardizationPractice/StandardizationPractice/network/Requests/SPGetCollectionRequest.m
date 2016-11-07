//
//  SPGetCollectionRequest.m
//
//  Created by Netease
//
//  Auto build by NEI Builder

#import "SPGetCollectionRequest.h"
#import "HTNetworking.h"
#import "SPModels.h"

@implementation SPGetCollectionRequest

+ (RKRequestMethod)requestMethod {
    return RKRequestMethodPOST;
}

+ (NSString *)requestUrl {
    return @"/collection";
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