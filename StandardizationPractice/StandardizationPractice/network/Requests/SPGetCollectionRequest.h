//
//  SPGetCollectionRequest.h
//
//  Created by Netease
//
//  Auto build by NEI Builder

#import "SPBaseRequest.h"

/**
 *  name: 获取指定用户照片
 *  description: 获取指定用户的照片
使用Post来获取；暂时只支持到用户名lwang作为示例;
url: http://localhost:3000/collection
post内容为： @{@&quot;name&quot;:&quot;lwang&quot;, @&quot;password&quot;:&quot;test&quot;, @&quot;type&quot;:@&quot;photolist&quot;}.
 */
@interface SPGetCollectionRequest : SPBaseRequest


/**
 *  
 */
@property (nonatomic, copy) NSString *name;
/**
 *  
 */
@property (nonatomic, copy) NSString *password;
/**
 *  
 */
@property (nonatomic, copy) NSString *type;

@end