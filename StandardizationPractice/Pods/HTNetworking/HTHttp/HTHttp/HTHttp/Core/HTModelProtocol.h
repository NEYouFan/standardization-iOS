//
//  HTModel.h
//  Pods
//
//  Created by Wangliping on 15/12/8.
//
//

#import <Foundation/Foundation.h>

/**
 The `HTModelProtocol` protocol allows users to customize different behaviors while converting between Model and JSON by providing interfaces such as property list.
 */

@class RKObjectMapping;

@protocol HTModelProtocol

@optional

/**
 *  Information of custom object type in collection such as NSArray, NSSet or NSOrderSet.
 *  For example, a property is defined as `@property (nonatomatic, strong) NSArray<HTAuthor *> *authorList`, 
    then a Key-Value pair `@"authorList": @"HTAuthor"` should be included in result of this method.
 *  @return A dictionary indicates property name and object types. The key is property name while the value is object type.
 */
+ (NSDictionary *)collectionCustomObjectTypes;

/**
 *  依赖NEI自动生成. NEI自动生成时，给出NSArray里面对应的item type.
 *
 *  @return key为属性名，value为类型. 注意：如果NSArray的item type为HTHTTPModel的子类型，那么value就对应其中的item type.
 */
+ (NSDictionary *)customTypePropertyDic;

/**
 *  依赖NEI自动生成. 基本属性列表. 提供该方法的目的: 尽管通过runtime可以获取到一个类的所有属性列表，但是无法区分是否category的属性, 所以通过NEI自动生成来提供.
 *
 *  @return 包含属性名的数组.
 */
+ (NSArray *)baseTypePropertyList;

/**
 All the properties in blacklist will be ignored in model transform process.
 Returns nil to ignore this feature.
 
 @return An array of property's name (Array<NSString>).
 */
+ (NSArray *)modelPropertyBlacklist;

/**
 *  用于JSON转Model的RKObjectMapping. 使用者可以自定义Mapping从而实现自定义的Model<>JSON转换. 如果不自定义，那么在调用NSObject+HTModel中提供的Model<>JSON转换接口时，
 *  会默认JSON Key同属性名字一一对应. 创建自己的RKObjectMapping如下:
 
     RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[HTDemoSpec class]];
     [mapping addAttributeMappingsFromArray:@[@"name", @"type"]];
 
     // Note: Model的属性放在后面, JSON Key放在前面
     [mapping addAttributeMappingsFromDictionary:@{@"id":@"listId"}];
 
     添加RelationShipMapping的方法可以参见: https://github.com/RestKit/RestKit/wiki/Object-mapping
 *   TODO: 后续HTHTTP会提供相应文档的整理与示例.
 *
 *  @return 返回一个RKObjectMapping对象.
 */
+ (RKObjectMapping *)customModelMapping;

/**
 *  同modelMapping.
 *
 *  @param blackPropertyList 显式指定了要排除的属性.
 *
 *  @return 返回一个RKObjectMapping对象.
 */
+ (RKObjectMapping *)customModelMapping:(NSArray *)blackPropertyList;

/**
 *  Model到JSON对象的转换. 对于NSObject+HTModel的Category方法, 转换的时候允许使用者自定义该方法的实现。
 *
 *  @return 返回一个JSON对象.
 */
- (id)customModelToJSONObject;

/**
 *  Model到JSON对象的转换. 对于NSObject+HTModel的Category方法, 转换的时候允许使用者自定义该方法的实现。
 *
 *  @return 返回一个JSON对象.
 */
- (id)customModelToJSONObject:(NSArray *)blackPropertyList;

/**
 *  JSON对象到Model的转换. 对于NSObject+HTModel的Category方法, 转换的时候允许使用者自定义该方法的实现。
 *
 *  @return 成功返回YES, 否则返回NO.
 */
- (BOOL)customModelSetWithDictionary:(NSDictionary *)dic;

/**
 *  转换成为JSON时nil属性是否需要转换到JSON中. NSObject+HTModel.h默认转化. 如果不希望包含nil属性，则实现该方法并返回NO.
 *
 *  @return 包含，返回YES, 否则返回NO.
 */
- (BOOL)includeMissingAttributesInJSON;

/**
 *  should set value to json object while converting model to json. If this method is not implemented, then the value should be set for the keypath.
 *  For example, normally, if value's class is NSData, it is not allowed to convert it to JSON Object by default.
 *  Note: If you implement this method in your own class, it would be better to make default return result YES otherwise most object types won't be converted.
 *  A simple implementation should be as following:
 *  - (BOOL)shouldSetValueToJson:(id)value forKeyPath:(NSString *)keyPath {
 *      if ([value is kindofClass:[NSData class]]) {
 *          return NO;
 *      }
 *
 *      return YES.
 *  }
 *
 *  @param value   value which will be set to converted JSON Dictionary.
 *  @param keyPath keyPath for the value in JSON Dictionary.
 *
 *  @return If it could be set, return YES. Otherwise return NO.
 */
- (BOOL)shouldSetValueToJson:(id)value forKeyPath:(NSString *)keyPath;

/**
 *  自定义对于value的转换规则. Note: 一般情况下，默认的转换规则已经够用. 此方法一般用于实现对NSDate的不同形式的格式化字符串或者对NSData等没有默认规则的转化方法.
 *  如果希望对该value采用默认的规则，即不提供任何定制的处理，则返回nil.
 *  @param value   待转换的Value
 *  @param keyPath Value对应的Keypath
 *
 *  @return 返回转换后的value.
 */
- (id)customTransformedValueToJson:(id)value forKeyPath:(NSString *)keyPath;

/**
 *  should set value to json object while converting json to model.
 *  Note: If you implement this method in your own class, it would be better to make default return result YES otherwise most object types won't be converted.
 *  Normally, it is unnecessary to implement it.
 *
 *  @param value   value which will be set to converted Model.
 *  @param keyPath keyPath for the value in converted Model.
 *
 *  @return If it could be set, return YES. Otherwise return NO.
 */
- (BOOL)shouldSetValueFromJson:(id)value forKeyPath:(NSString *)keyPath;

/**
 *  自定义对于value的转换规则. Note: 一般情况下，默认的转换规则已经够用. 此方法一般用于实现对NSDate的不同形式的格式化字符串或者对NSData等没有默认规则的转化方法.
 *  如果希望对该value采用默认的规则，即不提供任何定制的处理，则返回nil.
 *  @param value   待转换的Value
 *  @param keyPath Value对应的Keypath
 *
 *  @return 返回转换后的value.
 */
- (id)customTransformedValueFromJson:(id)value forKeyPath:(NSString *)keyPath;

@end
