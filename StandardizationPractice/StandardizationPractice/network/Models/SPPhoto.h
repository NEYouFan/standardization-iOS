//
//  SPPhoto.h
//
//  Created by Netease
//
//  Auto build by NEI Builder


#import "HTHTTPModel.h"


/**
 *  照片信息
 */
@interface SPPhoto : HTHTTPModel
/**
 *  
 */
@property (nonatomic, copy) NSString *photoNo;
/**
 *  
 */
@property (nonatomic, copy) NSString *imageUrl;
/**
 *  
 */
@property (nonatomic, copy) NSString *title;
/**
 *  
 */
@property (nonatomic, copy) NSString *location;
/**
 *  
 */
@property (nonatomic, copy) NSString *posterName;
/**
 *  
 */
@property (nonatomic, copy) NSString *province;
/**
 *  
 */
@property (nonatomic, assign) BOOL favorite;
/**
 *  
 */
@property (nonatomic, copy) NSString *reason;

@end