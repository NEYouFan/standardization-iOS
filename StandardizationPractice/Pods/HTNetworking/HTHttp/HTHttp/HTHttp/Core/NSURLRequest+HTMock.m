//
//  NSURLRequest+HTMock.m
//  Pods
//
//  Created by Wangliping on 16/1/19.
//
//

#import <HTHttp/Core/NSURLRequest+HTMock.h>
#import <objc/runtime.h>

static const void *keyHTMockResponseObject = &keyHTMockResponseObject;
static const void *keyHTMockResponseData = &keyHTMockResponseData;
static const void *keyHTMockResponseString = &keyHTMockResponseString;
static const void *keyHTMockError = &keyHTMockError;
static const void *keyHTMockResponse = &keyHTMockResponse;
static const void *keyHTMockBlock = &keyHTMockBlock;
static const void *keyHTMockJsonFilePath = &keyHTMockJsonFilePath;

@implementation NSURLRequest (HTMock)

- (id)ht_mockResponseObject {
    return objc_getAssociatedObject(self, keyHTMockResponseObject);
}

- (void)setHt_mockResponseObject:(id)mockResponseObject {
    objc_setAssociatedObject(self, keyHTMockResponseObject, mockResponseObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSData *)ht_mockResponseData {
    return objc_getAssociatedObject(self, keyHTMockResponseData);
}

- (void)setHt_mockResponseData:(NSData *)mockResponseData {
    objc_setAssociatedObject(self, keyHTMockResponseData, mockResponseData, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)ht_mockResponseString {
    return objc_getAssociatedObject(self, keyHTMockResponseString);
}

- (void)setHt_mockResponseString:(NSString *)mockResponseString {
    objc_setAssociatedObject(self, keyHTMockResponseString, mockResponseString, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSError *)ht_mockError {
    return objc_getAssociatedObject(self, keyHTMockError);
}

- (void)setHt_mockError:(NSError *)mockError {
    objc_setAssociatedObject(self, keyHTMockError, mockError, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSHTTPURLResponse *)ht_mockResponse {
    return objc_getAssociatedObject(self, keyHTMockResponse);
}

- (void)setHt_mockResponse:(NSHTTPURLResponse *)mockResponse {
    objc_setAssociatedObject(self, keyHTMockResponse, mockResponse, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (HTMockBlock)ht_mockBlock {
    return objc_getAssociatedObject(self, keyHTMockBlock);
}

- (void)setHt_mockBlock:(HTMockBlock)mockBlock {
    objc_setAssociatedObject(self, keyHTMockBlock, mockBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)ht_mockJsonFilePath {
    return objc_getAssociatedObject(self, keyHTMockJsonFilePath);
}

- (void)setHt_mockJsonFilePath:(NSString *)mockJsonFilePath {
    objc_setAssociatedObject(self, keyHTMockJsonFilePath, mockJsonFilePath, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end
