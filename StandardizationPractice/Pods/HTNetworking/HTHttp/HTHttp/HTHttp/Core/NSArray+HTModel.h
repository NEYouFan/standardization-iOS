//
//  NSArray+HTModel.h
//  Pods
//
//  Created by Wangliping on 15/12/8.
//
//

#import <Foundation/Foundation.h>

@interface NSArray (HTModel)

/**
 将JSON转为Model的数组, 该方法是线程安全的.
 例如: [{"name","Mary"},{name:"Joe"}] 对应的是一个Model的数组.
 但是仅仅能转换为同一类型的Model的数组. 类型由参数class决定.
 
 @param cls  待转换的数组的实际类型.
 @param json 一个JSON的数组，可以是`NSArray`, `NSString` 或 `NSData`.

 
 @return 返回一个数组，出错时返回nil.
 */
+ (NSArray *)ht_modelArrayWithClass:(Class)cls json:(id)json;

@end
