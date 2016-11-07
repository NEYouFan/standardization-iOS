//
//  SPUserDataManager.h
//  StandardizationPractice
//
//  Created by Baitianyu on 20/10/2016.
//  Copyright © 2016 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SPUserDataManager : NSObject

@property (nonatomic, assign) BOOL alreadyLogin;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *headerIcon;
@property (nonatomic, assign) CGFloat cacheSize;
@property (nonatomic, assign) BOOL saveOriginalPicture;

+ (instancetype)sharedInstance;
- (void)clearCache;

@end
