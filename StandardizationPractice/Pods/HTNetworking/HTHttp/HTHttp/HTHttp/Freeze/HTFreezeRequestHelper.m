//
//  HTFreezeRequestHelper.m
//  Pods
//
//  Created by Wangliping on 15/11/3.
//
//

#import "HTFreezeRequestHelper.h"
#import <objc/runtime.h>

@implementation HTFreezeRequestHelper

+ (NSDictionary *)categoryPropertiesOf:(NSURLRequest *)request {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    // Note: 这种获取Category属性的方法并不是通用的.
    // 可以用于NSMutableURLRequest仅仅是因为正常情况下，NSMutableURLRequest和NSURLRequest拥有同样的属性列表.
    NSArray *allPropertyList = [self getAllPropertyList:[NSURLRequest class]];
    NSArray *rawPropertyList = [self getAllPropertyList:[NSMutableURLRequest class]];
    for (NSString *propertyName in allPropertyList) {
        if ([rawPropertyList containsObject:propertyName]) {
            continue;
        }
        
        NSObject *propertyValue = [request valueForKey:propertyName];
        // TODO: 这里排除了不遵循NSCoding协议的属性，与方法名不吻合，暂不处理.
        if (nil != propertyValue && [propertyValue conformsToProtocol:@protocol(NSCoding)]) {
            [dic setObject:propertyValue forKey:propertyName];
        }
    }
    
    return dic;
}


+ (NSArray *)getAllPropertyList:(Class)theClass {
    NSMutableArray *propertyList = [NSMutableArray array];
    
    unsigned int outCount;
    objc_property_t *properties = class_copyPropertyList(theClass, &outCount);
    for (unsigned int i = 0; i < outCount; i++) {
        
        objc_property_t property = properties[i];
        NSString *propertyNameString = [[NSString alloc] initWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        if (nil != propertyNameString) {
            [propertyList addObject:propertyNameString];
        }
    }
    
    return propertyList;
}

@end
