//
//  HTWriteOnlyCachePolicy.h
//  Pods
//
//  Created by Wangliping on 15/11/16.
//
//

#import "HTCachePolicy.h"

/**
 *  这种特殊的策略不从cache中读取数据，但是总是保存数据到cache中，保证cache数据最新.
 */
@interface HTWriteOnlyCachePolicy : HTCachePolicy

@end
