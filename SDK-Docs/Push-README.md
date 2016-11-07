# 一、简介

Push iOS SDK 是配合推送平台开发的适应于 iOS 设备上的客户端 SDK。SDK 基于 MQTT 协议，在原有的协议上进行了封装，提供了更加清晰、易用的接口，便于客户端与推送服务器的之间的通讯。

目前广播全部通过 APNs 发送，而私信则可以通过长连接和 APNs 两个通道发送(可自由选择)。

本项目的git地址: [https://g.hz.netease.com/push-client/push-sdk-ios.git](https://g.hz.netease.com/push-client/push-sdk-ios.git)

本项目Demo的git地址: [https://g.hz.netease.com/push-client/push-sdk-ios-demo.git](https://g.hz.netease.com/push-client/push-sdk-ios-demo.git)

最新版本：**0.5.3 / 2016-09-07**，[更新日志](https://g.hz.netease.com/push-client/push-sdk-ios/blob/master/HISTORY.md)

支持 bitcode 的 0.5.3 下载地址: [https://g.hz.netease.com/push-client/push-sdk-ios/blob/0.5.3/Lib/Result-bitcode/push-sdk-ios-0.5.3-bitcode.tar.gz](https://g.hz.netease.com/push-client/push-sdk-ios/blob/0.5.3/Lib/Result-bitcode/push-sdk-ios-0.5.3-bitcode.tar.gz)

不支持 bitcode 的 0.5.3 下载地址: [https://g.hz.netease.com/push-client/push-sdk-ios/blob/0.5.3/Lib/Result/push-sdk-ios-0.5.3.tar.gz](https://g.hz.netease.com/push-client/push-sdk-ios/blob/0.5.3/Lib/Result/push-sdk-ios-0.5.3.tar.gz)


# 二、版本号说明

本 SDK 0.4.0 以后的版本的版本号遵循[语义化版本semver 2.0](http://semver.org/)规范, 因此，在遵循此规范的前提下，你可以安全地进行版本升级替换。

比如 0.4.5 版本相对于 0.4.2 版本来说，仅仅是 bugfix.


# 三、集成 SDK 的方式

目前 SDK 提供三种集成方式，不论使用何种集成方式，强烈建议使用最新版本的 SDK，以避免遗留的 bug 影响产品。

1. 使用 Cocoapods 集成 SDK(推荐使用方式)

	从 0.5.2 版本开始，SDK 支持使用 Cocoapods 集成，我们也推荐使用该方式。引入时请在项目 Podfile 中添加：

		pod 'PomeloPush' , :git=>'https://g.hz.netease.com/push-client/push-sdk-ios.git', :branch=>'0.5.3'。
	
	注意 branch 参数指定了使用哪个版本的 SDK，只有版本号不小于 0.5.2 的 branch 才支持使用该方式。

	注意：Podfile 中不要使用 tag 进行版本区分，例如：pod 'PomeloPush' , :git=>'https://g.hz.netease.com/push-client/push-sdk-ios.git', :tag=>'0.5.3' 的使用方式是错误的，需要将 tag 更换为 branch

1. 使用二进制包集成 SDK

   从本文起始列出的地址下载压缩包，解压，会有三个文件，分别是：

   * `pomeloclient.h` 文件
   * `libPushSDK.a` 文件
   * `libPushSDK-debug.a` 文件

   直接将头文件加入项目，并建立好对 `.a` 文件的依赖，`libPushSDK-debug.a` 是调试版本，含有一些调试信息。不要同时加入对 `libPushSDK-debug.a` 跟 `libPushSDK.a`，否则会导致链接冲突。
   当你需要调试信息时，请使用 `libPushSDK-debug.a`，当你不需要调试信息时，或者线上发布时，请使用 `libPushSDK.a`。使用时需要添加系统依赖库 `systemconfiguration.framework`

1. 直接以源码的方式集成 SDK(不推荐使用)

   下载源码: `git clone https://g.hz.netease.com/push-client/push-sdk-ios`，将代码中的源文件引入项目工程即可。注意：在直接使用源码时， 由于引入了 OpenUDID 库，而且 OpenUDID 代码不支持 ARC，因此需要在编译配置里面，针对 `Pomelo_OpenUDID.c` 文件配置选项 `-fno-objc-arc`。


# 四、使用流程及API说明

本文档中大部分接口说明已更新为 0.5.2 及以后版本中的接口，0.5.2 版本与之前接口基本一致。如对旧版本接口有疑问可参考 PomeloClient.h 文件中接口说明或联系 hzbaitianyu@corp.netease.com 进行详细咨询。建议使用者升级为最新 SDK 版本，以免旧版本遗留 bug 影响产品使用。


## 1. 初始化

* 使用初始化方法初始化 PomeloClient 实例

```objective-c
- (id)initWithDelegate:(id)aDelegate
                domain:(NSString *)aDomain
            productKey:(NSString *)aProductKey
           deviceToken:(NSString *)token
         delegateQueue:(NSOperationQueue *)queue;
```

参数说明：

		@param aDelegate       PomeloClient 的 delegate，是一个实现 PomeloDelegate 协议的 Object 实例
	 	@param aDomain         客户端所在的产品域
	  	@param aProductKey     产品 key
	   	@param token           客户端从 APNs 获取的 deviceToken，如果初始化时还没有取到设备的 deviceToken，可传入 nil
	    	@param queue           指定 push 有事件/消息时，回调到哪个线程。即应用期待接收回调的线程

* 设置推送环境的 `host` 和 `port`，SDK 默认会提供正式产品环境的 `host` 和 `port` ，所以如果在测试环境，需要设置自定义的 `host` 和 `port`(测试环境 host: `123.58.180.233`, port: `6001`)：

```objective-c
- (void)setHost:(NSString *)aHost port:(UInt16)aPort;
```

* 如果要使用 **长连接** 方式来获得推送，需要开启长连接支持：

```objective-c
- (void)useLongConnection;
```

  **注意**： 开启长连接支持后，SDK 会自动维护连接状态。主要表现在：网络状态变化导致连接断开后会自动进行重连。开发者无需关注长连接的连接状态以及底层细节。


## 2. 连接

```objective-c
- (BOOL)connect;
```

连接成功的回调：

```objective-c
- (void)pomeloClientDidConnect:(PomeloClient *)client success:(BOOL)isSuccess;
```

连接失败时，会自动尝试重连，直到连接成功。


## 3. 注册设备

如果需要 APNs 推送服务，在每次应用启动后必须向服务器注册设备。

```objective-c
- (BOOL)registerDeviceWithProductVersion:(NSString *)productVersion xplatform:(NSString *)xplatform info:(NSDictionary *)info;
```

参数说明：

		@param productVersion 产品版本，格式为 x.x.x，用于服务端过滤，不能为 nil
		@param xplatform      平台标志(iPhone或iPad)，用于服务端过滤，不能为 nil
		@param info           可选参数，如果要在 register 的时候传入更多的参数，可添加在 info 中，默认传 nil

注册成功回调：

```objective-c
- (void)pomeloClient:(PomeloClient *)client didRegisterDeviceResponse:(ResponseCode)code;
```

**注意**: 如连接服务器失败（无网络等情况），则需在下次连接成功时，再向服务器注册，直到注册成功。 如果第一次注册时没有取到 `deviceToken`, 而之后某次取到了，那么需要调用 updateDeviceToken: 方法，并重新调用`register` 接口。


## 4. 用户和设备绑定

当 App 中有用户登录时，需要将用户与设备进行绑定。绑定时机一般在产品用户登录成功后。

接口：

```objective-c
- (BOOL)bindUser:(NSString *)user expireTime:(NSString *)expireTime nonce:(NSString *)nonce signature:(NSString *)signature info:(NSDictionary *)info;
```

参数说明：

		@param user       用户名，其中不能包含 ';' 和 ',' 等特殊字符
		@param expireTime 推送消息过期时间，由产品服务器返回
		@param nonce      产品域，由产品服务器返回
		@param signature  签名，由产品服务器返回
		@param info       可选参数，如果要在 register 的时候传入更多的参数，可添加在 info 中，默认传 nil。如果想要支持一台设备绑定多用户，那么请在 `info` 中设置参数 `multiUser` 的值为 `1`

绑定成功回调方法：

```objective-c
- (void)pomeloClient:(PomeloClient *)client didBindUserResponse:(ResponseCode)code;
```

**注意**: 若连接暂时不可用，或发送失败，则应在下次连接成功时，再次发起绑定请求，直到绑定成功


## 5. 解除用户和设备绑定

当 App 中有用户注销（退出登录）时，需要向服务器发送解除绑定请求，解除用户与设备的绑定。

接口：

```objective-c
- (BOOL)unbindUser:(NSString *)user;
```

解除绑定回调方法：

```objective-c
- (void)pomeloClient:(PomeloClient *)client didUnbindUserResponse:(ResponseCode)code;
```

**注意**: 当网络不可用时，解除绑定实际上为本地操作，即删除用户的 `signatrue`。解除绑定可以不用等待返回。


## 6. 接受私信消息

目前使用长连接推送只支持私信消息，接受私信消息的接口：

```objective-c
- (void)pomeloClient:(PomeloClient *)client didReceiveSpecifyMessage:(NSArray *)message;
```

## 7. 上报系统和用户信息

```objective-c
- (BOOL)reportInfo:(NSDictionary *)info;
```

此接口主要是用来上传一些产品自定义筛选条件. 目前使用此接口来做基于mask的过滤，以后可能会使用此接口做更多其他东西。

mask过滤的具体实现为, 客户端通过此接口上报一个mask值到服务端, 然后服务端发广播消息的时候需要指定一个mask值。 我们会对服务端指定的mask值与客户端上报的mask值按位与操作, 如果非0, 就给对应用户下发消息, 否则不下发。通过使用这个接口，来可以实现有过滤的广播。

例子如下:

```objective-c

[pomeloClient reportInfo:@{@"mask": @1}];

```

## 8. 断开连接

当暂时不需要使用长连接时，可以选择手动释放掉连接。

```objective-c
- (BOOL)disconnect;
```

此调用返回值一定是`YES`.

## 9. 释放 PomeloClient

如果不再需要使用推送服务，请调用`destroyPomeloClient`方法，然后再置为 nil。

之所以需要调用`destroyPomeloClient`方法是为了销毁 SDK 内部的 Runloop，如果不销毁 Runloop，那么会导致资源泄露。


# 五、辅助接口

1. 日志功能

从 0.5.2 版本开始，SDK 引入了日志功能，日志分五个等级：

   	 PomeloLogLevelDebug = 0,
	 PomeloLogLevelInfo,
	 PomeloLogLevelWarning,
	 PomeloLogLevelError,
	 PomeloLogLevelFetal

日志分为两种：

* 控制台日志：在 SDK 整个生命周期中，会在控制台打印出关键时间点信息以及错误信息，默认日志级别为 Warning，即只打印有问题的信息，基本流程信息不打印。一般在应用调试推送功能时，可将 PomeloClient 的 logLevel 设置为 Debug 级别以打印出所有调试信息。

* 远端日志：在 SDK 生命周期中，错误信息会通过 PomeloClientDelegate 中的 - (void)pomeloLog:(NSString *)log; 方法回调给应用，产品使用方可将此日志传输到各自的远端日志系统中以便以后查询错误日志。默认日志级别为 Warning，修改远端日志级别请设置 PomeloClient 的 remoteLogLevel 属性。此日志级别一般不建议修改。注意：不要改为 Debug，Debug 日志中会有较多无需备份远端日志系统的非关键日志信息。

1. 获取推送服务中使用标识符 deviceId，

```objective-c
- (NSString *)deviceId;
```

1. 获取 OpenUDID，即设备Id

 PomeloClient 提供用户获取 OpenUDID 的接口，以方便用户可以根据设备来进行推送相关消息。注意此处返回与 -(NSString *)deviceId; 接口有区别：
 deviceId 会返回 "产品域-设备Id"。

```objective-c
+ (NSString *)getUDID;
```


# 六、网络处理说明

* 所有异步调用，无论成功还是失败，都会有一个`ResponseCode`通过回调接口返回. 

* 只要发起请求时返回yes，也就是发起成功，一定会回调返回

* 如果在回调返回前，多次发起同样的调用，只会通过回调返回一次

* 具体的错误码信息，请参考`PomeloClient.h`中的对应错误码的定义, 这里简单罗列一下:

```
200 成功
401 请求参数错误
420 非法的ProductKey
450 签名认证服务器错误
460 非法的签名
470 签名不存在
480 签名过期
600 其他的服务端错误
700 发起请求时网络异常
701 请求超时
```


# 七、本SDK的依赖说明

1. Reachability

SDK 依赖 `Reachability` [https://github.com/tonymillion/Reachability](https://github.com/tonymillion/Reachability) 库。为了避免与 Apple 官方的 [Reachability](http://developer.apple.com/library/ios/#samplecode/Reachability/Introduction/Intro.html) 冲突，所以加了前缀之后为 `PomeloReachability`，并且 Notification 的 name 改为 `pomeloReachabilityChangedNotification`。

应用如果要用到 `Reachability` 相关的功能，也可以直接用这个。

1. OpenUDID

SDK依赖了 `OpenUDID`[https://github.com/ylechelle/OpenUDID](https://github.com/ylechelle/OpenUDID), 并进行了改名，改名为Pomelo_OpenUDID.

1. MQTTKit

SDK的MQTT OC实现，是基于 [http://git.eclipse.org/c/paho/org.eclipse.paho.mqtt.objc.git/](http://git.eclipse.org/c/paho/org.eclipse.paho.mqtt.objc.git/), 进行了二次开发。原来的MQTTKit实现并没有完整实现MQTT协议的一些功能，我们SDK中，对其原始的实现进行了功能扩充。


# 八、注意事项

* 在 App 更新时，要重新调用一次 `register` 接口。如果有用户登录，则还需调用一次 `bind` 接口。


# 九、F&Q

1. 使用长连接和 APNS 接受消息各有什么优劣？

长连接：

  * 优点：消息到达更快，在用户关闭推送通知的情况下，也能收到消息。QoS 可控。
  * 缺点：如果指定消息走长连接，但是 App 在后台或者未打开，这时用户无法收到通知，只能在应用在下次打开时收到。

APNS：

  * 优点：用户在未打开应用，或者应用在后台时，能及时通知用户。
  * 缺点：用户可以关闭推送通知，QoS 不可控。消息发送速度稍慢。

1. SDK 中使用长连接和发送消息中使用长连接的区别？

   因为发送的消息是可以选择通道(长连接和 APNS)的，所以客户端也存在两种接受方式。如果在消息体中指定采用`长连接`，而客户端又未开启长连接，这时消息是无法到达的。

   只有当客户端开启了使用长连接，那么在发送消息时指定`长连接`才是有效的。当然这时 APNS 也是有效的。

   客户端开启长连接后，会略微比默认情况耗电耗流量，因为 SDK 要自动维护连接状况，发送心跳等。所以是否要用长连接特性，要根据自身业务需求综合考虑。

1. 遇到 Bug 或需要一些新特性支持怎么办？

   **特别注意：** 在 APNs 推送证书配置问题后，请首先 [证书配置](Docs/苹果证书配置.md) `第三部分--APNs与证书` ，查看完成后按照其中的 `脚本自测` 小节自行测试，如果测试通过但在应用中无法使用，再进行联系 <hzbaitianyu@corp.netease.com> ，务必自测后再进行沟通！

   此外，可以加入杭研推送服务交流群(1346602)，当 Push SDK 有更新时，会在该群进行通知，一般有问题尽量私聊，避免影响其他同事。

感谢大家支持！
