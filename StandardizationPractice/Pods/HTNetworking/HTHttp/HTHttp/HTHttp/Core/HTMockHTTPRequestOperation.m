//
//  HTMockHTTPRequestOperation.m
//  Pods
//
//  Created by Wangliping on 16/1/19.
//
//

#import <HTHttp/Core/HTMockHTTPRequestOperation.h>
#import <HTHttp/Core/NSURLRequest+HTMock.h>
#import <HTHttp/Core/HTMockURLResponse.h>
#import <RestKit/Support/RKMIMETypes.h>

@interface HTMockHTTPRequestOperation ()

@property (nonatomic, strong) NSError *mockError;
@property (nonatomic, copy) NSString *mockResponseString;
@property (nonatomic, strong) NSData *mockResponseData;
@property (nonatomic, strong) NSHTTPURLResponse *mockResponse;
@property (nonatomic, strong) id mockResponseObject;
@property (nonatomic, copy) HTMockBlock mockBlock;
@property (nonatomic, copy) NSString *mockJsonFilePath;

@end

@implementation HTMockHTTPRequestOperation

- (instancetype)initWithRequest:(NSURLRequest *)urlRequest {
    self = [super initWithRequest:urlRequest];
    if (self) {
        _mockError = urlRequest.ht_mockError;
        _mockResponseString = urlRequest.ht_mockResponseString;
        _mockResponseData = urlRequest.ht_mockResponseData;
        _mockResponse = urlRequest.ht_mockResponse;
        _mockResponseObject = urlRequest.ht_mockResponseObject;
        _mockBlock = urlRequest.ht_mockBlock;
        _mockJsonFilePath = urlRequest.ht_mockJsonFilePath;
    }
    
    return self;
}

#pragma mark - Mock without network

- (void)start {
    [self updateMockData];
    if ([self enableMock]) {
        if (nil == _mockResponse) {
            // 提供默认的mockResponse.
            if ([self hasValidResponseData]) {
                _mockResponse = [self defaultMockURLResponse];
            } else if (nil != self.mockError) {
                _mockResponse = [self defaultMockErrorURLResponse];
            }
        }
        
        [self finishOperation];
    } else {
        [super start];
    }
}

- (BOOL)enableMock {
    return nil != self.mockError || nil != self.mockResponse || nil != self.mockResponseData;
}

#pragma mark - Override Readonly Properties

- (NSError *)error {
    if (nil != _mockError) {
        return _mockError;
    }
    
    return [super error];
}

- (NSData *)responseData {
    if (nil != self.mockResponseData) {
        return self.mockResponseData;
    }
    
    return [super responseData];
}

- (NSString *)responseString {
    if (nil != self.mockResponseString) {
        return self.mockResponseString;
    }
    
    return [super responseString];
}

- (NSHTTPURLResponse *)response {
    if (nil != _mockResponse) {
        return _mockResponse;
    }
    
    return [super response];
}

#pragma mark - Mock Reponse Data

- (id)mockResponseData {
    if (nil == _mockResponseData) {
        if ([NSJSONSerialization isValidJSONObject:self.mockResponseObject]) {
            _mockResponseData = [NSJSONSerialization dataWithJSONObject:self.mockResponseObject options:0 error:NULL];
        } else if (nil != _mockJsonFilePath) {
            _mockResponseData = [[NSData alloc] initWithContentsOfFile:_mockJsonFilePath];
        } else if ([_mockResponseString length] > 0) {
            _mockResponseData = [_mockResponseString dataUsingEncoding:NSUTF8StringEncoding];
        }
    }
    
    return _mockResponseData;
}

- (NSString *)mockResponseString {
    if (nil == _mockResponseString && nil != self.mockResponseData) {
        return [[NSString alloc] initWithData:self.mockResponseData encoding:NSUTF8StringEncoding];
    }
    
    return _mockResponseString;
}

#pragma mark - Update And Valid Mock Data

- (void)updateMockData {
    if (nil == _mockBlock) {
        return;
    }
    
    _mockBlock(self.request);
    
    NSURLRequest *request = self.request;
    _mockError = request.ht_mockError;
    _mockResponseString = request.ht_mockResponseString;
    _mockResponseData = request.ht_mockResponseData;
    _mockResponse = request.ht_mockResponse;
    _mockResponseObject = request.ht_mockResponseObject;
    _mockJsonFilePath = request.ht_mockJsonFilePath;
}

- (BOOL)hasValidResponseData {
    return (nil != self.responseData || [NSJSONSerialization isValidJSONObject:self.mockResponseObject] || [NSJSONSerialization isValidJSONObject:self.mockResponseString]);
}

#pragma mark - Default Mock Data

- (NSHTTPURLResponse *)defaultMockURLResponse {
    HTMockURLResponse *mockResponse = [[HTMockURLResponse alloc] initWithURL:self.request.URL statusCode:200 HTTPVersion:@"1.1" headerFields:nil];
    mockResponse.mockMIMEType = RKMIMETypeJSON;
    
    return mockResponse;
}

#warning 模拟Error必须要自己提供response或者在获取结果之后处理，否则error会被覆盖.
- (NSHTTPURLResponse *)defaultMockErrorURLResponse {
    HTMockURLResponse *mockResponse = [[HTMockURLResponse alloc] initWithURL:self.request.URL statusCode:404 HTTPVersion:@"1.1" headerFields:nil];
    mockResponse.mockMIMEType = RKMIMETypeJSON;
    
    return mockResponse;
}

@end
