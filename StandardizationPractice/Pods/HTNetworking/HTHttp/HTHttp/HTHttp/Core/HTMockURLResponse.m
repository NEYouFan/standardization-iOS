//
//  HTMockURLResponse.m
//  Pods
//
//  Created by Wangliping on 16/1/20.
//
//

#import <HTHttp/Core/HTMockURLResponse.h>

@implementation HTMockURLResponse

- (NSString *)MIMEType {
    if ([_mockMIMEType length] > 0) {
        return _mockMIMEType;
    }
    
    return [super MIMEType];
}

+ (instancetype)defaultMockResponseWithUrl:(NSURL *)url {
    HTMockURLResponse *mockResponse = [[HTMockURLResponse alloc] initWithURL:url statusCode:200 HTTPVersion:@"1.1" headerFields:nil];
    mockResponse.mockMIMEType = @"application/json";
    return mockResponse;
}

@end
