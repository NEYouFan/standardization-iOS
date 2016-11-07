//
//  SPUser.m
//
//  Created by Netease
//
//  Auto build by NEI Builder

#import "SPUser.h"

/**
 *  用户信息
 */
@implementation SPUser

+ (NSDictionary *)customTypePropertyDic {
    return @{};
}

+ (NSArray *)baseTypePropertyList {
    return @[@"blockBalance", @"status", @"version", @"updateTime", @"balance", @"userId"];
}

@end
