//
//  HTHTTPModel+Validate.m
//  HTHttpDemo
//
//  Created by Wangliping on 15/12/18.
//  Copyright © 2015年 NetEase. All rights reserved.
//

#import "HTHTTPModel+Validate.h"
#import "NSObject+HTModel.h"

static NSString * const HTTPModelErrorDomain = @"HTTPModelErrorDomain";
static const NSInteger HTTPModelErrorExceptionThrown = 1;

static BOOL HTTPModelValidateAndSetValue(id obj, NSString *key, id value, BOOL forceUpdate, NSError **error) {
    // Mark this as being autoreleased, because validateValue may return
    // a new object to be stored in this variable (and we don't want ARC to
    // double-free or leak the old or new values).
    __autoreleasing id validatedValue = value;
    
    @try {
        if (![obj validateValue:&validatedValue forKey:key error:error]) return NO;
        
        if (forceUpdate || value != validatedValue) {
            [obj setValue:validatedValue forKey:key];
        }
        
        return YES;
    } @catch (NSException *ex) {
        NSLog(@"*** Caught exception setting key \"%@\" : %@", key, ex);
        
        // Fail fast in Debug builds.
#if DEBUG
        
        @throw ex;
#else
        if (error != NULL) {
            *error = [HTHTTPModel modelErrorWithException:ex];
        }
        
        return NO;
#endif
    }
}

@implementation HTHTTPModel (Validate)

- (BOOL)validate:(NSError **)error {
    return [self validate:error crashIfInvalid:NO];
}

- (BOOL)validate:(NSError **)error crashIfInvalid:(BOOL)crashIfInvalid {
    NSDictionary *allPropertyInfoDic = [[self class] ht_allPropertyInfoDic];
    for (NSString *key in allPropertyInfoDic.allKeys) {
        id value = [self valueForKey:key];
        if (nil == value) {
            if (crashIfInvalid) {
                NSAssert(nil, @"property key: %@ is not set, please check your model: %@", key, NSStringFromClass([self class]));
            } else {
                NSLog(@"property key: %@ is not set, please check your model: %@", key, NSStringFromClass([self class]));
            }
        }
        
        BOOL success = HTTPModelValidateAndSetValue(self, key, value, NO, error);
        if (!success) return NO;
    }
    
    return YES;
}

+ (NSError *)modelErrorWithException:(NSException *)exception {
    NSParameterAssert(exception != nil);
    
    NSDictionary *userInfo = @{
                               NSLocalizedDescriptionKey: exception.description,
                               NSLocalizedFailureReasonErrorKey: exception.reason,
                               @"HTTPModelThrownException": exception
                               };
    
    return [NSError errorWithDomain:HTTPModelErrorDomain code:HTTPModelErrorExceptionThrown userInfo:userInfo];
}

@end
