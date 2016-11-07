HTNetworking基本使用教程
---

本教程讲解HTNetworking的基本功能的使用。

###[基本工作流程](#基本工作流程)
###[HTBaseRequest类描述请求](#HTBaseRequest类描述请求)
###[数据模型的描述](#数据模型的描述)
###[发送请求](#发送请求)
###[全局配置](#全局配置)

更多高级功能，请参照[HTNetworking高级使用教程](htnetworking高级使用教程.md).

<p id="基本工作流程">
## 一 基本工作流程

### 流程介绍
`HTNetworking`将每一个网络请求都封装成对象，因此，对一个请求，都必须提供一个请求类，该类需要继承自`HTBaseRequest`类，通过覆盖父类的一些方法来构造指定的网络请求。

针对所有请求，需要提前对请求的管理者作全局的配置，比如，所有请求的baseUrl, 参数序列化格式，返回的数据格式等等，建议放在`AppDelegate`的`- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions`中执行如下代码：

	NSURL *baseURL = [NSURL URLWithString:@"http://www.myserver.com"];
	RKObjectManager *manager = HTNetworkingInit(baseURL);
	
针对每一个具体的请求，需要处理如下几件事情：

1. 如果希望将返回的数据直接映射成数据模型，需要定义指定的数据模型类；
2. 针对具体的请求，需要提供一个请求类描述该请求；
3. 创建请求类的实例，发送请求并处理请求的结果；

HTNetworking的核心功能都通过上面几个步骤来得到体现，具体表现在数据模型类定义方式的不同以及请求类的配置与描述的不同。


### 示例

以如下请求为例，
请求方法：`POST`   请求URL: `/item/info`
返回的数据为JSON格式，key为`data`, value为一个字典，示例如下:

	{"data":{"itemId":1015007,
			 "name":"暖冬磨毛纯色AB面四件套",
			 "price":319,
			 "pic":"http://127.net/93813c70eea2230652f15ab5033dab79.jpg"
	         }       
	}

则数据类定义如下：

	@interface HTEItemInfo : HTHTTPModel
	
	@property (nonatomic, assign) NSInteger itemId;
	@property (nonatomic, copy) NSString *name;
	@property (nonatomic, assign) CGFloat price;
	@property (nonatomic, copy) NSString *pic;
	
	@end


请求类描述如下：

	#import "HTEGetItemInfoRequest.h"
	#import "HTEItemInfo.h"
	
	@implementation HTEGetItemInfoRequest
	
	+ (RKRequestMethod)requestMethod {
	    return RKRequestMethodPOST;
	}
	
	+ (NSString *)requestUrl {
	    return @"/item/info";
	}
	
	// 与返回数据中业务数据的数据模型对应
	+ (RKMapping *)responseMapping {
	    return [HTEItemInfo defaultResponseMapping];
	}
	
	// 与返回数据中业务数据的Key值对应
	+ (NSString *)keyPath {
	    return @"data";
	}
	
	@end

发送请求如下：

	HTEGetItemInfoRequest *request = [[HTEGetItemInfoRequest alloc] init];
    [request startWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
    	// 这里的data与HTEGetItemInfoRequest中的keyPath对应.
        HTEItemInfo *itemInfo = [mappingResult.dictionary objectForKey:@"data"];

		// 请求成功，处理请求得到的数据.
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
		// 请求失败，处理错误.
    }];

<p id="HTBaseRequest类描述请求">    
## 二 HTBaseRequest类描述请求
请求类通过覆盖父类HTBaseRequest的一些方法来构造指定的网络请求。其中，最核心的包括，请求方法，请求地址，请求参数，自定义请求头部，返回的数据模型等；如果不需要修改默认的行为与配置，则不需要覆盖基类的相应方法。

所有功能和请求的配置都不影响请求的发送API调用方式，也即当需求发生变更(例如，请求的定义发生变更时)，通常只需要更新请求描述代码。

### 类定义示例

如下，请求类必须是HTBaseRequest类的子类。

	@interface HTEGetItemInfoRequest : HTBaseRequest
	
	@property (nonatomatic, assign) NSInteger itemID;
	
	@end


当然，如果所有的请求都存在公共的配置，可以自定义一个请求的基类从HTBaseRequest中派生，然后所有的其他请求类从自定义的请求基类中派生，例如：

	@interface HTMyBaseRequest : HTMyBaseRequest
	
	@end


	@interface HTEGetItemInfoRequest : HTMyBaseRequest
	
	@property (nonatomatic, assign) NSInteger itemID;
	
	@end

### 描述请求方法
通过覆写类方法`+ (RKRequestMethod)requestMethod`来描述请求方法，可选值包括`RKRequestMethodGET`, `RKRequestMethodPOST`等，分别与GET, POST, PUT, DELETE等对应.

	+ (RKRequestMethod)requestMethod {
	    return RKRequestMethodPOST;
	}
	
### 描述请求地址	
通过覆写类方法`requestUrl`来描述请求的地址。

实际的请求地址由全局配置的baseUrl与requestUrl拼接而成，例如，baseUrl配置为`http://www.163.com/`, 则如下实现表明该请求地址为`http://www.163.com/item/info`.

	+ (NSString *)requestUrl {
	    return @"/item/info";
	}

### 描述请求参数
通过覆写实例方法`requestParams`来描述请求的参数。

	- (NSDictionary *)requestParams {
		return @{@"itemID":@(_itemID)};
	}

### 描述返回的数据模型

返回的数据模型包括与该数据模型对应的Key值以及返回的数据对应哪个模型类。

通过覆写类方法`+ (NSString *)keyPath`来指明数据模型对应的key值; 例如， 如果希望将`{"data":{....}}`中`data`字段的值映射成为一个数据模型类，则`keyPath`必须指定为`data`, 如下所示：

	+ (NSString *)keyPath {
	    return @"data";
	}

对于数据模型类，有多种方式可以描述。现在针对主要的几种场景进行说明，以返回JSON格式为例，其他返回数据格式在反序列化后能表示为Key-Value对的均与之类似。

#### 数据模型与返回数据一一对应

覆写类方法`+ (RKMapping *)responseMapping`描述数据映射关系；

	+ (RKMapping *)responseMapping {
	    return [HTEItemInfo defaultResponseMapping];
	}

#### 数据模型与返回数据无法完全对应

数据模型属性与返回数据格式中的JSON Key不对应时，需要手写映射关系；

	+ (RKMapping *)responseMapping {
	    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[HTItemInfo class]];
	    // JSON Key:  description  <-->  Model 属性: desc
	    [mapping addAttributeMappingsFromDictionary:@{@"description":@"desc"}];
	    
	    return mapping;
	}

#### 返回数据无法用单一数据模型类描述
	
覆写类方法`+ (NSArray<RKResponseDescriptor *> *)responseDescriptors`可以为一个请求指定多个数据模型类的映射；

	+ (NSArray<RKResponseDescriptor *> *)responseDescriptors {
		NSMutableArray *responseDescriptors = [[NSMutableArray alloc] init];
		
			
		RKMapping *responseMapping = [Model1 defaultResponseMapping];
    	RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:responseMapping method:[self requestMethod] pathPattern:[self pathPattern] keyPath:@"data1" statusCodes:[self statusCodes]];
		if (nil != responseDescriptor) {
			[responseDescriptors addObject:responseDescriptor];
		}
	
		responseMapping = [Model2 defaultResponseMapping];
		responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:responseMapping method:[self requestMethod] pathPattern:[self pathPattern] keyPath:@"data1" statusCodes:[self statusCodes]];
		if (nil != responseDescriptor) {
			[responseDescriptors addObject:responseDescriptor];
		}

		return responseDescriptors;
	}

### 描述不同的baseUrl
当全局配置的baseUrl与实际请求的baseUrl不相同时，可以通过覆写类方法`+ (NSString *)baseUrl`来指明该请求的baseUrl; 
例如，全局配置的baseUrl为`http://www.baidu.com/`, 而实际请求的地址为`http://www.163.com/item/info`, 则可通过如下示例代码设置正确的baseUrl.

	+ (NSString *)baseUrl {
	    return @"http://www.163.com/";
	}

### 配置请求的超时时间
覆写实例方法`requestTimeoutInterval`来配置请求的超时时间，默认是60s,与系统默认的请求超时时间一致。

	- (NSTimeInterval)requestTimeoutInterval {
	    return 120;
	}

### 为请求配置自定义的Header
覆写实例方法`requestHeaderFieldValueDictionary`配置该请求的自定义头部；自定义的Header会在全局配置的Header基础上额外添加头部信息；下面的例子展示了如何添加自定义的Cookie与UserInfo的Header.
	
	- (NSDictionary *)requestHeaderFieldValueDictionary {
	    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	    if (nil != _cookie) {
	        [dic setObject:_cookie forKey:@"Cookie"];
	    }
	    
	    if (nil != _userInfo) {
	        [dic setObject:_userInfo forKey:@"UserInfo"];
	    }
	    
	    return dic;
	}
		
### cache功能配置

通过覆写基类实例方法cacheId即可开启 cache功能

	- (HTCachePolicyId)cacheId {
		// 先从cache中读取数据，如果没有才发送网络请求.
	    return HTCachePolicyCacheFirst;
	}
	
	- (NSTimeInterval)cacheExpireTimeInterval {
		// cache过期时间设置.
	    return 3600;
	}

### 模拟数据
要模拟数据进行测试，需要开启全局的一个开关，建议仅在DEBUG模式下开启，代码如下：

	#ifdef DEBUG
	
	   [HTBaseRequest enableMockTest];
	   
	#endif

通过覆写基类的实例方法`- (BOOL)enableMock`和`- (NSString *)mockJsonFilePath`方法来模拟数据进行测试；

	- (BOOL)enableMock {
	    return YES;
	}
	
	- (NSString *)mockJsonFilePath {
		// 模拟的返回数据从HTMockInfo.json文件中读出.
		return [[NSBundle mainBundle] pathForResource:@"HTMockInfo" ofType:@"json"];
	}
	
或者在创建`Request`的实例后设置`Request`的属性`enableMock`与`mockJsonFilePath`来对该请求指定Mock数据来源:

	request.enableMock = YES;
	request.mockJsonFilePath = [[NSBundle mainBundle] pathForResource:@"HTMockInfo" ofType:@"json"];

除了可以通过JSON文件来模拟数据外，如下属性都可以通过在基类中覆盖对应的实例方法来进行数据模拟, 一般选择一样即可。
	
	// 模拟返回的数据
	@property (nonatomic, strong) NSData *mockResponseData;
	
	// 模拟返回的数据字符串
	@property (nonatomic, copy) NSString *mockResponseString;
	
	// 模拟错误信息
	@property (nonatomic, strong) NSError *mockError;
	
	// 模拟NSURLResponse
	@property (nonatomic, strong) NSHTTPURLResponse *mockResponse;
	
	// 该block允许根据request的不同参数返回不同的模拟数据或者请求返回结果.
	@property (nonatomic, copy) HTMockBlock mockBlock;

### 非法结果处理

通过覆写基类的实例方法`- (HTValidResultBlock)validResultBlock`可以对非法结果进行处理；例如，在请求成功发送，但是服务器没有返回正确数据的情况下，可以让逻辑走到失败的分支，即`failure`的block.

	- (HTValidResultBlock)validResultBlock {
	   return ^(RKObjectRequestOperation *operation) {
	        RKMappingResult *result = operation.mappingResult;
	        if (0 == [result count]) {
	            return NO;
	        }
			
			// 返回YES, 则认为结果合法；否则结果非法。使用者可以根据自己业务逻辑的需求来重写该block.	
	        return YES;
	    };
	}


### 上传表单数据

例如，上传图片时，通常需要以表单的格式上传，只需要覆写基类的方法`- (AFConstructingBlock)constructingBodyBlock`即可。

	- (AFConstructingBlock)constructingBodyBlock {
	    return ^(id<AFMultipartFormData> formData) {
	        NSData *data = UIImagePNGRepresentation(self.uploadImage);
	        NSString *fileName = @"testlwang.png";
	        NSString *formKey = @"files";
	        NSString *type = @"image/png";
	        [formData appendPartWithFileData:data name:formKey fileName:fileName mimeType:type];
	        
	        // 请根据业务需求传递合适的参数. 其中data是实际图片的数据; 其余的参数与下面的内容对应.
	        // Content-Disposition: form-data; name="files"; filename="testlwang.png"
	        // Content-Type: image/png
	    };
	}

### 通过属性配置请求

注意，所有上述的描述，如果在`HTBaseRequest`中有通过属性(@property)对外开放出来, 则可以在创建请求的实例后，通过实例对象的属性去配置请求，例如：
	
	HTMockUserInfoRequest *request = [[HTMockUserInfoRequest alloc] init];
	// 通过HTBaseRequest中开放的属性去配置一个请求.
	request.enableMock = YES;
    request.mockJsonFilePath = [[NSBundle mainBundle] pathForResource:@"HTMockAuthorize" ofType:@"json"];
    [request startWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
		// 结果处理
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
		// 错误处理
    }];

更多对请求的配置参见`HTBaseRequest.h`中的相关描述。

### 自定义请求

通过覆写基类的实例方法`- (void)customRequest:(NSMutableURLRequest *)request`和`- (BOOL)needCustomRequest`可以按照自己的需求任意定制请求；

例如，下面的例子添加了Cookie的HTTP头;

	- (BOOL)needCustomRequest {
		return YES;
	}

	- (void)customRequest:(NSMutableURLRequest *)request {
	    [request setValue:@"testCookie" forHTTPHeaderField:@"Cookie"];
	}
	
这一方法提供了足够的灵活性，使用者可以根据自己的需求完全定制所需要的请求。

<p id="数据模型的描述">
## 三 数据模型的描述
数据模型的描述比较简单，根据返回的业务数据字典描述数据模型即可，使用者可以选择是否从HTHTTPModel中派生；`基本工作流程`中描述了如何定义Model和在Request中描述映射关系，并且这种方式支持模型类的嵌套, 主要通过HTHTTPModel中定义的类方法`+ (RKMapping *)defaultResponseMapping;`或者Category `NSObject+HTMapping.h`中定义的方法`+ (RKObjectMapping *)ht_modelMapping`来描述映射关系，但需要注意如下几个问题：

1. Model的属性值必须与接口返回数据格式的key值一一对应才可以应用上述方法；
2. 如果Model类有集合类型并且集合类型中的Item类型还需要继续映射时，必须遵循`HTHTTPModelProtocol`协议并且实现方法 (建议从`HTHTTPModel`中派生并且实现该方法)，否则无法对子类型进行正确映射。例如：

		@interface HTArticle : HTHTTPModel
		
		@property (nonatomic, copy) NSString *title;
		@property (nonatomic, strong) NSArray<HTSubscriber *> *subscribers;
		
		@end
	
		@implementation HTArticle
		
		+ (NSDictionary *)collectionCustomObjectTypes {
		    return @{@"subscribers" : @"HTSubscriber"};
		}
		
		@end


**强烈建议在设计服务器返回数据格式时，尽量保证能够生成key值对应的数据模型类并且在定义模型类时满足上述限制条件**。否则，例如如果返回数据的格式与模型类的属性定义不匹配，则必须自己手写映射关系的描述；下面举两例说明：

例 1：返回的JSON文件为: {"data":{"description":"It is a test"}}

由于description是NSObject类的方法，因此定义的模型类不允许有`description`属性类; 

@interface HTItemInfo : NSObject

@property (nonatomatic, copy) NSString *desc;

@end

则手写的映射关系如下：

	
	+ (RKMapping *)responseMapping {
	    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[HTItemInfo class]];
	    [mapping addAttributeMappingsFromDictionary:@{@"description":@"desc"}];
	    
	    return mapping;
	}
	
例2：嵌套类型.

返回的JSON文件为: {"data":{"description":"It is a test", "detail":{....}}}， 其中detail字段对应的value对应一个模型类HTItemDetail, HTItemDetail的属性与key值对应.

由于description是NSObject类的方法，因此定义的模型类不允许有`description`属性类; 

	@interface HTDemoItemInfo : NSObject
	
	@property (nonatomatic, copy) NSString *desc;
	@property (nonatomatic, strong) HTItemDetail *detail;
	
	@end

当嵌套的数据模型类也需要映射时，需要使用`addRelationshipMappingWithSourceKeyPath`来添加嵌套的映射关系，描述如下：

	+ (RKMapping *)responseMapping {
	    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[HTItemInfo class]];
	    [mapping addAttributeMappingsFromDictionary:@{@"description":@"desc"}];
	    
	    RKObjectMapping *detailMapping = [HTItemDetail defaultResponseMapping];
	    [mapping addRelationshipMappingWithSourceKeyPath:@"detail" mapping:detailMapping];
	    
	    return mapping;	
	}

更多关于对象映射(Object Mapping)的信息，请参见[Object Mapping](https://github.com/RestKit/RestKit/wiki/Object-mapping).

<p id="发送请求">
## 四 发送请求
发送请求的基本方式都是一致的，常见的需求包括获取映射后的数据、获取映射后的原始Response信息等；另，在回调block中无需考虑循环引用的问题，框架库中已自动进行了处理，解除了回调block与request之间的循环引用。

	HTEGetItemInfoRequest *request = [[HTEGetItemInfoRequest alloc] init];
    [request startWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
		// 请求成功，处理请求得到的数据.
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
		// 请求失败，处理错误.
    }];
    
在获取到结果后，获取模型类信息的方法：

    // 这里的data与HTEGetItemInfoRequest中的keyPath对应.
    HTEItemInfo *itemInfo = [mappingResult.dictionary objectForKey:@"data"];
    
也可以自行获取到`mappingResult.dictionary`后遍历查看其中有哪些数据.

如果需要获取到原始的服务器返回数据，可以通过如下方式：

	id responseObject = operation.responseObject;
    NSString *responseString = operation.HTTPRequestOperation.responseString;
    
获取原始的Response与Request信息，可以通过如下方式：

	NSURLResponse *response = operation.HTTPRequestOperation.response;
    NSURLRequest * request = operation.HTTPRequestOperation.request;
 
上述方法可以协助快速检查服务器返回的结果是否正确，从而定位与排查问题。

通常，请求的回调结果通过block来传递，但同时也支持delegate的方式; 示例如下：

	- (void)demoSendRequestWithDelegate {
	    HTDemoGetUserInfoRequest *request = [[HTDemoGetUserInfoRequest alloc] init];
	    request.requestDelegate = self;
	    [request start];
	}
	
	#pragma mark - HTRequestDelegate
	
	- (void)htRequestFinished:(HTBaseRequest *)request {
		// ... 请求成功
	}
	
	- (void)htRequestFailed:(HTBaseRequest *)request {
		// ... 请求失败
	}

<p id="全局配置"> 
## 五 全局配置

上文中提到，建议放在`AppDelegate`的`- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions`中执行如下代码进行全局配置，此处还可以进行更多全局配置。

### 配置请求的baseUrl

创建RKObjectMananger对象时配置baseUrl.

	NSURL *baseURL = [NSURL URLWithString:@"http://www.myserver.com"];
	RKObjectManager *manager = HTNetworkingInit(baseURL);
	    
### 配置Mock数据开关

在需要mock时，打开全局mock开关。可以在每个请求之前调用，但是建议在`HTNetworkingInit(baseURL)`之后调用，这样需要开启或者关闭模拟测试会非常方便.

    [HTBaseRequest enableMockTest];

### 配置HTTPS相关

HTTPS相关配置可以通过对`RKObjectMananger`对象的`requestProvider`属性进行设置, 下面的例子表示采用默认的securityPolicy并且允许无效证书（即采用自建证书）

	manager.requestProvider.securityPolicy.allowInvalidCertificates = YES;
    manager.requestProvider.securityPolicy.validatesDomainName = NO;

使用者可以根据自己的实际需求进行配置，包括创建可用的`securityPolicy`对象等.

### 配置请求参数格式

可以通过`RKObjectManager`配置请求参数序列化的格式，默认为`application/x-www-form-urlencoded`. 下例将请求参数序列化格式设置为JSON `application/json`.

    manager.requestSerializationMIMEType = RKMIMETypeJSON; 


### 配置返回数据解析方法

例如：服务器返回的实际数据格式为JSON, 但MIME Type为`text/plain`, 则进行如下配置可以按照JSON格式反序列化服务器返回的数据。

	[RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"text/plain"];
	
如果返回的MIME Type为`application/json`, 则不需要额外指定；其他MIME Type类似。

### 配置全局的映射关系

如前所述，数据映射功能用于将返回数据映射成为数据模型类，对每个请求，有不同的业务数据格式，而对所有的请求，可能会存在相同的返回数据格式，例如，一个典型的返回数据格式如下：

	{
		"code": 200,
		"message": "请求成功",
		"data": {...}
	}

其中，`data`对应的是业务数据，对每个请求都不一样，而一级协议格式是一致的，每个请求都会需要知道返回的`code`和`message`信息，则可以添加一个全局的映射关系，这样在返回的mappingResult中可以拿到该映射关系，示例如下：

	// 数据模型
	@interface HTStatusModel : NSObject
	
	@property (nonatomic, assign) NSUInteger code;
	@property (nonatomic, copy) NSString* errorMsg;
	
	@end

	// 映射关系描述	
	+ (RKResponseDescriptor *)errorResponseDescriptor {
	    RKObjectMapping *errorMapping = [RKObjectMapping mappingForClass:[HTStatusModel class]];
	    [errorMapping addAttributeMappingsFromArray:@[@"code",@"errorMsg"]];
	    RKResponseDescriptor *errorResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:errorMapping method:RKRequestMethodAny pathPattern:nil keyPath:nil statusCodes:nil];
	    
	    return errorResponseDescriptor;
	}
	
	// 添加全局的映射关系到RKObjectMananger.
	[manager addResponseDescriptor:[self errorResponseDescriptor]];

### 配置检查错误返回结果的block

有两种方式可以配置全局的`validResultBlock`, 一种是通过`RKObjectMananger`配置, 一种是配置`HTBaseRequest`的默认`validResultBlock`.

假定当mappingResult的结果中没有任何信息时，当作请求错误来处理，则通过RKObjectMananger配置的方式如下:

	manager.validResultBlock = ^(RKObjectRequestOperation *operation) {
        RKMappingResult *result = operation.mappingResult;
        if (0 == [result count]) {
            return NO;
        }

        return YES;
    };

当一个请求类重新实现自己的`- (HTValidResultBlock)validResultBlock`的方法时，可以覆盖上述全局的配置. 如果所有的请求类希望共用相同的 validResultBlock, 也可以在自己所实现的基类中实现该方法。   

### 配置请求属性
有两种方式可以配置应用中所有请求共同的属性；

1. 可以通过RKObjectMananger的requestProvider属性配置；
2. 通过请求基类配置；

以设置超时时间为例：

方式1：
	
	manager.requestProvider.defaultTimeout = 90;
	
方式2：

	// MyBaseRequest提供全局配置，所有请求类从该类派生。
	@interface MyBaseRequest : HTBaseRequest
	
	@end
	
	@implementation MyBaseRequest 
	
	- (NSTimeInterval)requestTimeoutInterval {
	    return 90;
	}
	
	@end		

支持的配置请参见`RKRequestProvider.h`和`HTBaseRequest.h`中的接口说明.
