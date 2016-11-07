# CocoaPods  

### 介绍

CocoaPods 是开发 OS X 和 iOS 应用程序的一个第三方库的依赖管理工具。利用 CocoaPods，可以定义自己的依赖关系 (称作 pods)，并且随着时间的变化，以及在整个开发环境中对第三方库的版本管理非常方便。

#### 安装
1. Mac下自带ruby,使用ruby的gem命令即可： 
    
		$ sudo gem install cocoapods
		$ pod setup
		如果更新到最新版本的mac 10.11系统，发现安装不了cocopods，更为如下安装方式
		$ sudo gem install -n /usr/local/bin cocoapods

2. 上述如果失败，可以升级gem

		$sudo gem update --system
3. 另外，ruby的软件源rubygems.org因为使用的亚马逊的云服务，所以被墙了，需要更新一下ruby的源，如下代码将官方的ruby源替换成国内淘宝的源：

		gem sources --remove https://rubygems.org/
		gem sources -a http://ruby.taobao.org/
		gem sources -l
4. pod setup在执行时，会输出Setting up CocoaPods master repo，会等待比较久的时间。这步其实是Cocoapods在将它的信息下载到 ~/.cocoapods目录下。也可以将CocoaPods设置成使用gitcafe镜像提高下载速度。（非必须）

		pod repo remove master
		pod repo add master https://gitcafe.com/akuandev/Specs.git
		pod repo update

### 比较重要的两个文件
#### Podfile
Podfile 是一个文件，用于定义项目所需要使用的第三方库。该文件支持高度定制，你可以根据个人喜好对其做出定制。
#### Podspec
podspec 也是一个文件，该文件为Pods依赖库的描述文件,每个Pods依赖库必须有且仅有那么一个描述文件，描述了一个库是怎样被添加到工程中的。它支持的功能有：列出源文件、framework、编译选项和某个库所需要的依赖等。  

Podspec的使用请参考[CocoaPods自定义podspec](https://g.hz.netease.com/mobile-ios/document/blob/master/%E6%8A%80%E6%9C%AF%E6%96%87%E6%A1%A3/Cocopods/CocoaPods%E8%87%AA%E5%AE%9A%E4%B9%89podspec.md)
#### 使用
1. 首先新建一个名为Podfile的文件，放在工程根目录下面，列出所要依赖的库. 
	* 简单地使用Podfile
	        platform :ios  
			# 后面数字是指定的是pod的版本号  
			pod 'JSONKit',       '~> 1.4'    
			#如果要最后一个版本使用:head  
			pod 'Objection', :head     
			pod "AFNetworking", "~> 2.0"  
			pod 'SDWebImage','~>3.4'  
			#已经配置了podspec文件，从源代码库中获取  
			pod 'AFNetworking', :git => 'https://github.com/gowalla/AFNetworking.git'    
			pod 'ColorTouch', :git => 'https://git.hz.netease.com/git/hzzhangping/ColorTouch-IOS.git'    
	* 添加多个包源仓库  
			source 'https://github.com/artsy/Specs.git  
			source 'https://github.com/CocoaPods/Specs.git'  
			platform :ios, '8.0'  
			#设置这句话可以有效抑制引入第三方代码库产生的warning  
			inhibit_all_warnings!     
			#不产生这个库的warning  
			pod 'SSZipArchive', :inhibit_warnings => true  
	* 使用本地工程  
			#../HTUI是相对于Podfile文件位置的相对路径，  
			#HTUI工程文件里面需要有podspec文件。当然也可以通过绝对路径来定义path  
			pod 'HTUI', :path => '../HTUI'  
	* 选择仓库分支  
			#dev分支  
			pod 'AFNetworking', :git => 'https://github.com/gowalla/AFNetworking.git', :branch => 'dev'  
			#版本号  
			pod 'AFNetworking', :git => 'https://github.com/gowalla/AFNetworking.git', :tag => '0.7.0'    
			pod 'AFNetworking', :git => 'https://github.com/gowalla/AFNetworking.git', :commit => '082f8319af'  
2. 执行如下命令即可：

		pod install

	1. 读取 Podfile 文件  
	   第一步是要弄清楚显示或隐式的声明了哪些第三方库。在加载 podspecs 过程中，CocoaPods 就建立了包括版本信息在内的所有的第三方库的列表。Podspecs 被存储在本地路径 ~/.cocoapods 中。
	2. 版本控制和冲突
	3. 加载源文件  
	   每个 .podspec 文件都包含一个源代码的索引，这些索引一般包裹一个 git 地址和 git tag。CocoaPods 将依照 Podfile、.podspec 和缓存文件的信息将源文件下载到 Pods 目录中。  
	4. 生成 Pods.xcodeproj
	5. 安装第三方库
	6. 写入至磁盘
	   Pods.xcodeproj 文件被写入磁盘，另外两个非常重要的文件：Podfile.lock 和 Manifest.lock 都将被写入磁盘。
	7. Podfile.lock  
	   这是 CocoaPods 创建的最重要的文件之一。它记录了需要被安装的 pod 的每个已安装的版本。如果你想知道已安装的 pod 是哪个版本，可以查看这个文件。推荐将 Podfile.lock 文件加入到版本控制中，这有助于整个团队的一致性。
	8. Manifest.lock	
	   这是每次运行 pod install 命令时创建的 Podfile.lock 文件的副本。如果你遇见过这样的错误 沙盒文件与 Podfile.lock 文件不同步 (The sandbox is not in sync with the Podfile.lock)，这是因为 Manifest.lock 文件和 Podfile.lock 文件不一致所引起。由于 Pods 所在的目录并不总在版本控制之下，这样可以保证开发者运行 app 之前都能更新他们的 pods，否则 app 可能会 crash，或者在一些不太明显的地方编译失败。
3. 如若更新了Podfile，可用

		pod update
4. 如果每次都是install和update。每次都会很慢。这是因为两个命令都会升级CocoaPods的spec仓库，只需使用下述方法即可

		pod install --verbose --no-repo-update
		pod update --verbose --no-repo-update
		
####注意事项
如果每次都使用--verbose --no-repo-update，则本地spec就一直没有更新，有可能在pod的时候版本出错。因此必须隔断时间使用`pod repo update`更新spec仓库。
####参考文件
更多Podfile信息 [Podfile 指南](https://guides.cocoapods.org/using/the-podfile.html)  
objc.io的文档[深入理解 CocoaPods](http://objccn.io/issue-6-4/)
