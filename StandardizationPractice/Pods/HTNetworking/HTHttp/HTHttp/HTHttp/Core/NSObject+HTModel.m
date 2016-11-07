//
//  NSObject+HTModel.m
//  Pods
//
//  Created by Wangliping on 15/11/25.
//
//

#import "NSObject+HTModel.h"
#import <objc/runtime.h>
#import <RestKit/RestKit.h>
#import <RestKit/ObjectMapping/RKObjectUtilities.h>
#import "RKObjectMappingOperationDataSource.h"
#import <HTHttp/Core/HTModelProtocol.h>
#import <HTHttp/Core/HTModelMappingHandler.h>
#import <HTHttp/Core/HTObjectHelper.h>
#import <HTHttp/Core/NSObject+HTMapping.h>

static void * HTModelCachedPropertyDicKey = &HTModelCachedPropertyDicKey;
static void * HTModelCachedAllPropertyDicKey = &HTModelCachedAllPropertyDicKey;

@implementation NSObject (HTModel)

#pragma mark - Convert Model to JSON/NSString/Dictionary

- (id)ht_modelToJSONObject {
    if ([self conformsToProtocol:@protocol(HTModelProtocol)] && [self respondsToSelector:@selector(customModelToJSONObject)]) {
        return [(id<HTModelProtocol>)self customModelToJSONObject];
    }
    
    RKObjectMapping *mapping = [[self class] ht_modelMapping:YES];
    return [self ht_modelToJSONObjectWithModelMapping:mapping];
}

- (id)ht_modelToJSONObject:(NSArray *)blackPropertyList {
    if ([self conformsToProtocol:@protocol(HTModelProtocol)] && [self respondsToSelector:@selector(customModelToJSONObject:)]) {
        return [(id<HTModelProtocol>)self customModelToJSONObject:blackPropertyList];
    }
    
    RKObjectMapping *mapping = [[self class] ht_modelMappingWithBlackList:blackPropertyList];
    return [self ht_modelToJSONObjectWithModelMapping:mapping];
}

- (id)ht_modelToJSONObjectWithModelMapping:(RKObjectMapping *)modelMapping {
    if (nil == modelMapping) {
        return nil;
    }
    
    RKMapping *inverseMapping = [modelMapping inverseMapping];
    // 属性值为nil时默认包含该Key-Value对, 类似Mantle.
    BOOL assignsDefaultValueForMissingAttributes = YES;
    if ([self conformsToProtocol:@protocol(HTModelProtocol)] && [self respondsToSelector:@selector(includeMissingAttributesInJSON)]) {
        assignsDefaultValueForMissingAttributes = [(id<HTModelProtocol>)self includeMissingAttributesInJSON];
    }
    
    ((RKObjectMapping *)inverseMapping).assignsDefaultValueForMissingAttributes = assignsDefaultValueForMissingAttributes;
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    RKMappingOperation *operation = [[RKMappingOperation alloc] initWithSourceObject:self destinationObject:dictionary mapping:inverseMapping];
    RKObjectMappingOperationDataSource *dataSource = [RKObjectMappingOperationDataSource new];
    operation.dataSource = dataSource;
    operation.delegate = [HTModelMappingHandler sharedInstance];
    [operation start];
    if (operation.error) {
        return nil;
    }
    
    return dictionary;
}

- (NSData *)ht_modelToJSONData {
    id jsonObject = [self ht_modelToJSONObject];
    if (![NSJSONSerialization isValidJSONObject:jsonObject]) {
        return nil;
    }
    
    return [NSJSONSerialization dataWithJSONObject:jsonObject options:0 error:NULL];
}

- (NSString *)ht_modelToJSONString {
    NSData *jsonData = [self ht_modelToJSONData];
    if (jsonData.length == 0) {
        return nil;
    }
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

#pragma mark - Convert JSON/NSString/Dictionary to Model.

+ (instancetype)ht_modelWithJSON:(id)json {
    if (nil == json) {
        return nil;
    }
    
    NSObject *one = [[self alloc] init];
    [one ht_modelSetWithJSON:json];
    
    return one;
}

+ (instancetype)ht_modelWithDictionary:(NSDictionary *)dictionary {
    if (![dictionary isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    NSObject *one = [[self alloc] init];
    [one ht_modelSetWithDictionary:dictionary];
    
    return one;
}

- (BOOL)ht_modelSetWithJSON:(id)json {
    return [self ht_modelSetWithDictionary:[self ht_dicFromJson:json]];
}

- (BOOL)ht_modelSetWithDictionary:(NSDictionary *)dic {
    if ([self conformsToProtocol:@protocol(HTModelProtocol)] && [self respondsToSelector:@selector(customModelSetWithDictionary:)]) {
        return [(id<HTModelProtocol>)self customModelSetWithDictionary:dic];
    }
    
    if (![dic isKindOfClass:[NSDictionary class]]) {
        return NO;
    }
    
    RKMapping *mapping = [[self class] ht_modelMapping:YES];
    RKMappingOperation *operation = [[RKMappingOperation alloc] initWithSourceObject:dic destinationObject:self mapping:mapping];
    RKObjectMappingOperationDataSource *dataSource = [RKObjectMappingOperationDataSource new];
    operation.dataSource = dataSource;
    operation.delegate = [HTModelMappingHandler sharedInstance];
    [operation start];
    if (operation.error) {
        return NO;
    }
    
    return YES;
}

- (NSDictionary *)ht_dicFromJson:(id)json {
    if (nil == json) {
        return nil;
    }
    
    NSDictionary *dic = nil;
    NSData *jsonData = nil;
    if ([json isKindOfClass:[NSDictionary class]]) {
        dic = json;
    } else if ([json isKindOfClass:[NSString class]]) {
        jsonData = [(NSString *)json dataUsingEncoding:NSUTF8StringEncoding];
    } else if ([json isKindOfClass:[NSData class]]) {
        jsonData = json;
    }
    
    if (nil != jsonData) {
        dic = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:NULL];
    }
    
    return dic;
}

#pragma mark - NSCoping Protocol Support

- (id)ht_modelCopy {
    if ([HTObjectHelper isBasicNSClass:[self class]]) {
        NSString *warningMsg = [NSString stringWithFormat:@"Method %@ should not be called for basic NS classe %@ .", NSStringFromSelector(_cmd), [self class]];
        NSAssert(nil, warningMsg);
        return [self copy];
    }
    
    NSObject *one = [self.class new];
    
    NSDictionary *propertyInfoDic = [[self class] ht_allPropertyInfoDic];
    [one setValuesForKeysWithDictionary:[self dictionaryWithValuesForKeys:propertyInfoDic.allKeys]];
    
    return one;
}

#pragma mark - NSCoding Protocol Support

- (void)ht_modelEncodeWithCoder:(NSCoder *)aCoder {
    if (nil == aCoder) {
        return;
    }
    
    if ([HTObjectHelper isBasicNSClass:[self class]] && [self conformsToProtocol:@protocol(NSCoding)] && [self respondsToSelector:@selector(encodeWithCoder:)]) {
        NSString *warningMsg = [NSString stringWithFormat:@"Method %@ should not be called for basic NS classe %@ .", NSStringFromSelector(_cmd), [self class]];
        NSAssert(nil, warningMsg);
        [(id<NSCoding>)self encodeWithCoder:aCoder];
        return;
    }
    
    NSDictionary *propertyInfoDic = [[self class] ht_allPropertyInfoDic];
    for (NSString *propertyName in propertyInfoDic) {
        NSObject *value = [self valueForKey:propertyName];
        if (nil == value) {
            continue;
        }
        
        if ([HTObjectHelper isBasicNSClass:[value class]] || [value respondsToSelector:@selector(encodeWithCoder:)]) {
            [aCoder encodeObject:value forKey:propertyName];
        }
    }
}

- (id)ht_modelInitWithCoder:(NSCoder *)aDecoder {
    if (nil == aDecoder) {
        return self;
    }
    
    if ([HTObjectHelper isBasicNSClass:[self class]] && [self conformsToProtocol:@protocol(NSCoding)] && [self respondsToSelector:@selector(initWithCoder:)]) {
        NSString *warningMsg = [NSString stringWithFormat:@"Method %@ should not be called for basic NS classe %@ .", NSStringFromSelector(_cmd), [self class]];
        NSAssert(nil, warningMsg);
        return self;
    }
    
    NSDictionary *propertyInfoDic = [[self class] ht_allPropertyInfoDic];
    for (NSString *propertyName in propertyInfoDic) {
        NSObject *value = [aDecoder decodeObjectForKey:propertyName];
        [self setValue:value forKey:propertyName];
    }
    
    return self;
}

#pragma mark - IsEqual Support

- (NSUInteger)ht_modelHash {
    if ([HTObjectHelper isBasicNSClass:[self class]]) {
        return [self hash];
    }
    
    NSUInteger value = 0;
    NSUInteger count = 0;
    NSDictionary *propertyInfoDic = [[self class] ht_allPropertyInfoDic];
    for (NSString *propertyName in propertyInfoDic) {
        value ^= [[self valueForKey:propertyName] ht_modelHash];
        count ++;
    }
    
    if (count == 0) {
        value = (long)(__bridge void *)self;
    }
    
    return value;
}

- (BOOL)ht_modelIsEqual:(id)model {
    if ([HTObjectHelper isBasicNSClass:[self class]]) {
        return [self isEqual:model];
    }
    
    if (self == model) {
        return YES;
    }
    
    // It is OK to compare hash value instead of ht_modelHash value.
    if ([self hash] != [model hash]) {
        return NO;
    }
    
    NSDictionary *propertyInfoDic = [[self class] ht_allPropertyInfoDic];
    for (NSString *propertyName in propertyInfoDic) {
        id this = [self valueForKey:propertyName];
        id that = [self valueForKey:propertyName];
        
        if (this == that) {
            continue;
        }
        
        if (nil == this || nil == that) {
            return NO;
        }
        
        if ([this ht_modelIsEqual:that]) {
            continue;
        }
    }
    
    return YES;
}

#pragma mark - Runtime Helper

+ (NSDictionary *)ht_propertyInfoDic {
    NSDictionary *cachedPropertyInfoDic = objc_getAssociatedObject(self, HTModelCachedPropertyDicKey);
    if (cachedPropertyInfoDic != nil) {
        return cachedPropertyInfoDic;
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    for (i = 0; i < outCount; i++) {
        
        objc_property_t property = properties[i];
        NSString *propertyNameString = [[NSString alloc] initWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        if (0 == [propertyNameString length]) {
            continue;
        }
        
        const char *attr = property_getAttributes(property);
        if (NULL == attr) {
            continue;
        }
        
        Class aClass = RKKeyValueCodingClassFromPropertyAttributes(attr);
        NSString *aClassName = NSStringFromClass(aClass);
        if (0 == [aClassName length]) {
            continue;
        }
        
        [dic setObject:aClassName forKey:propertyNameString];
    }
    
    // It doesn't really matter if we replace another thread's work, since we do
    // it atomically and the result should be the same.
    objc_setAssociatedObject(self, HTModelCachedPropertyDicKey, dic, OBJC_ASSOCIATION_COPY);
    
    return dic;
}

+ (NSDictionary *)ht_allPropertyInfoDic {
    NSDictionary *cachedPropertyInfoDic = objc_getAssociatedObject(self, HTModelCachedAllPropertyDicKey);
    if (cachedPropertyInfoDic != nil) {
        return cachedPropertyInfoDic;
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    Class cls = [self class];
    while (nil != [cls superclass]) {
        unsigned int outCount, i;
        objc_property_t *properties = class_copyPropertyList(cls, &outCount);
        for (i = 0; i < outCount; i++) {
            
            objc_property_t property = properties[i];
            NSString *propertyNameString = [[NSString alloc] initWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
            if (0 == [propertyNameString length]) {
                continue;
            }
            
            const char *attr = property_getAttributes(property);
            if (NULL == attr) {
                continue;
            }
            
            Class aClass = RKKeyValueCodingClassFromPropertyAttributes(attr);
            NSString *aClassName = NSStringFromClass(aClass);
            if (0 == [aClassName length]) {
                continue;
            }
            
            [dic setObject:aClassName forKey:propertyNameString];
        }

        cls = [cls superclass];
    }
    
    // It doesn't really matter if we replace another thread's work, since we do
    // it atomically and the result should be the same.
    objc_setAssociatedObject(self, HTModelCachedAllPropertyDicKey, dic, OBJC_ASSOCIATION_COPY);
    
    return dic;
}

@end
