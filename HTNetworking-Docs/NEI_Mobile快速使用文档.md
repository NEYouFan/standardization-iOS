NEI_Mobile快速使用文档
---

本文主要描述如何快速上手使用HTNetworking框架以及NEI自动化生成网络请求代码并且自动集成到工程中。

## 一 前置条件
如果只需要生成工程，不用NEI和HTNetworking处理网络请求相关任务，则可跳过本章。

### 1 使用NEI定义请求数据类型与异步接口
nei相关介绍、步骤与帮助文档参见前端技术部[nei的帮助文档](http://nei.hz.netease.com/manual).

### 2 利用PodFile添加对工程HTNetworking的依赖
自动生成的代码依赖于[HTNetworking](https://g.hz.netease.com/HeartTouchOpen/HTNetworking), 需要在PodFile里添加对HTHTTP的依赖，如下：

	platform :ios, '7.0'
	pod 'HTNetworking', :git => 'https://g.hz.netease.com/HeartTouchOpen/HTNetworking.git', :branch => 'master'
	pod 'HTCommonUtility', :git => 'https://git.hz.netease.com/git/mobile/HTCommonUtils.git', :branch => 'master'

CocoaPods的使用不在本文档描述范围内，HT组同学可以参见:
[CocoaPods的安装和使用](https://git.hz.netease.com/hzzhangping/heartouch/blob/master/docs/Xcode/Cocopods/CocoaPods%E7%9A%84%E5%AE%89%E8%A3%85%E5%92%8C%E4%BD%BF%E7%94%A8.md)

无权限的同学可以参见:
[CocoaPods安装和使用教程](http://code4app.com/article/cocoapods-install-usage)

## 二 工具安装

### 1 安装node.js

相关工具基于 Node.js 平台，因此需要使用者先安装 Node.js 环境，Node.js 在各平台下的安装配置请参阅官方说明。

	需要安装的 Node.js 版本须为 v4.2 及以上

### 2 安装nei工具

正式版本的工具安装命令:
	
	npm install nei –g
	
更新命令:

	npm update nei –g	

测试版本的安装命令:
	
	npm install "genify/nei#master" -g

详细安装指令参照`https://github.com/genify/nei`.

## 三 NEI Mobile自动生成工程
### 1 提供工程模板
可以选择自己制作工程模板，也可以选择现有的工程模板；现有的工程模板与目录结构参见: [模板工程](../%E6%A8%A1%E6%9D%BF/%E6%A8%A1%E6%9D%BF%E5%B7%A5%E7%A8%8B); 其中每一个文件夹代表一个工程模板.

推荐直接采用已制作好的完整工程模板，当前提供的完整工程模板包括:
[HTTemplate](../模板/模板工程/完整Xcode工程模板/HTTemplate)

自己制作工程模板的方法与步骤参见：[如何使用nei自动生成ios工程](工作流程/如何使用nei自动生成ios工程.md)。

由于工程模板中的配置文件需要更改，因此推荐将模板拷贝到单独的文件夹中。

### 2 配置build.json与NEIKey.json两个配置文件
以工程模板`HTSingleView`为例，包含模板文件夹`HTSingleView`以及两个配置文件`NEIKey.json`和`build.json`; 链接参见：

`NEIKey.json`指明模板文件中需要替换那些字段，不属于模板的一部分，是模板化的必需配置文件，示例如下：

	{
		"ProductName": "Yanxuan",
		"Prefix": "XYZ",
		“CategoryPrefix”:"xyz"
	}

即模板文件夹`HTSingleView`中所有的`{{ProductName}}`会被替换为实际的产品名`Yanxuan`, 所有的`{{Prefix}}`会被替换成为实际的前缀`XYZ`.   

`build.json`不属于模板的一部分，是执行`nei`命令时的参数配置文件，所有的项目与`nei`命令的参数对应, 示例如下：

	{
		"t": "mobile",
		"l": "oc",
		"w": true,
		"p": "",
		"tp": "HTSingleView/",
		"resOut": "Common/Network/", 
		"tdp": "NEIKey.json"
	}

对于iOS工程来说，只涉及到以上这些参数，参数描述如下：

1. "t": type, 工程类型，对于iOS，固定为mobile
2. "l": language, 语言类型，暂时只支持Objective-C, 固定为oc
3. "w": 是否覆盖，暂时只支持true，固定
4. "p": project的output path; 即nei生成的.xcodeproj文件会放在该目录下; 可以是全路径，也可以是相对于`build.json`文件的相对路径; 一般填写相对路径即可; 默认情况下会在当前路径;
5. "tp": 模板文件夹路径，这里的模板文件夹也就是包含{{ProductName}}文件夹的那个文件夹；可以是全路径，也可以是相对于`build.json`文件的相对路径; 一般填写相对路径即可;
6. "resOut": 从nei获取下来的资源数据生成的Models和Requests的路径, 主要是相对于工程文件夹的路径；由于通常情况下，实际路径一定是在以产品名命名的文件夹路径下，因此，在执行`nei build`的过程中，会将命令行中指定的产品名`productName`加在resOut路径的第一层目录中，即"resOut"是相对于`{{ProductName}}`文件夹的路径；
7. “tpd”: 模板替换配置文件的路径，现在固定为`NEIKey.json`.

Note: 实际生成工程中，为简化使用，不再需要每次配置这两个文件，只需要在命令行中指定产品名`productName`与`namePrefix`即可。


### 3 执行命令生成工程

	nei build 11029 -c build.json --productName YunweiStone --namePrefix YWS
	
其中:

1. 11029是项目id; 
2. -c是指定配置文件;
3. `productName`指定产品名; 该参数必须在命令行指定，并且会自动替换`NEIKey.json`中的`ProductName`, 也就是会替换工程模板中出现的所有`{{ProductName}}`.
4. `namePrefix`指定产品代码前缀; 该参数也必须在命令行指定；指定后，`NEIKey.json`中的`Prefix`会自动替换为该参数的值，`CategoryPrefix`会替换为该参数的小写形式，也就是会替换工程模板中出现的所有`{{Prefix}}`与`{{CategoryPrefix}}`; 同时该前缀也是自动生成的网络请求代码的前缀;

例如：

	nei build 11029 -c /Users/netease/Documents/TestProjects/NEI_Test/iostpl/build.json --productName YunweiStone --namePrefix YWS

如果原工程模板中文件夹并没有添加到`.xcodeproj`文件中，那么可以指定参数`--updateProject`，在执行`nei build`命令时将模板文件夹下的文件添加到工程中.
	
	nei build 11029 -c /Users/netease/Documents/TestProjects/NEI_Test/iostpl/build.json --productName YunweiStone --namePrefix YWS --updateProject
	
注意：

1. **build.json、productName、namePrefix三个参数必须在命令行中提供；否则无法正确生成正确的工程;**
2. build.json可以使用全路径或者相对路径；但是如果路径不正确，会使用默认工程模板生成，而默认工程模板是Web工程，因此会生成一个无用的Web工程; **推荐到build.json所在目录下执行nei build命令**
3. 默认情况下，新生成的工程文件夹与`build.json`在同一目录下并且以`productName`命名.
4. 11029是NEI项目id, 可以从对应的NEI项目中自动生成Models与Requests文件并添加到工程；如果该NEI项目下没有定义接口与数据类型，那么不会自动生成Models与Requests; 但如果指定的是不存在的NEI项目id, 则不会生成工程，至少必须在NEI上新建一个项目。 后续可以参照第四章`NEI Mobile自动生成与更新网络请求代码`的命令生成与更新请求文件。
5. `--updateProject`参数的含义：默认情况下，除了自动生成的Models和Requests外，`nei build`命令不会在Xcode工程文件.xcodeproj中添加group和文件信息，适用于完整工程模板，即.xcodeproj文件中已经包含了group和文件信息的情况。如果用户希望指定

### 4 编译检查与修正
1. 如果模板中包含了PodFile, 那么需要执行`pod update`或者`pod install`来安装相应依赖库;
2. 编译并修正可能的编译错误.


更多详细步骤与介绍参见：[如何使用nei自动生成ios工程](工作流程/如何使用nei自动生成ios工程.md)

## 四 NEI Mobile自动生成与更新网络请求代码
### 1 执行命令
	
	nei mobile 11029 --namePrefix YW -o ProjectPath -resOut YunWei/Network/

参数:

* 11029: NEI项目id, 必填并且必须是有效的NEI项目
* -namePrefix: 生成的请求与Model的前缀; 一般与整个工程的前缀一致；
* -o 指明工程文件.xcodeproj所在的目录的路径，可以是绝对路径也可以是相对路径；如果没有，会在当前路径下搜索工程文件`.xcodeproj`；如果找不到，不会更新工程文件；
* -resOut 指明生成的Models与Requests相对ProjectPath的路径，后面一定要以`/`结尾, 否则不是完整的路径; 第一层目录必须是工程名或者工程中的第一层Group名，否则无法正确添加到工程文件中.


### 2 .gitignore 

选择将下面两行添加到.gitignore文件，这样nei生成的项目相关信息不会被上传到代码服务器，仅最新的nei-latest.json文件可以上传代码服务器;

	nei-20*.json
	nei-20*.txt

### 3 更新

在NEI上更新异步接口定义与数据类型定义后，继续执行上述命令可以更新到本地工程:

	$ nei mobile 11029 --namePrefix YW -o ProjectPath -resOut YunWei/Network/

如果在工程文件所在目录执行该命令，可以省略`-o`参数:

	$ nei mobile 11029 -w true --namePrefix YW -resOut YunWei/Network/


更多详细步骤与介绍参见：[HTHTTP代码自动生成工作流程](工作流程/HTHTTP代码自动生成工作流程.md)

### 4 强制更新

正常情况下，如果接口管理平台上的数据类型和接口定义没有发生过变化，那么不会更新工程文件；如果希望强制更新工程文件，例如，接口没有变化，但是前缀发生变化了，那么可以添加`--force`参数或者`-f`参数，此时会强行更新工程文件，确保`Models`和`Requests`目录下的文件正确添加到工程中，示例：

		nei mobile 11029 --namePrefix YWM -resOut YunWei/Network/ -f

## 五 常见问题
Q: 自动生成工程, 只生成了一个Web工程  
A: 可能原因：a build.json路径错误； b build.json中模板文件夹路径错误

Q: Models与Requests未自动生成  
A: 可能原因: a nei项目编号出错 b resOut参数不正确

Q: Models与Requests文件生成，但未正确添加到工程中  
A: 可能原因: a project的path不正确 b resOut第一层路径参数不正确，可以尝试着换成工程名 c 工程组织结构不正确，检查是否正确生成了与工程名同名的Group.

Q: `nei build`生成新工程后，在`CocoaPods 0.39`下执行`pod install`, 然后`nei mobile`更新代码时失败;
A: Known issue. 这个是由于CocoaPods的bug造成的；参见[iOS: nei mobile解析Cocoapods 0.39版本更改后的工程文件出错 #21](https://github.com/NEYouFan/nei-toolkit/issues/21)

## 六 参考资料
1. [nei工具使用说明](https://github.com/NEYouFan/nei-toolkit)
2. [如何使用nei自动生成ios工程](工作流程/如何使用nei自动生成ios工程.md)
3. [HTHTTP代码自动生成工作流程](工作流程/HTHTTP代码自动生成工作流程.md)
4. [HTHTTP使用文档](https://g.hz.netease.com/HeartTouchOpen/HTNetworking/blob/master/README.md)


