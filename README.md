# 一、介绍

iOS 标准化是促进 App 开发团队高效、高质量进行开发工作的一个完整的开发框架。标准化框架覆盖 App 开发过程中的方方面面，从常用开发工具的使用到团队开发规范，再到我们开发的控件库、网络库的使用，最后，我们也提供了保障工程质量的 APM、大白健康安全系统，以及常用的 SDK(比如 HTTPDNS、Push等)。	

使用标准化框架可以带来众多好处，比如：
1. 严格要求团队开发人员遵守 **标准化团队开发规范** ，可以保证团队各成员以一致的风格进行工作，减少不必要的协作冲突；
2. 标准化框架中的网络库结合 [NEI](https://g.hz.netease.com/HeartTouchOpen/nei_mobile) 可以减少大量网络层代码编写，提高业务的网络层开发效率，并可以降低出错概率；
3. 标准化框架中的控件库可以节省开发人员调研所需控件的时间，并防止为众多杂乱开源库填坑浪费时间；
   我们有相关开发人员会持续保证控件库的灵活性与可靠性，根据已使用控件库的产品反馈来看，目前处于良性循环；
4. APM 和大白健康安全系统可以帮助开发人员尽早发现工程中的隐藏 bug，并有完整的日志系统帮助开发人员定位问题，正当的使用可以在较短时间内提升工程质量；
5. 标准化框架中提到常用 SDK 大多是我们自己在维护与开发，有问题可以方便的进行沟通交流，减少使用第三方 SDK 带来的沟通困难问题。
6. 标准化框架中也制定了很多 UI 编写时的规范，等等...


# 二、深入学习标准化

上面对标准化做了简单的介绍，在下面会给出标准化框架的各个组成部分以及各部分的简介，本文档不包含标准化框架各组成部分的详细介绍以及学习指南，对于更详细学习指南请参考本仓库的 [wiki-标准化学习大纲](https://g.hz.netease.com/mobile-ios/Standardization/wikis/home)，[wiki-标准化学习大纲](https://g.hz.netease.com/mobile-ios/Standardization/wikis/home) 中对标准化的各个部分进行了细致的划分，并提供了丰富的学习文档供开发者学习。
		

# 三、组成部分

## 开发工具的使用

标准化框架介绍了多种常用的开发工具，包括网络处理工具(Charles, Wireshark, Network Link Conditioner)，UI处理工具(PhotoShop, xScope, Reveal)，以及开发时最常用的工具(Xcode, Cocoapods)。

熟练运用标准化框架介绍的各种开发工具可以极大的提升我们的开发效率及质量。

## 团队开发规范

应用开发一般是团队协作进行开发，为了保持团队成员工作方式的高效与统一，标准化框架给出了开发过程中团队各成员需要遵守的规范，主要包括：项目的 Git 使用规范，Objective-C 编码规范，Swift 编码规范，项目工程的文件组织规范，开发人员须知的视觉交互规范，项目中页面编写规范(自定义 View 的编写规范、静态 TableView 的编写规范)。

由于公司 Git 仓库对 Markdown 的语法支持略有差别，所以标准化也给出了在公司 Git 仓库编写 Markdown 应该支持的语法规范。

此外，对于 SDK 或其他公共库的开发者，标准化也规范了如何更好的编写 README 的规范。

## 控件库

开发页面时，有时会需要使用第三方控件来降低开发成本，但第三方库有如下缺点：

* 同一类第三方控件库会存在多个，需要花费人力进行调研相对较好的控件库；
* 第三方控件库往往质量参差不齐；
* 当第三方控件有 bug 或不能满足业务需求时，无法高效的与开发者沟通，只能自己修改源码，导致成本的逐渐提升；

标准化框架中给出了一些常用的控件，可以减少团队调研所需的时间，并且每个控件都有相关开发人员维护，可以及时有效的提出 bug 以及新的需求，标准化框架开发人员会尽力支持产品需求。

标准化框架中的控件库列表如下：

* HTSegmentView
* HTRefreshView
* HTPageViewController
* HTImageView
* HTAssetsPicker
* HTPopoverMenu
* HTRouter
* HTBadgeTextView
* HTToast
* HTWebView
* HTCommonUtility

此外，控件库仍会进行补充完善。
	
## 网络库

* NEI

	NEI是杭州研究院前端技术部提供的用于优化前后端接口的开发和测试的工作，可以在上面定义请求的异步接口与数据类型，并协助自动生成客户端的请求代码已经model的数据结构。同时还能根据工程模版自动化生成项目工程。

* HTNetworking
	HTNetworking是一个基于RestKit开发的iOS网络框架库，具有使用简单、高度可配置、扩展性强等特点，同时集成了cache等高级功能。
	
	具体优点如下：

		(1) 简单清晰的请求描述，高度可配置;
	
		(2) 提供Mock数据测试功能，无须服务器支持也能走通网络请求逻辑;
	
		(3) 强大的对象映射系统，网络请求返回数据与数据模型类(Model)自动映射;
	
		(4) 良好的扩展性，更方便替换与扩展底层网络请求库;
	
		(5) 集成cache、冻结请求、请求调度;
	
		(6) 解除RestKit与AFNetworking的耦合；

## SDK

TODO：简单的说明

* NAPM 

	NAPM是网易性能监控平台，用于监控、优化应用性能，提高应用的可靠性和质量。SDK支持：
	
		（1）统计应用http请求数据，如请求时间，数据，错误
		（2）收集页面交互性能数据
		（3）使用Ping，TraceRoute，和DNS检测工具（nstool.netease.com）诊断网络

* CandyWebCache

    CandyWebCache是移动端web资源的本地缓存的解决方案，能够拦截webview的请求，并优先使用本地缓存静态资源进行响应，以此来对webview加载页面性能进行优化。除此之外，CandyWebCache从功能模块设计和协议设计上支持扩展，支持其他资源进行下载更新，如hotfix、游戏资源包等。


		(1) 协议层拦截请求，透明替换响应
		(2) 静态资源版本控制及更新策略
		(3) 资源防篡改策略
		(4) 静态资源自动打包到应用，及首次安装解压处理

* Push

    Push SDK 是杭州研究院开发的用于客户端推送的开发组件，Push SDK 提供两种方式的推送：**长连接推送** 和 **基于APNs的推送** ：

		(1) 长连接推送具有实时性高以及低网络开销的优点
		(2) 基于APNs的推送利用苹果的推送服务进行客户端推送，
		(3) 两种推送方式可以灵活应用和切换，而且两者可以统一通过杭研的推送服务器进行推送消息的下发；

* HTTPDNS 

	遭遇 DNS 劫持？使用 HTTPDNS 获取 ip 吧。HTTPDNS 原理：
	
		(1) 使用 http 协议，向杭研服务器获取到域名对应的 ip，绕过运营商的 DNS 解析；
		(2) 直接使用这个 ip 发请求；
		
	SDK 提供的支持：
	
	    (1) 友好的接口；
		(2) ip 缓存功能；
		(3) 尽可能快、尽可能准确地让你每次都能拿到可用 ip；

* 大白健康安全系统
	
	大白安全系统主要目的在于可以监控app的健康情况，目前支持:
	
		(1) 内存泄漏监控
		(2) 循环引用监控。
	
	之后会推出 app 运行时的 crash 抓取机制，预计功能:
	
		(1)实时避免app绝大多数的崩溃，大大降低其crash率。
		(2)实现crash抓取之后的上报功能，通过后台可以实时查看app的崩溃数据，通过大数据分析来提醒使用方开发过程中需要注意的地方。


* URS 

	该 SDK 是 URS 为网易移动产品*登录*提供的全新解决方案。主要支持三大功能 :
	
		(1) 通行证账号登录 
		(2) 移动账号登录
		(3) 同一终端网易App共享登录

# 四、标准化框架的使用示例：iOS标准化学习大作业

* [大作业需求文档地址](https://g.hz.netease.com/mobile-ios/Standardization/tree/master/%E7%A7%BB%E5%8A%A8%E7%AB%AF%E5%AE%9E%E8%B7%B5%E5%A4%A7%E4%BD%9C%E4%B8%9A)
* [大作业参考demo地址](https://g.hz.netease.com/mobile-ios/Standardization/tree/master/StandardizationPractice)
* [大作业服务器地址](https://g.hz.netease.com/hzwangliping/TrainingServer/tree/master/CT%E5%A4%A7%E4%BD%9C%E4%B8%9A%E6%9C%8D%E5%8A%A1%E5%99%A8)