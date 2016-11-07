//
//  NSArray+HTModel.m
//  Pods
//
//  Created by Wangliping on 15/12/8.
//
//

#import <HTHttp/Core/NSArray+HTModel.h>
#import "NSObject+HTModel.h"

@implementation NSArray (HTModel)

+ (NSArray *)ht_modelArrayWithClass:(Class)cls json:(id)json {
    if (!json) return nil;
    NSArray *arr = nil;
    NSData *jsonData = nil;
    if ([json isKindOfClass:[NSArray class]]) {
        arr = json;
    } else if ([json isKindOfClass:[NSString class]]) {
        jsonData = [(NSString *)json dataUsingEncoding:NSUTF8StringEncoding];
    } else if ([json isKindOfClass:[NSData class]]) {
        jsonData = json;
    }
    
    if (jsonData) {
        arr = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:NULL];
        if (![arr isKindOfClass:[NSArray class]]) {
            arr = nil;
        }
    }
    
    return [self ht_modelArrayWithClass:cls array:arr];
}

+ (NSArray *)ht_modelArrayWithClass:(Class)cls array:(NSArray *)arr {
    if (!cls || !arr) {
        return nil;
    }
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for (NSDictionary *dic in arr) {
        if (![dic isKindOfClass:[NSDictionary class]]) {
            continue;
        }
        
        NSObject *obj = [cls ht_modelWithDictionary:dic];
        if (nil != obj) {
            [result addObject:obj];
        }
        
    }
    return result;
}


@end
