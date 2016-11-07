RestKit测试服务器配置方法
====================================================================================================
## 用途
RestKit 测试服务器可以用来支持RestKit的单元测试，服务器默认运行在本地，路径在HTHttp/RestKit/Tests/Server下；其对应的帮助文档为HTHttp/RestKit/Tests/README.md, 但其中部分已经过时且在安装过程中会遇到一些问题。本文档主要针对服务器的配置与启动列出实际的解决方案。

## 一 在用户目录安装Ruby
默认情况下，系统中已经安装了Ruby; 但如果直接使用系统的Ruby执行命令"gem install bundler"会报错，提示无权限。

	While executing gem ... (Gem::FilePermissionError)
    You don't have write permissions for the /Library/Ruby/Gems/2.0.0 directory.

尽管使用命令"sudo gem install bundler"可以获得权限安装bundler, 但会影响系统自定义安装的Ruby. 故推荐在用户目录安装Ruby. 步骤如下：

### 1 使用brew安装ruby

	brew install ruby    
	
在这之前可以使用命令"ruby --version"查看系统安装的ruby版本或者使用命令"which ruby"查看系统安装的ruby路径.

Note: brew安装有的时候会过慢，可以参考`http://heepo.github.io/%E5%B7%A5%E5%85%B7/2015/08/05/Homebrew-Mirror-Links.html`提供的方式更换合适的镜像.

### 2 修改环境变量
到自己目录下的.profile 或者 .bashrc 或者  .bash_profile

	/Users/Netease/.profile   

用emacs或是vim打开 （更改前请备份好这个文件，避免误操作）在文件的末尾加入

	# for brew install
	export PATH=/usr/local/bin:$PATH

然后重启终端，就可以用到了新的ruby了	. 此时执行which ruby会发现路径和系统安装的ruby路径不相同.

一点说明：实际操作中我机器上原本是没有这个.profile的，于是直接新建了这个文件并加入那段代码.

## 二 安装bundler

### 1 执行如下命令安装bundler

	gem install bundler

### 2 执行如下命令查看bundler是否安装成功

	gem list --local

## 三 通过Bundle安装其他组件
### 1 修改gemfile
在安装之前，需要修改HTHttp/RestKit目录下的gemfile; 将下面这行

	source "https://rubygems.org"
修改为：

	source "https://ruby.taobao.org/"
否则会不断提示安装步骤；

Note: 之前的地址`http://ruby.taobao.org`无法访问，需要更新为`https://ruby.taobao.org`.

### 2 安装
执行命令`bundle install`安装gemfile指定的组件.

### 3 执行命令`bundle`查看使用的组件.

### 4 可能发生的错误与解决方法
1 执行命令`bundle`时报错"Could not find rake-10.3.2 in any of the sources"
解决方法：bundle install可以自动安装上rake-10.3.2; 执行完毕后可以在gem list --local中查看rake对应版本是否可以安装上.

2 bundle install的时候报错：
An error occurred while installing i18n (0.7.0), and Bundler cannot continue.
Make sure that `gem install i18n -v '0.7.0'` succeeds before bundling.

运行`gem install i18n -v '0.7.0'`即可; 一般如果gemfile按照上面的步骤做过修改是不会报这个错误的.

3 报错：Make sure that `gem install nokogiri -v '1.6.6.2'` succeeds before bundling
解决方法：运行如下命令

	gem install nokogiri -- --use-system-libraries=true --with-xml2-include=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.10.sdk/usr/include/libxml2

Note: 请根据自己的系统版本信息调整上述路径，例如，当我的系统升级到最新的版本10.11后，上面SDK的路径就应该从`MacOSX10.10.sdk`调整为
`MacOSX10.11.sdk`.完成的命令如下：

	gem install nokogiri -- --use-system-libraries=true --with-xml2-include=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.11.sdk/usr/include/libxml2
	Building native extensions with: '--use-system-libraries=true --with-xml2-include=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.11.sdk/usr/include/libxml2'

然后继续执行bundle install即可.
参考：
http://ruby.zigzo.com/2015/03/18/installing-nokogiri-on-yosemite/

## 四 运行RestKit Test Server

按照RestKit原有的文档，执行命令`rake server`可以启动服务器；但实际操作中发现会报错，原因是server要求的rake版本是1.3.2; 而我系统上激活的rake版本为1.4.2; 这时换用如下命令可以正常启动服务器:

	bundle exec rake server

## 五 检查测试服务器是否运行

浏览器中输入：
http://localhost:4567/



## 参考文档：
http://blog.csdn.net/maojudong/article/details/7920578