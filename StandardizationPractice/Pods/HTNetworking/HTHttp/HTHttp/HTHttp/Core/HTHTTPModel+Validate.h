//
//  HTHTTPModel+Validate.h
//  HTHttpDemo
//
//  Created by Wangliping on 15/12/18.
//  Copyright © 2015年 NetEase. All rights reserved.
//

#import "HTHTTPModel.h"

@interface HTHTTPModel (Validate)

- (BOOL)validate:(NSError **)error;

- (BOOL)validate:(NSError **)error crashIfInvalid:(BOOL)crashIfInvalid;

+ (NSError *)modelErrorWithException:(NSException *)exception;

@end
