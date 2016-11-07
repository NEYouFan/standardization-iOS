//
//  HTCacheDBHelper.h
//  HTHttp
//
//  Created by Wang Liping on 15/9/2.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTDatabaseHelper.h"

#define HT_HTTP_DB ([HTCacheDBHelper sharedInstance])

@interface HTCacheDBHelper : HTDatabaseHelper

@end
