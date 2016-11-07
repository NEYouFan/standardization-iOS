NAPM
---
NAPM是网易性能监控平台，用于监控、优化应用性能，提高应用的可靠性和质量。
	

特性
---
* 统计应用http请求数据，如请求时间，数据，错误
* 收集页面交互性能数据
* 使用Ping，TraceRoute，和DNS检测工具（nstool.netease.com）诊断网络

用法
---
### 快速配置，打开监控功能
打开AppDelegate.m，导入头文件MAM.h    
在方法`application:didFinishLaunchingWithOptions`的第一行添加如下代码，启动监控功能：  

```
//使用默认配置，userID使用default_user  
[MAM startWithProductKey:@"ea276fd5fae94d99b5572aeba4a5516c"];
```
	
**注意：务必在应用刚启动后就打开NAPM，1.3.8以后，支持使用`setTraceEnable:`方法在启动后动态地开关网络请求和页面交互的监控。** 

### 网络诊断

网络诊断包含三个部分：

*	对特定域名执行Ping
*	对特定域名执行Trace Route 
*	执行DNS检测工具（nstool.netease.com） 

使用方法如下：

```
[MAM startNetDiagnoWithDomain:@"api.lofter.com" completeBlock:^(NSString *allLogInfo) {
        //get diagno result
    }];
```

#### 设置网络数据收集采样率

方法`+[MAM setSamplingRate:]`支持设置网络数据收集的采样率。


安装
---
### CocoaPods
在Podfile中添加  

```
pod 'MAM',:git=>'https://g.hz.netease.com/napm/napm-ios-pod.git'
```
更新Pod： `pod update --verbose --no-repo-update`  

### 常规方式
1. 下载[压缩包](https://g.hz.netease.com/napm/napm-ios-pod/repository/archive.zip?ref=master)  
  
2. 找到MAM静态库和MAM.h文件，拖动到Xcode工程目录中。

3. 添加5个库：

	• SystemConfiguration.framework

	• CoreTelephony.framework

	• libz.tbd

	• libsqlite3.tbd 
	
	• libresolv.tbd 
	
_Xcode配置：_  
**确认Build Settings的Other Link Flags中使用了-ObjC**  

系统要求
---

该项目最低支持`iOS 7.0`和`Xcode 7.0`

许可证
---

NAPM使用MIT许可证，详情见LICENSE文件。