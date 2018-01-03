# 版本支持

xcode7及以上


# 命令参数
```
HearTouch iOS Package Script
Author: jw
Usage:
Example: sh htbuild.sh --env="ad-hoc" --signIdentity="iPhone Distribution: zhongkai song (SM77JMFHDC)" --provisioning="jw-distribute" --workspacePath="/Users/jw/mycode/xcode/JWXCBuildTest" --workspaceName="JWXCBuildTest"
参数说明:
 --env               [必选] 打包环境(exportOptionsPlist)，名称需要与config目录下的plist文件名相同，如：ad-hoc" 
 --workspacePath     [必选] workspace路径，如/Users/jw/JWXCBuildTest"
 --workspaceName     [必选] workspace名称,不带xcworkspace后缀，如JWXCBuildTest"
 --signIdentity      [可选] 签名证书，如：iPhone Distribution: zhongkai song (SM77JMFHDC)，如果不设置，则采用工程配置"
 --provisioningUUID  [可选] provisioning_profile UUID，如果不设置，则采用工程配置"
 --scheme            [可选] xcode scheme名称，默认与workspaceName相同"
 --plistPath         [可选] 项目plist相对路径，相对于workspace文件路径，默认使用./workspaceName/Info.plist"
 --buildConfig       [可选] Debug or Release，默认Release"
 --version           [可选] 大版本号，默认使用工程配置版本号"
 --buildVersion      [可选] build版本号，默认使用工程配置版本号"
 --distDir           [可选] 打包输出目录，默认当前目录下创建dist目录"
 --keychain          [可选] 证书所在keychain，默认login"
 --keychain_password [可选] 本机Keychain Access解锁密码，用于做证书是否存在验证，如果不传，则不做证书验证"
  
```

# 使用步骤

1. 修改htbuild.sh中的keychain_password="mycomputer-password" 为本机Keychain Access解锁密码
2. 拷贝一份config/template.plist，根据需要打包的类型重命名文件并修改内容，脚本--env参数传入的文件名需与该文件名相同

	* teamID：在开发者中心查看Member Center -> Your Account -> Account Summary -> Developer Account Summary
	* method：根据开发者证书类型，选择其中一种，app-store , enterprise , ad-hoc , development
	
3. 可以直接使用命令行打包，也可以参照bin/ad-hoc.sh书写脚本文件进行打包。

# 补充说明 
4. 输入内容保存在打包输出目录（使用distDir参数指定，默认是当前目录下创建dist目录）目录下，自动生成的${workspaceName}-${buildConfig}-${version}-${buildVersion}子目录中。内容包括archive文件、ipa文件、日志文件。
4. 日志信息会保存在打包输出目录（使用distDir参数指定，默认是当前目录下创建dist目录）下${workspaceName}.build.log文件中，如果打包出错可以查看输入日志信息。


4. 打包脚本中的ad-hoc相关是示例，用于打包发布版本的脚本文件，如果是开发版本或者其他版本需要按照使用文档做修改，不要直接使用。

# 常见错误记录

1. `Error Domain=IDEDistributionErrorDomain Code=1 "(null)"`
 
#### 原因一：
 
The problem
 
Apple's WWDR certificate expired on 14/02/16 and simply replacing this certificate with the new one should solve the issue.

The fix

* Download the new certificate https://developer.apple.com/certificationauthority/AppleWWDRCA.cer
* Open keychain and remove the expired certificate from login and system
* Add new certificate

 参考：http://ajmccall.com/idedistributionerrordomain-code-1-error-and-fastlane/
 
#### 原因二：
 
 证书与--env的plist中描述信息没有对应,例如ad-hoc必须使用发布证书,development必须使用开发证书。
