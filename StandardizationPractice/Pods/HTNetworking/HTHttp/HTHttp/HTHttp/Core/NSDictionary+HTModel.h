//
//  NSDictionary+HTModel.h
//  Pods
//
//  Created by Wangliping on 15/12/8.
//
//

#import <Foundation/Foundation.h>

@interface NSDictionary (HTModel)

/**
*  将JSON转为Model的数组, 该方法是线程安全的. 
*  例如:  Example: {"user1":{"name","Mary"}, "user2": {name:"Joe"}} 对应的是一个字典，将这个字典的Value转为一个Model, 该Model的类型由参数cls指定. 
*  Note: 仅仅能转换为同一类型的Model的数组. 类型由参数class决定. 推荐对于整个JSON创建一个对应的Model类进行描述.
*
*  @param cls  待转换的Model类型.
*  @param json 一个表示字典的JSON，可以是`NSDictionary`, `NSString` 或 `NSData`.
*
*  @return 返回一个字典，该字典的Value均为cls类型的对象.
*/

+ (NSDictionary *)ht_modelDictionaryWithClass:(Class)cls json:(id)json;

@end
