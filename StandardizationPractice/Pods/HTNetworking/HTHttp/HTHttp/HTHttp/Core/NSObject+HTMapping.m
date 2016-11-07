//
//  NSObject+HTMapping.m
//  Pods
//
//  Created by Wangliping on 15/12/14.
//
//

#import <HTHttp/Core/NSObject+HTMapping.h>
#import "NSObject+HTModel.h"
#import <HTHttp/Core/HTObjectHelper.h>
#import <HTHttp/Core/HTModelProtocol.h>
#import <RestKit/ObjectMapping/RKObjectMapping.h>
#import <objc/runtime.h>

static const NSInteger kMaxRelationshipMappingLevel = 6;
static const void * HTModelCachedMappingKey = &HTModelCachedMappingKey;

@implementation NSObject (HTMapping)

+ (RKObjectMapping *)ht_modelMapping {
    // 默认情况下不缓存Model Mapping.
    return [self ht_modelMapping:NO];
}

+ (RKObjectMapping *)ht_modelMapping:(BOOL)cacheMapping {
    if ([self conformsToProtocol:@protocol(HTModelProtocol)] && [self respondsToSelector:@selector(customModelMapping)]) {
        return [(id<HTModelProtocol>)self customModelMapping];
    }
    
    // 缓存modelMapping以提高性能.
    RKObjectMapping *modelMapping = objc_getAssociatedObject(self, HTModelCachedMappingKey);
    if (modelMapping != nil) {
        return modelMapping;
    }
    
    modelMapping = [self ht_modelMapping:nil hasCycle:NO];
    if (cacheMapping) {
        objc_setAssociatedObject(self, HTModelCachedMappingKey, modelMapping, OBJC_ASSOCIATION_COPY);
    }
    
    return modelMapping;
}

+ (RKObjectMapping *)ht_modelMappingWithBlackList:(NSArray *)blackPropertyList {
    // 对于提供了blackPropertyList的case, 结果不唯一，不提供缓存.
    if ([self conformsToProtocol:@protocol(HTModelProtocol)] && [self respondsToSelector:@selector(customModelMapping:)]) {
        return [(id<HTModelProtocol>)self customModelMapping:blackPropertyList];
    }
    
    return [self ht_modelMapping:nil blackPropertyList:blackPropertyList hasCycle:NO];
}

// 增加excludeModelList是为了避免递归过程中死锁的出现. 例如: Model A中有个成员变量类型仍然是Model A, 如果在取该成员变量的类型Model A的Mapping中，不添加参数excludeModelList, 就会无限递归.
+ (RKObjectMapping *)ht_modelMapping:(NSMutableArray *)excludeModelList hasCycle:(BOOL)hasCycle {
    NSArray *blackPropertyList = [self ht_modelPropertyBlacklist];
    return [self ht_modelMapping:excludeModelList blackPropertyList:blackPropertyList hasCycle:hasCycle];
}

// 增加excludeModelList是为了避免递归过程中死锁的出现. 例如: Model A中有个成员变量类型仍然是Model A, 如果在取该成员变量的类型Model A的Mapping中，不添加参数excludeModelList, 就会无限递归.
+ (RKObjectMapping *)ht_modelMapping:(NSMutableArray *)excludeModelList blackPropertyList:(NSArray *)blackPropertyList hasCycle:(BOOL)hasCycle {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[self class]];
    NSArray *attributesArray = [self ht_mappingAttributesArrayWithBlackList:blackPropertyList];
    if ([attributesArray count] > 0) {
        [mapping addAttributeMappingsFromArray:attributesArray];
    }
    
    // 如果出现了循环，则限制最多层数为kMaxRelationshipMappingLevel.
    if (hasCycle && [excludeModelList count] > kMaxRelationshipMappingLevel) {
        return mapping;
    }
    
    NSDictionary *customTypePropertyDic = [self ht_customTypePropertyDic];
    for (NSString *propertyName in customTypePropertyDic) {
        if (0 == [propertyName length] || [blackPropertyList containsObject:propertyName]) {
            // 属性名为空或者被显式排除，则不需要添加到Mapping中.
            continue;
        }
        
        NSString *propertyType = [customTypePropertyDic objectForKey:propertyName];
        Class modelClass = NSClassFromString(propertyType);
        if (!hasCycle && [excludeModelList containsObject:propertyType]) {
            // 如果属性已被排除，则表明出现了循环.
            // 例如，ClassA含有类型为ClassB的属性，ClassB又含有类型为ClassA的属性，那么必须控制循环的曾经，否则会在添加RelationshipMapping时无限循环.
            hasCycle = YES;
        }
        
        NSMutableArray *itemExcludeModeList = [NSMutableArray arrayWithObject:NSStringFromClass([self class])];
        if ([excludeModelList count] > 0) {
            [itemExcludeModeList addObjectsFromArray:excludeModelList];
        }
        
        // Note: 这里不需要传递blackPropertyList.
        RKObjectMapping *relationMapping = [modelClass ht_modelMapping:itemExcludeModeList hasCycle:hasCycle];
        if (nil == relationMapping) {
            continue;
        }
        
        [mapping addRelationshipMappingWithSourceKeyPath:propertyName mapping:relationMapping];
    }
    
    return mapping;
}

+ (NSArray *)ht_mappingAttributesArrayWithBlackList:(NSArray *)blackPropertyList {
    NSArray *attributesArray = [self ht_baseTypePropertyList];
    if (0 == [blackPropertyList count]) {
        return attributesArray;
    }
    
    NSMutableArray *array = [NSMutableArray array];
    [array addObjectsFromArray:attributesArray];
    [array removeObjectsInArray:blackPropertyList];
    return array;
}

#pragma mark - Helper Methods

+ (NSArray *)ht_modelPropertyBlacklist {
    if ([self conformsToProtocol:@protocol(HTModelProtocol)] && [self respondsToSelector:@selector(modelPropertyBlacklist)]) {
        return [(id<HTModelProtocol>)self modelPropertyBlacklist];
    }
    
    return nil;
}

+ (NSDictionary *)ht_collectionCustomObjectTypes {
    if ([self conformsToProtocol:@protocol(HTModelProtocol)] && [self respondsToSelector:@selector(collectionCustomObjectTypes)]) {
        return [(id<HTModelProtocol>)self collectionCustomObjectTypes];
    }
    
    return nil;
}

+ (NSDictionary *)ht_customTypePropertyDic {
    if ([self conformsToProtocol:@protocol(HTModelProtocol)] && [self respondsToSelector:@selector(customTypePropertyDic)]) {
        return [(id<HTModelProtocol>)self customTypePropertyDic];
    }
    
    NSMutableDictionary *customTypePropertyDic = [NSMutableDictionary dictionary];
    NSDictionary *dic = [self ht_allPropertyInfoDic];
    for (NSString *properyName in dic) {
        NSString *className = [dic objectForKey:properyName];
        Class propertyClass = NSClassFromString(className);
        // 如果不是基本系统类型，如NSString, NSArray等，则可继续映射.
        if (![HTObjectHelper isBasicNSClass:propertyClass]) {
            [customTypePropertyDic setObject:className forKey:properyName];
        }
    }
    
    NSDictionary *collectionObjectTypeDic = [self ht_collectionCustomObjectTypes];
    if (nil != collectionObjectTypeDic) {
        [customTypePropertyDic addEntriesFromDictionary:collectionObjectTypeDic];
    }
    
    return customTypePropertyDic;
}

+ (NSArray *)ht_baseTypePropertyList {
    if ([self conformsToProtocol:@protocol(HTModelProtocol)] && [self respondsToSelector:@selector(baseTypePropertyList)]) {
        return [(id<HTModelProtocol>)self baseTypePropertyList];
    }
    
    NSMutableArray *baseTypePropertyList = [NSMutableArray array];
    NSDictionary *collectionObjectTypeDic = [self ht_collectionCustomObjectTypes];
    NSDictionary *dic = [self ht_allPropertyInfoDic];
    for (NSString *properyName in dic) {
        NSString *className = [dic objectForKey:properyName];
        Class propertyClass = NSClassFromString(className);
        // 如果是基本系统类型，并且不是含有自定义类型的NSArray或者NSSet等，则按照基本类型进行映射.
        if ([HTObjectHelper isBasicNSClass:propertyClass] && nil == [collectionObjectTypeDic objectForKey:properyName]) {
            [baseTypePropertyList addObject:properyName];
        }
    }
    
    return baseTypePropertyList;
}

@end
