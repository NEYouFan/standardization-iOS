//
//  HTKVCHandler.h
//  Pods
//
//  Created by Wangliping on 15/12/9.
//
//

#import <Foundation/Foundation.h>
#import <RestKit/ObjectMapping/RKMappingOperation.h>

@interface HTModelMappingHandler : NSObject <RKMappingOperationDelegate>

+ (instancetype)sharedInstance;

@end
