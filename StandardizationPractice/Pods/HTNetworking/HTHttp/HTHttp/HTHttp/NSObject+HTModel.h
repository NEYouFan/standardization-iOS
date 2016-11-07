//
//  NSObject+HTModel.h
//  Pods
//
//  Created by Wangliping on 15/11/25.
//
//

#import <Foundation/Foundation.h>

@interface NSObject (HTModel)

/**
 Generate a json object from the receiver's properties.
 
 @return A json object in `NSDictionary` or `NSArray`, or nil if an error occurs.
 See [NSJSONSerialization isValidJSONObject] for more information.
 
 @discussion Any of the invalid property is ignored.
 If the reciver is `NSArray`, `NSDictionary` or `NSSet`, it just convert
 the inner object to json object.
 */
- (id)ht_modelToJSONObject;

/**
 *  类似ht_modelToJSONObject
 *
 *  @param blackPropertyList 需要排除的字段
 *
 *  @return 返回Json object.
 */
- (id)ht_modelToJSONObject:(NSArray *)blackPropertyList;

/**
 Generate a json string's data from the receiver's properties.
 
 @return A json string's data, or nil if an error occurs.
 
 @discussion Any of the invalid property is ignored.
 If the reciver is `NSArray`, `NSDictionary` or `NSSet`, it will also convert the
 inner object to json string.
 */
- (NSData *)ht_modelToJSONData;

/**
 Generate a json string from the receiver's properties.
 
 @return A json string, or nil if an error occurs.
 
 @discussion Any of the invalid property is ignored.
 If the reciver is `NSArray`, `NSDictionary` or `NSSet`, it will also convert the
 inner object to json string.
 */
- (NSString *)ht_modelToJSONString;

/**
 *  根据JSON对象生成当前类对象.
 *
 *  @param json JSON对象.合法的JSON对象参见NSJSONSerialization的方法+ (BOOL)isValidJSONObject:(id)obj;的描述.
 *
 *  @return 返回一个当前类对象.
 */
+ (instancetype)ht_modelWithJSON:(id)json;

/**
 *  根据字典生成当前类对象.
 *
 *  @param dictionary 与当前类信息匹配的字典.
 *
 *  @return 返回当前类对象.
 */
+ (instancetype)ht_modelWithDictionary:(NSDictionary *)dictionary;

/**
 *  将当前类的信息更新为json所描述的内容.
 *
 *  @param json JSON对象.合法的JSON对象参见NSJSONSerialization的方法+ (BOOL)isValidJSONObject:(id)obj;的描述.
 *
 *  @return 更新成功返回YES，否则返回NO.
 */
- (BOOL)ht_modelSetWithJSON:(id)json;

/**
 *  将当前类的信息更新为字典所描述的内容.
 *
 *  @param dic 字典信息.
 *
 *  @return 成功返回YES, 否则返回NO.
 */
- (BOOL)ht_modelSetWithDictionary:(NSDictionary *)dic;

/**
 *  提供默认的copy机制，会拷贝所有定义的属性.
 *
 *  @return 返回当前类对象.
 */
- (id)ht_modelCopy;

/**
 *  提供默认的encode方法，如果类定义的所有属性或者Collection (NSArray, NSSet..)中包含的对象都支持NSCoding协议，则不需要自己重新写encode方法，直接调用该方法即可.
 *
 *  @param aCoder 一个归档对象.
 */
- (void)ht_modelEncodeWithCoder:(NSCoder *)aCoder;

/**
 *  提供默认的initWithCoder方法，如果类定义的所有属性或者Collection (NSArray, NSSet..)中包含的对象都支持NSCoding协议，则不需要自己重新写initWithCoder方法，直接调用该方法即可.
 *
 *  @param aCoder 一个归档对象.
 */
- (instancetype)ht_modelInitWithCoder:(NSCoder *)aDecoder;

/**
 *  提供默认计算Hash值的方法. 使用者如果希望为自己的类添加方法hash, 可以直接调用该方法.
 *
 *  @return 返回Hash值.
 */
- (NSUInteger)ht_modelHash;

/**
 *  判断类是否相等.
 *
 *  @param model 另一个类对象.
 *
 *  @return 相等返回YES, 否则返回NO.
 */
- (BOOL)ht_modelIsEqual:(id)model;

/**
 *  类的属性信息. 不包含父类的信息.
 *
 *  @return 返回一个字典，key是属性名，value是属性类型.
 */
+ (NSDictionary *)ht_propertyInfoDic;

/**
 *  类的所有属性信息. 包含父类但不包含NSObject, NSProxy等顶层基类.
 *
 *  @return 返回一个字典，key是属性名，value是属性类型.
 */
+ (NSDictionary *)ht_allPropertyInfoDic;

@end
