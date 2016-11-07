//
//  HTHTTPModel.h
//  Pods
//
//  Created by Wangliping on 15/11/17.
//
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <HTHttp/Core/HTModelProtocol.h>

@class RKMapping;

@interface HTHTTPModel : NSObject <NSCopying, NSCoding, HTModelProtocol>

/**
 *  Model的版本号. 加上前缀ht避免命名冲突.
 */
@property (nonatomic, assign) NSInteger htVersion;

/**
 *  使用者在子类手写该方法. 主要为了解决通过Runtime无法获取到NSArray中Item的具体类型的问题，为Object Mapping服务.
 *  如果Model类中包含NSArray类型的属性，并且NSArray的每一项的类型不是系统类型而是自定义类型，即不是NSString, NSArray, NSDictionary, NSNumber等类型，
 *  则需要将属性名和对应的ObjectType添加到字典中.
 *  例如，某个子Model定义了属性@property (nonatomic, strong) NSArray<HTUser *> *comments; 通过runtime无法获取到comments属性中NSArray具体每一项的类型.
 *  这时子类的collectionObjectTypeDic需要包含@"comments":@"HTUser"这一项，否则defaultResponseMapping方法获取到的RKMapping可能无法对该NSArray属性作正确处理.
 *  如果是系统类型，例如@property (nonatomic, strong) NSArray<NSString *> *comments; 则不需要添加.
 *
 *  @return 返回字典. Key为属性名，Value为NSArray中ObjectType名.
 */
//+ (NSDictionary *)collectionCustomObjectTypes;

/**
 *  依赖NEI自动生成. NEI自动生成时，给出NSArray里面对应的item type.
 *
 *  @return key为属性名，value为类型. 注意：如果NSArray的item type为HTHTTPModel的子类型，那么value就对应其中的item type.
 */
//+ (NSDictionary *)customTypePropertyDic;
//
////
///**
// *  依赖NEI自动生成. 基本属性列表. 提供该方法的目的: 尽管通过runtime可以获取到一个类的所有属性列表，但是无法区分是否category的属性, 所以通过NEI自动生成来提供.
// *
// *  @return 包含属性名的数组.
// */
//+ (NSArray *)baseTypePropertyList;
// HTHTTPModel的子类需要根据自己的情况来实现上面三个代理方法.

/**
 *  默认的ResponseMapping.
 *
 *  @return 生成Model类默认的ResponseMapping.
 */
+ (RKMapping *)defaultResponseMapping;

#pragma mark - 


#pragma mark - JSON / Model Convertor

/**
 *  根据JSON内容创建对应的Model类对象.
 *
 *  @param json json对象，为NSString, NSData或者NSDictionary.
 *
 *  @return 返回创建的Model对象.
 */
+ (instancetype)modelWithJSON:(id)json;

/**
 *  根据字典内容创建对应的Model类对象.
 *
 *  @param dictionary 字典
 *
 *  @return 返回创建的Model对象.
 */
+ (instancetype)modelWithDictionary:(NSDictionary *)dictionary;

/**
 *  将JSON内容转为Model的属性.
 *
 *  @param dic json对象，为NSString, NSData或者NSDictionary.
 *
 *  @return 成功返回YES, 失败返回NO.
 */
- (BOOL)modelSetWithJSON:(id)json;

/**
 *  将字典内容转为Modle的属性.
 *
 *  @param dic 字典.
 *
 *  @return 成功返回YES, 失败返回NO.
 */
- (BOOL)modelSetWithDictionary:(NSDictionary *)dic;

/**
 *  转换为JSON Object, 比如字典或者数组.
 *
 *  @return 返回JSON Object, 可以是数组或者字典.
 */
- (id)modelToJSONObject;

/**
 *  转换为JSON DATA.
 *
 *  @return 转为JSON格式的NSData.
 */
- (NSData *)modelToJSONData;

/**
 *  转换为JSON String.
 *
 *  @return 返回JSON格式的字符串.
 */
- (NSString *)modelToJSONString;

@end
