# NEHttpDNS设计文档
HttpDNS是为移动客户端量身定做的基于HTTP协议和域名解析的流量调度解决方案。NEHttpDNS是iOS端对于HttpDNS的实现

## 0 主要功能

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


## 1 接口说明

NEHttpDNS主要通过NEHTTPDNS类进行了接口封装，使用者无需关心任何细节，直接通过NEHTTPDNS访问所需功能接口就可以。

### 1.1 DNS预加载
一般在程序开始时，调用该函数，预先把部分domain加载到内存并进行持久化中，以便使用时直接从缓存中拿，而无需通过网络获取。

```
/**
 *  @param domains 需要预加载的 domain 字符串数组
 */
+ (void)preFetchDomains:(NSArray<NSString *> *)domains;

```

### 1.2 DNS解析异步接口
下面的接口为异步解析接口，首先会查询缓存信息，如果缓存存在，返回对应的解析结果。如果不存在的话，对应返回nil。同时会新建子线程进行异步域名解析，并更新缓存。返回nil时，产品自行采用LocalDNS解析。

```
/**
 *  异步解析接口，首先查询缓存，若存在返回缓存结果；若不存在，则返回nil，并进行异步域名解析更新缓存
 *
 *  @param domain domain
 *
 *  @return domain对应的解析结果
 */
+ (NSString * _Nullable)ipByDomainAsync:(NSString *)domain;

/**
 *  异步解析接口，首先查询缓存，若存在返回结果列表；若不存在，则返回nil，并进行异步域名解析更新缓存
 *
 *  @param domain domain
 *
 *  @return 域名对应的解析结果列表
 */
+ (NSArray<NSString *> *)ipsByDomainAsync:(NSString *)domain;

/**
 *  异步解析接口，根据domains列表，查询缓存中对应的ip;若不存在，则返回nil，并进行异步域名解析更新缓存
 *
 *  @param domains domains 数组
 *
 *  @return 每个 domain 及其对应的 ip 的字典。key 为 domain，value 为 ip
 */
+ (NSDictionary<NSString *, NSString *> * _Nullable)ipByDomainsAsync:(NSArray<NSString *> *)domains;

/**
 *  异步解析接口，根据domains列表，首先查询缓存，若存在则返回对应的结果列表字典;对于不存在的domain缓存信息，进行异步域名解析更新缓存
 *
 *  @param domains domains 数组
 *
 *  @return 每个 domain 及其对应的 ip 的字典。key 为 domain，value 为 ips
 */
+ (NSDictionary<NSString *, NSArray<NSString *> *> * _Nullable)ipsByDomainsAsync:(NSArray<NSString *> *)domains;
```

### 1.3 DNS解析同步接口
下面的接口都是同步接口，可能会发送网络请求，请接入产品自行保证不在主线程中进行。同步请求的超时时间为10s。若请求失败，返回nil，产品自行采用LocalDNS解析。

```
/**
 *  同步解析接口，首先查询缓存，若存在则返回结果；若不存在则进行同步域名解析请求，解析成功返回结果；解析失败，返回nil
 *
 *  @param domain domain
 *
 *  @return 对应该 domain 的 ip
 */
+ (NSString * _Nullable)ipByDomain:(NSString *)domain;

/**
 *  同步解析接口，首先查询缓存，若存在则返回结果列表；若不存在进行同步解析请求，解析成功返回结果，否则，返回nil
 *
 *  @param domain domain
 *
 *  @return 对应该domain的ip列表
 */
+ (NSArray<NSString *> * _Nullable)ipsByDomain:(NSString *)domain;

/**
 *  同步解析接口，首先查询缓存，若存在则返回结果；若不存在则进行同步域名解析请求，解析成功返回结果，否则，返回nil；
 *
 *  @param domains domains 数组
 *
 *  @return 每个 domain 及其对应的 ip 的字典。key 为 domain，value 为 ip
 */
+ (NSDictionary<NSString *, NSString *> * _Nullable)ipByDomains:(NSArray<NSString *> *)domains;

/**
 *  同步解析接口，首先查询缓存，若存在则返回结果；若不存在则进行同步域名解析请求，解析成功返回结果，否则，返回nil；
 *
 *  @param domains domains 数组
 *
 *  @return 每个 domain 及其对应的 ip 的字典。key 为 domain，value 为 ips
 */
+ (NSDictionary<NSString *, NSArray<NSString *> *> * _Nullable)ipsByDomains:(NSArray<NSString *> *)domains;

```

### 1.4 缓存更新
强制更新所有缓存。更新操作在子线程上进行，异步进行域名解析请求，并更新缓存。

```
/**
 *  立即异步更新所有缓存中的数据。
 */
+ (void)flush;
```

```
/**
 *  从内存中删除对应 domain 的 ip
 *
 *  @param ip     ip。如果传入 nil，则删除缓存中 domain 对应的所有 ip
 *  @param domain 对应 ip 的 domain。如果传入 nil，此函数不做任何事
 */
+ (void)deleteIp:(NSString * _Nullable)ip correspondingDomain:(NSString *)domain;
```
 
### 1.6 Config相关
```
/**
 *  是否允许HTTPDNS返回TTL过期的域名
 *  当允许返回ttl过期的ip时，SDK在返回过期的ip的同时依然会进行异步更新以获取最近的ip信息
 *
 *  @param enable 是否返回ttl过期域名
 */
+ (void)setExpiredIPEnabled:(BOOL)enable;
```

以下为设置加密类型的相关接口，默认明文传输。

```
/**
 *  设置 http + AES 加密方式。需要传入配置信息。
 *
 *  @param product 分配的产品号
 *  @param key     加秘秘钥
 *  @param iv      初始向量
 */
+ (void)setAESEncryptionWithProduct:(NSString *)product key:(NSString *)key iv:(NSString *)iv;
```
```
/**
 *  设置 https 加密方式。
 */
+ (void)setHttpsEncryption;
```
```
/**
 *  设置不加密。即不使用 https，也不使用 AES，明文传输。
 */
+ (void)setNoneEncryption;
```
```
/**
 *  设置服务器IP
 */
+ (void)setServerIP:(NSString *)serverIP;
```
