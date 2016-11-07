//
//  HTObjectHelper.m
//  Pods
//
//  Created by Wangliping on 15/12/9.
//
//

#import "HTObjectHelper.h"

/// Foundation Class Type
typedef NS_ENUM (NSUInteger, HTEncodingNSType) {
    HTEncodingTypeNSUnknown = 0,
    HTEncodingTypeNSString,
    HTEncodingTypeNSMutableString,
    HTEncodingTypeNSValue,
    HTEncodingTypeNSNumber,
    HTEncodingTypeNSDecimalNumber,
    HTEncodingTypeNSData,
    HTEncodingTypeNSMutableData,
    HTEncodingTypeNSDate,
    HTEncodingTypeNSURL,
    HTEncodingTypeNSArray,
    HTEncodingTypeNSMutableArray,
    HTEncodingTypeNSDictionary,
    HTEncodingTypeNSMutableDictionary,
    HTEncodingTypeNSSet,
    HTEncodingTypeNSMutableSet,
};

/// Get the Foundation class type from property info.
/// 可以正确处理类似__NSCFBoolean这种类型.
static inline HTEncodingNSType HTClassGetNSType(Class cls) {
    if (!cls) return HTEncodingTypeNSUnknown;
    if ([cls isSubclassOfClass:[NSMutableString class]]) return HTEncodingTypeNSMutableString;
    if ([cls isSubclassOfClass:[NSString class]]) return HTEncodingTypeNSString;
    if ([cls isSubclassOfClass:[NSDecimalNumber class]]) return HTEncodingTypeNSDecimalNumber;
    if ([cls isSubclassOfClass:[NSNumber class]]) return HTEncodingTypeNSNumber;
    if ([cls isSubclassOfClass:[NSValue class]]) return HTEncodingTypeNSValue;
    if ([cls isSubclassOfClass:[NSMutableData class]]) return HTEncodingTypeNSMutableData;
    if ([cls isSubclassOfClass:[NSData class]]) return HTEncodingTypeNSData;
    if ([cls isSubclassOfClass:[NSDate class]]) return HTEncodingTypeNSDate;
    if ([cls isSubclassOfClass:[NSURL class]]) return HTEncodingTypeNSURL;
    if ([cls isSubclassOfClass:[NSMutableArray class]]) return HTEncodingTypeNSMutableArray;
    if ([cls isSubclassOfClass:[NSArray class]]) return HTEncodingTypeNSArray;
    if ([cls isSubclassOfClass:[NSMutableDictionary class]]) return HTEncodingTypeNSMutableDictionary;
    if ([cls isSubclassOfClass:[NSDictionary class]]) return HTEncodingTypeNSDictionary;
    if ([cls isSubclassOfClass:[NSMutableSet class]]) return HTEncodingTypeNSMutableSet;
    if ([cls isSubclassOfClass:[NSSet class]]) return HTEncodingTypeNSSet;
    return HTEncodingTypeNSUnknown;
}

@implementation HTObjectHelper

+ (BOOL)isBasicNSClass:(Class)cls {
    HTEncodingNSType type = HTClassGetNSType(cls);
    return HTEncodingTypeNSUnknown != type;
}

@end
