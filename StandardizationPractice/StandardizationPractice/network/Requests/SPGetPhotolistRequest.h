//
//  SPGetPhotolistRequest.h
//
//  Created by Netease
//
//  Auto build by NEI Builder

#import "SPBaseRequest.h"

/**
 *  name: 获取广场图片列表
 *  description: 获取广场图片列表
 */
@interface SPGetPhotolistRequest : SPBaseRequest


/**
 *  
 */
@property (nonatomic, assign) NSInteger limit;
/**
 *  
 */
@property (nonatomic, assign) NSInteger offset;

@end