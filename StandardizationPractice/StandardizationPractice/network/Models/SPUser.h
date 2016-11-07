//
//  SPUser.h
//
//  Created by Netease
//
//  Auto build by NEI Builder


#import "HTHTTPModel.h"


/**
 *  用户信息
 */
@interface SPUser : HTHTTPModel
/**
 *  
 */
@property (nonatomic, assign) NSInteger blockBalance;
/**
 *  
 */
@property (nonatomic, assign) NSInteger status;
/**
 *  
 */
@property (nonatomic, assign) NSInteger version;
/**
 *  
 */
@property (nonatomic, assign) NSInteger updateTime;
/**
 *  
 */
@property (nonatomic, assign) NSInteger balance;
/**
 *  
 */
@property (nonatomic, assign) NSInteger userId;

@end