
## 1 HTTPDNS 简介

遭遇 DNS 劫持？使用 HTTPDNS 获取 ip 吧。HTTPDNS 原理：

1. 使用 http 协议，向杭研服务器获取到域名对应的 ip，绕过运营商的 DNS 解析；
2. 直接使用这个 ip 发请求；
		
SDK 提供的支持：

* 同步（异步）获取单个域名对应的地址信息列表
* 同步（异步）获取多个域名对应的地址信息字典
* 分网络类型缓存DNS解析信息，在切换网络时更新缓存
* 缓存获取到的地址信息，优先从缓存中获取解析信息
* 缓存自动更新及强制更新
* 缓存数据加密存储
* 获取单个域名的dns缓存结果
* 获取多个域名的dns缓存结果
* DNS预加载
* 可先httpDNS请求的加密方式（不加密、https、AES)


		

## 2 HTTPDNS 使用教程

### 2.1 接口说明
接口说明参见[《NEHttpDNS设计文档》](https://g.hz.netease.com/HTHttpDNS-android/HTTPDNS-iOS/blob/dev/NEHttpDNS%E8%AE%BE%E8%AE%A1%E6%96%87%E6%A1%A3.md)

### 2.2 客户端集成SDK
使用CocoaPods安装HTTPDNS

(1)修改Podfile

```
pod 'HTTPDNS', :git => 'https://g.hz.netease.com/HTHttpDNS-android/HTTPDNS-iOS.git'
```
(2)执行`pod install` 或`pod update`

(3)应用程序配置
针对iOS 9以上版本，请关闭ATS（Application Transport Secure）特性。如：

```
    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSAllowsArbitraryLoads</key>
        <true/>
    </dict>
```
可通过修改Info.plist文件进行相关配置


### 2.3 HTTPDNS配置

(1)导入头文件

 ```
 #import "NEHTTPDNS.h"
 ```  
(2)设置HTTPDNS服务器的IP地址
 
 默认的服务器IP地址: `106.2.81.8`
 
 ```
 [NEHTTPDNS setServerIP:@"xxx.xxxx.xxx.xxx"];
 ```
(3)设置加密方式
 
 默认的方式是`NOENCRYPTION`方式 ，即明文传输。可通过以下接口设置不同的加密方式。
 
 设置AES加密方式。
 
 ```
 [NEHTTPDNS setAESEncryptionWithProduct:@"test2" key:@"23BED2B9E5895C54705790C43D427E0E" iv:@"34B4A7421D50B1DE3F5C0A7278B61586"];
 ``` 
 
 设置为HTTPS协议传输
 
 ```
 [NEHTTPDNS setHttpsEncryption];
 ```

(4)设置是否允许使用缓存中过期的domain信息

 默认不允许。
 
 ```
 [NEHTTPDNS setExpiredIPEnabYS];
 ```

### 2.4 HTTPDNS SDK使用

(1)预解析域名

在程序初始化的时候，可以选择性地预先通过SDK加载可能会使用到的域名，以便提前解析，减少后续解析时请求的延时。调用如下接口：

```
NSArray * hosts = [[NSArray alloc] initWithObjects:@"www.lofter.com", @"www.test.com", nil];
[NEHTTPDNS preResolveDomains:hosts];
```
(2)查询域名信息

* 同步查询。会首先从缓存中获取可用的domain信息，如果不存在，在进行同步解析请求。同步请求超时时间为10s，若请求失败返回nil。如果相应的返回值为空，产品方需自行通过LocalDNS进行域名解析。
  
  `注意，同步查询会block住当前线程，所以不要放在UI线程来执行。`
  
  ```
  //查询单个host，返回优先ip
  NSString * ip = [NEHTTPDNS ipByDomain:@"www.lofter.com"];
  
  //查询单个host, 返回ip列表
  NSArray<NSString *> * iplist = [NEHTTPDNS ipsByDomain:@"www.lofter.com"];
  
  //查询多个host, 对应返回每个host所对应的优先ip
  NSDictionary<NSString *, NSString *> * resolveDic = [NEHTTPDNS ipByDomains:domains];
  
  //查询多个host, 对应返回每个host所对应的ip列表
  NSDictionary<NSString *, NSArray<NSString *> *resolveDic = [NEHTTPDNS ipsByDomains；domains];
  ```
  
* 异步查询。会首先从缓存中获取可用的domain信息。如果不存在，对就返回nil，并通过子线程去异步请求并刷新缓存。
 
  	异步查询接口使用与同步查询类似。

(3)强制更新

强制更新缓存。`此操作为异步操作`

```
[NEHTTPDNS flush];
```
(4)缓存中删除对应的domain的ip

删除某domain所对应的所有ip

```
[NEHTTPDNS deleteIp:nil correspondingDomain:@"www.lofter.com"];
```

删除某domain所对应的某ip

```
[NEHTTPDNS deleteIp:@"xxx.xxxx.xxx.xxx" correspondingDomain:@"www.lofter.com"];
```

## 3 使用Demo

```
#pragma mark - 初始化设置
- (void)initConfig{
    //1.[可选]设置serverIP, 默认serverIP = 106.2.81.8
    [NEHTTPDNS setServerIP:@"106.2.81.8"];
    //2.设置加密方式，默认明文传输
    //[NEHTTPDNS setNoneEncryption];
#pragma mark - 设置HTTPS传输,
    //[NEHTTPDNS setHttpsEncryption];
#pragma mark - 设置AES加密
    //[NEHTTPDNS setAESEncryptionWithProduct:@"xxx" key:@"xxx" iv:@"xxx"];
    //3.设置是否使用过期缓存，默认不使用
    [NEHTTPDNS setExpiredIPEnabled:NO];
    //4.预加载domains
    NSArray *domains = @[@"api.lofter.com", @"zxq.com", @"www.163.com"];
    [NEHTTPDNS preResolveDomains:domains];
}

#pragma mark - Actions
- (void)syncResolveDemo{
    NSString *originalUrl = @"http://www.163.com/";
    NSURL* url = [NSURL URLWithString:originalUrl];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    // 5.调用同步接口，获取domain信息
    NSString* ip = [NEHTTPDNS ipByDomain:url.host];
    // 6.通过HTTPDNS获取IP成功，进行URL替换和HOST头设置
    if (ip) {
        NSLog(@"Get IP from HTTPDNS Successfully!");
        NSRange hostFirstRange = [originalUrl rangeOfString: url.host];
        if (NSNotFound != hostFirstRange.location) {
            NSString* newUrl = [originalUrl stringByReplacingCharactersInRange:hostFirstRange withString:ip];
            request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:newUrl]];
            [request setValue:url.host forHTTPHeaderField:@"host"];
        }
    }
    else{
    // 7.如果获取失败，则降级处理，自动通过LocalDNS解析
    }
    
    NSHTTPURLResponse* response;
    NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    NSLog(@"response %@",response);
}

- (void)asyncResolveDemo{
    NSString *originalUrl = @"http://www.163.com/";
    NSURL* url = [NSURL URLWithString:originalUrl];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    // 5.调用异步接口，获取domain信息
    NSString* ip = [NEHTTPDNS ipByDomainAsync:url.host];
    // 6.通过HTTPDNS获取IP成功，进行URL替换和HOST头设置
    if (ip) {
        NSLog(@"Get IP from HTTPDNS Successfully!");
        NSRange hostFirstRange = [originalUrl rangeOfString: url.host];
        if (NSNotFound != hostFirstRange.location) {
            NSString* newUrl = [originalUrl stringByReplacingCharactersInRange:hostFirstRange withString:ip];
            request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:newUrl]];
            [request setValue:url.host forHTTPHeaderField:@"host"];
        }
    }
    else{
        // 7.如果获取失败，则降级处理，自动通过LocalDNS解析。同时，SDK会自动进行异步请求，并更新缓存
        //...
    }
    
    NSHTTPURLResponse* response;
    NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    NSLog(@"response %@",response);
}
```
