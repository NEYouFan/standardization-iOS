##ColorTouch大作业服务器配置
1. 安装nodejs

		brew install node

2. 运行脚本

		node ./myServer.js
		
##API

假设服务器ip为：192.168.0.1 可以通过 ifconfig en0， 无线网络通过  ifconfig en1 来查看
如果服务器在本机启动，则使用localhost即可.

在测试Post之前，需要安装并启动redis-server.

启动命令如下:


1. 获取用户积分信息
	
	http://192.168.0.1:3000/user

2. 获取照片详情

	此接口采取分页，通过limit，offset来指定页数：
	
	http://192.168.0.1:3000/photolist?limit=20&offset=0  第一页
或者	http://localhost:3000/photolist?limit=20&offset=0  第一页
	
	http://192.168.0.1:3000/photolist?limit=20&offset=20 第二页
	
	依次类推。目前仅支持20项为一页。
	
3. POST
使用Simple REST Client可以测试Post功能.
Post示例：
http://localhost:3000/collection
Post内容为：
name=zzl&email=zzl@sina.com

4. 照片上传	

浏览器中输入http://192.168.0.1:3000/可以测试照片上传.

5  获取指定用户的照片详情

使用Post来获取；暂时只支持到用户名lwang作为示例;

url:
http://localhost:3000/collection

post内容为：
@{@"name":"lwang", @"password":"test", @"type":@"photolist"}.


