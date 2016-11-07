//
//  HTObjectHelper.h
//  Pods
//
//  Created by Wangliping on 15/12/9.
//
//

#import <Foundation/Foundation.h>

@interface HTObjectHelper : NSObject

/**
 *  是否基本NS类型. NS基本类型包括NSString, NSNumber, NSArray等.
 *
 *  @param cls Class
 *
 *  @return 是，返回YES, 否则，返回NO.
 */
+ (BOOL)isBasicNSClass:(Class)cls;

@end
