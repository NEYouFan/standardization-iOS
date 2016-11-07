//
//  HTHTTPModel.m
//  Pods
//
//  Created by Wangliping on 15/11/17.
//
//

#import "HTHTTPModel.h"
#import <HTHttp/Support/HTHttpLog.h>
#import <RestKit/RestKit.h>
#import <RestKit/ObjectMapping/RKObjectUtilities.h>
#import <objc/runtime.h>
#import "NSObject+HTModel.h"
#import <HTHttp/Core/NSObject+HTMapping.h>

@implementation HTHTTPModel

// TODO: 还需要支持的功能
// 1 copy                   Done
// 2 mutablecopy            Done
// 3 encode/decode          Done
// 4 model-> JSON            Done
// 5 JSON -> Model (优先级低) Done
// 6 如何扩展额外的例如数据库存储，添加额外变量的功能；暂时看来，无法在Model内部支持，需要应用自己去做扩展或者转换. 不能通过派生的方法，因为派生的话，拿到的已经是基类的对象了.
// 7 description
// 8 所有Model和所有Request的头文件要包在一个头文件中

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    HTLogHTTPError(@"Error happens while setting value %@ For Undefined Key: %@", value, key);
}

- (id)valueForUndefinedKey:(NSString *)key {
    HTLogHTTPError(@"Error happens while getting value For Undefined Key: %@", key);
    return nil;
}

+ (RKMapping *)defaultResponseMapping {
    // 尽管htVersion不需要带入Mapping, 但由于无法排除嵌套的htVersion, 且添加该字段到Mapping中并无特殊影响，所以暂不从responseMapping中排除.
    return [self ht_modelMapping];
}

#pragma mark - JSON / Model Convertor

+ (instancetype)modelWithJSON:(id)json {
    return [self ht_modelWithJSON:json];
}

+ (instancetype)modelWithDictionary:(NSDictionary *)dictionary {
    return [self ht_modelWithDictionary:dictionary];
}

- (BOOL)modelSetWithJSON:(id)json {
    return [self ht_modelSetWithJSON:json];
}

- (BOOL)modelSetWithDictionary:(NSDictionary *)dic {
    return [self ht_modelSetWithDictionary:dic];
}

- (id)modelToJSONObject {
    return [self ht_modelToJSONObject];
}

- (NSData *)modelToJSONData {
    return [self ht_modelToJSONData];
}

- (NSString *)modelToJSONString {
    return [self ht_modelToJSONString];
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [self ht_modelEncodeWithCoder:aCoder];
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [self ht_modelInitWithCoder:aDecoder];
}

#pragma mark - NSCoping

- (id)copyWithZone:(nullable NSZone *)zone {
    return [self ht_modelCopy];
}

#pragma mark - hasn and isEqual

- (NSUInteger)hash {
    return [self ht_modelHash];
}

- (BOOL)isEqual:(id)object {
    return [self ht_modelIsEqual:object];
}

@end
