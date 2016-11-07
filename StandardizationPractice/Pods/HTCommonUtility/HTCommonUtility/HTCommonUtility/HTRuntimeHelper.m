//
//  HTRuntimeHelper.m
//  Pods
//
//  Created by Wangliping on 15/11/9.
//
//

#import "HTRuntimeHelper.h"
#import <objc/runtime.h>

@implementation HTRuntimeHelper

+ (NSArray<NSString *> *)getPropertyList:(Class)theClass {
    NSMutableArray *propertyList = [NSMutableArray array];
    
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList(theClass, &outCount);
    for (i = 0; i < outCount; i++) {
        
        objc_property_t property = properties[i];
        NSString *propertyNameString = [[NSString alloc] initWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        if (nil != propertyNameString) {
            [propertyList addObject:propertyNameString];
        }
    }
    
    return propertyList;
}

+ (NSString *)customDescriptionOf:(NSObject *)object {
    // TODO: 获取object的格式化描述信息，包含属性列表，属性的值等等，以一个格式化的JSON方式展现出来.
    return [object description];
}

@end
