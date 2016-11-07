HTNetworking
---
`HTNetworking`是一个基于`RestKit`开发的iOS网络框架库，具有使用简单、高度可配置、扩展性强等特点，同时集成了cache等高级功能。

特性
---
* 简单清晰的请求描述，高度可配置;
* 提供Mock数据测试功能，无须服务器支持也能走通网络请求逻辑;
* 强大的对象映射系统，网络请求返回数据与数据模型类(Model)自动映射;
* 良好的扩展性，更方便替换与扩展底层网络请求库;
* 集成cache、冻结请求、请求调度;
* 解除`RestKit`与`AFNetworking`的耦合；

用法
---

`HTNetworking`将每一个网络请求都封装成对象，因此，对一个请求，都必须提供一个请求类，该类需要继承自`HTBaseRequest`类，通过覆盖父类的一些方法来构造指定的网络请求。

例如，假定有如下请求：   
请求方法：`POST`   请求URL: `/item/info` 需要传递item的ID作为参数, 参数key值为`itemID`.
返回的数据为JSON格式，key为`data`, value为一个字典，示例如下:

	{"data":{"itemId":1015007,
			 "name":"暖冬磨毛纯色AB面四件套",
			 "price":319,
			 "pic":"http://127.net/93813c70eea2230652f15ab5033dab79.jpg"
	         },       
	}

则我们可以先定义一个Model类, 与返回JSON数据中的业务数据对应如下：

	@interface HTEItemInfo : HTHTTPModel
	
	@property (nonatomic, assign) NSInteger itemId;
	@property (nonatomic, copy) NSString *name;
	@property (nonatomic, assign) CGFloat price;
	@property (nonatomic, copy) NSString *pic;
	
	@end


对应的请求类描述如下：

	#import "HTEGetItemInfoRequest.h"
	#import "HTEItemInfo.h"
	
	@implementation HTEGetItemInfoRequest
	
	+ (RKRequestMethod)requestMethod {
	    return RKRequestMethodPOST;
	}
	
	+ (NSString *)requestUrl {
	    return @"/item/info";
	}
	
	// 请求参数.
	- (NSDictionary *)requestParams {
    	return @{@"itemID":@(_itemID)};
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

上面即完成了对一个请求以及该请求返回的数据类型的描述。


发送请求时，调用方式如下：

	HTEGetItemInfoRequest *request = [[HTEGetItemInfoRequest alloc] init];
	// 如有必要，设置request的属性.
	request.itemID = 10;
    [request startWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
    	// 这里的data与HTEGetItemInfoRequest中的keyPath对应.
        HTEItemInfo *itemInfo = [mappingResult.dictionary objectForKey:@"data"];

		// 请求成功，处理请求得到的数据.
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
		// 请求失败，处理错误.
    }];

更多使用示例，请参见Demo与如下文档：

* [HTNetworking基本使用教程](Doc/使用文档/HTNetworking基本使用教程.md)
* [HTNetworking高级使用教程](Doc/使用文档/htnetworking高级使用教程.md)

安装
---
###	CocoaPods

1. 在Podfile中添加 `pod 'HTNetworking'`
2. 执行`pod install`或`pod update`
	
系统要求
---

该项目最低支持`iOS 7.0`和`Xcode 7.0`

许可证
---

HTNetworking使用[Apache 2.0](http://www.apache.org/licenses/LICENSE-2.0)许可证，详情见LICENSE文件.