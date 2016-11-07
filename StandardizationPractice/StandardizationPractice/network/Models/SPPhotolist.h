//
//  SPPhotolist.h
//
//  Created by Netease
//
//  Auto build by NEI Builder


#import "HTHTTPModel.h"

@class SPPhoto;

/**
 *  照片列表
 */
@interface SPPhotolist : HTHTTPModel
/**
 *  
 */
@property (nonatomic, assign) BOOL hasMore;
/**
 *  
 */
@property (nonatomic, strong) NSArray<SPPhoto *> *photolist;

@end