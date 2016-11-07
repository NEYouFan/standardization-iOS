//
//  HTKVCHandler.m
//  Pods
//
//  Created by Wangliping on 15/12/9.
//
//

#import "HTModelMappingHandler.h"
#import "RKPropertyMapping.h"
#import "RKPropertyInspector.h"
#import "RKObjectMapping.h"
#import "RKLog.h"
#import "HTModelProtocol.h"
#import <RestKit/RestKit.h>

@implementation HTModelMappingHandler

+ (instancetype)sharedInstance {
    static HTModelMappingHandler *instance;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        instance = [[HTModelMappingHandler alloc] init];
    });
    
    return instance;
}

- (BOOL)mappingOperation:(RKMappingOperation *)operation shouldSetValue:(id)value forKeyPath:(NSString *)keyPath usingMapping:(RKPropertyMapping *)propertyMapping {
    id sourceObject = operation.sourceObject;
    id destinationObject = operation.destinationObject;
    if ([sourceObject conformsToProtocol:@protocol(HTModelProtocol)] && [sourceObject respondsToSelector:@selector(shouldSetValueToJson:forKeyPath:)] && [destinationObject isKindOfClass:[NSDictionary class]]) {
        // Model to JSON.
        return [(id<HTModelProtocol>)sourceObject shouldSetValueToJson:value forKeyPath:keyPath];
    } else if ([destinationObject conformsToProtocol:@protocol(HTModelProtocol)] && [destinationObject respondsToSelector:@selector(shouldSetValueToJson:forKeyPath:)] && [sourceObject isKindOfClass:[NSDictionary class]]) {
        // JSON to Model.
        return [(id<HTModelProtocol>)destinationObject shouldSetValueFromJson:value forKeyPath:keyPath];
    }
    
    if ([value isKindOfClass:[NSData class]]) {
        return NO;
    }
    
    return YES;
}

- (void)mappingOperation:(RKMappingOperation *)operation didSetValue:(id)value forKeyPath:(NSString *)keyPath usingMapping:(RKPropertyMapping *)propertyMapping {
    id transformedValue = nil;
    id sourceObject = operation.sourceObject;
    id destinationObject = operation.destinationObject;
    if ([destinationObject conformsToProtocol:@protocol(HTModelProtocol)] && [destinationObject respondsToSelector:@selector(customTransformedValueFromJson:forKeyPath:)] && [sourceObject isKindOfClass:[NSDictionary class]]) {
        // JSON to Model.
        transformedValue = [(id<HTModelProtocol>)destinationObject customTransformedValueFromJson:value forKeyPath:keyPath];
    } else if ([sourceObject conformsToProtocol:@protocol(HTModelProtocol)] && [sourceObject respondsToSelector:@selector(customTransformedValueToJson:forKeyPath:)] && [destinationObject isKindOfClass:[NSDictionary class]]) {
        // Model to JSON.
        transformedValue = [(id<HTModelProtocol>)sourceObject customTransformedValueToJson:value forKeyPath:keyPath];
    }
    
    if (nil != transformedValue) {
        RKLogDebug(@"Model Class provide custom transfrom value for original value : %@ for keyPath: %@", value, keyPath);
    } else if (value == nil) {
        if (propertyMapping.objectMapping.assignsDefaultValueForMissingAttributes) {
            // Serialize nil values as null
            transformedValue = [NSNull null];
        }
    } else if ([value isKindOfClass:[NSDate class]]) {
        [propertyMapping.valueTransformer transformValue:value toValue:&transformedValue ofClass:[NSString class] error:nil];
    } else if ([value isKindOfClass:[NSDecimalNumber class]]) {
        // Precision numbers are serialized as strings to work around Javascript notation limits
        transformedValue = [(NSDecimalNumber *)value stringValue];
    } else if ([value isKindOfClass:[NSSet class]]) {
        // NSSets are not natively serializable, so let's just turn it into an NSArray
        transformedValue = [value allObjects];
    } else if ([value isKindOfClass:[NSOrderedSet class]]) {
        // NSOrderedSets are not natively serializable, so let's just turn it into an NSArray
        transformedValue = [value array];
    } else if ([value isKindOfClass:[NSURL class]]) {
        transformedValue = ((NSURL *)value).absoluteString;
    } else if ([value isKindOfClass:[NSAttributedString class]]) {
        transformedValue = ((NSAttributedString *)value).string;
    } else {
        Class propertyClass = RKPropertyInspectorGetClassForPropertyAtKeyPathOfObject(propertyMapping.sourceKeyPath, operation.sourceObject);
        if ([propertyClass isSubclassOfClass:NSClassFromString(@"__NSCFBoolean")] || [propertyClass isSubclassOfClass:NSClassFromString(@"NSCFBoolean")]) {
            transformedValue = @([value boolValue]);
        }
    }
    
    if (transformedValue) {
#warning 这里有编译问题，原因未知.
//        RKLogDebug(@"Serialized %@ value at keyPath to %@ (%@)", NSStringFromClass([value class]), NSStringFromClass([transformedValue class]), value);
        [operation.destinationObject setValue:transformedValue forKeyPath:keyPath];
    }
}

@end
