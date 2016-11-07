//
//  NSDictionary+HTModel.m
//  Pods
//
//  Created by Wangliping on 15/12/8.
//
//

#import <HTHttp/Core/NSDictionary+HTModel.h>
#import "NSObject+HTModel.h"

@implementation NSDictionary (HTModel)

+ (NSDictionary *)ht_modelDictionaryWithClass:(Class)cls json:(id)json {
    if (!json) {
        return nil;
    }
    
    NSDictionary *dic = nil;
    NSData *jsonData = nil;
    if ([json isKindOfClass:[NSDictionary class]]) {
        dic = json;
    } else if ([json isKindOfClass:[NSString class]]) {
        jsonData = [(NSString *)json dataUsingEncoding:NSUTF8StringEncoding];
    } else if ([json isKindOfClass:[NSData class]]) {
        jsonData = json;
    }
    
    if (jsonData) {
        dic = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:NULL];
        if (![dic isKindOfClass:[NSDictionary class]]) {
            dic = nil;
        }
    }
    
    return [self ht_modelDictionaryWithClass:cls dictionary:dic];
}

+ (NSDictionary *)ht_modelDictionaryWithClass:(Class)cls dictionary:(NSDictionary *)dic {
    if (nil == cls || nil == dic) {
        return nil;
    }
    
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    for (id key in dic) {
        NSObject *obj = [cls ht_modelWithDictionary:dic[key]];
        if (nil != obj) {
            result[key] = obj;
        }
        
    }
    
    return result;
}


@end
