//
//  NSURLRequest+HTMock.h
//  Pods
//
//  Created by Wangliping on 16/1/19.
//
//

#import <Foundation/Foundation.h>

/**
 *  在block中提供Mock数据并设置到request中, 需要同步提供Mock数据.
 *
 *  @param request 请求数据类型
 */
typedef void (^HTMockBlock)(NSURLRequest *request);

@interface NSURLRequest (HTMock)

@property (nonatomic, strong) id ht_mockResponseObject;
@property (nonatomic, strong) NSData *ht_mockResponseData;
@property (nonatomic, copy) NSString *ht_mockResponseString;
@property (nonatomic, strong) NSError *ht_mockError;
@property (nonatomic, strong) NSHTTPURLResponse *ht_mockResponse;
@property (nonatomic, copy) HTMockBlock ht_mockBlock;
@property (nonatomic, copy) NSString *ht_mockJsonFilePath;

@end
