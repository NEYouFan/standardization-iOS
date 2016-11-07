//
//  NSObject+HTMapping.h
//  Pods
//
//  Created by Wangliping on 15/12/14.
//
//

#import <Foundation/Foundation.h>

@class RKObjectMapping;

@interface NSObject (HTMapping)

/**
 *  默认根据类定义的属性列表得到的ModelMapping对象. 该Mapping对象用于描述Model<>JSON转换时的对应关系.
 *  用户可以遵守HTModel协议并且实现自己的modelMapping方法来实现转换关系的自定义.
 *  具体可以参见HTModelProtocol.h中HTModel协议的定义以及对modelMapping接口的相关注释.
 *  
 *  @return 返回一个RKObjectMapping对象.
 */
+ (RKObjectMapping *)ht_modelMapping;

/**
 *  默认根据类定义的属性列表得到的ModelMapping对象. 该Mapping对象用于描述Model<>JSON转换时的对应关系.
 *  用户可以遵守HTModel协议并且实现自己的modelMapping方法来实现转换关系的自定义.
 *  具体可以参见HTModelProtocol.h中HTModel协议的定义以及对modelMapping接口的相关注释.
 *
 *  @param cacheMapping 获取Mapping后是否缓存以供下次使用.
 *
 *  @return 返回一个RKObjectMapping对象.
 */
+ (RKObjectMapping *)ht_modelMapping:(BOOL)cacheMapping;

/**
 *  获取ModelMapping对象并且排除参数所指明的属性列表.
 *
 *  @param blackPropertyList 待排除的属性列表.
 *
 *  @return 返回一个RKObjectMapping对象.
 */
+ (RKObjectMapping *)ht_modelMappingWithBlackList:(NSArray *)blackPropertyList;

@end
