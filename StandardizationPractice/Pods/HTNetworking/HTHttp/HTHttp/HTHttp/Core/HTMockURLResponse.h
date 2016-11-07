//
//  HTMockURLResponse.h
//  Pods
//
//  Created by Wangliping on 16/1/20.
//
//

#import <Foundation/Foundation.h>

@interface HTMockURLResponse : NSHTTPURLResponse

@property (nonatomic, copy) NSString *mockMIMEType;

/**
 *  default mock response for a successful request with JSON MIME Type.
 *
 *  @param url url for response
 *
 *  @return A mocked URL response.
 */
+ (instancetype)defaultMockResponseWithUrl:(NSURL *)url;

@end
