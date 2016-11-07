//
//  SPPhotolist.m
//
//  Created by Netease
//
//  Auto build by NEI Builder

#import "SPPhotolist.h"

/**
 *  照片列表
 */
@implementation SPPhotolist

+ (NSDictionary *)customTypePropertyDic {
    return @{@"photolist" : @"SPPhoto"};
}

+ (NSArray *)baseTypePropertyList {
    return @[@"hasMore"];
}

@end
