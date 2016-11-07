//
//  SPPhoto.m
//
//  Created by Netease
//
//  Auto build by NEI Builder

#import "SPPhoto.h"

/**
 *  照片信息
 */
@implementation SPPhoto

+ (NSDictionary *)customTypePropertyDic {
    return @{};
}

+ (NSArray *)baseTypePropertyList {
    return @[@"photoNo", @"imageUrl", @"title", @"location", @"posterName", @"province", @"favorite", @"reason"];
}

@end
