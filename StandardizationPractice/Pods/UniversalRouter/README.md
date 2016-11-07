UniversalRouter
---
UniversalRouter ：使用URL来定位页面及页面导航。

特性
---
* 去中心化的URL配置方式
* 高性能的URL匹配算法，支持通配符和正则表达式
* 支持跨应用或web view和native请求的响应，http链接升级成native页面
* 支持单例、去循环等多种controller导航机制
* 支持navigation的全屏返回手势，方便的接口设置自定义转场动画

用法
---
###页面配置
配置页面，注册URL到Router
```
+ (HTControllerRouterConfig*)configureRouter
{
    HT_EXPORT();
    HTControllerRouterConfig *config = [[HTControllerRouterConfig alloc] initWithUrlPath:@"app://singleinstance/{id}"];
    return config;
}
```
     
###简单的接口
在有导航栏的页面中push一个页面
```  
#import "UIViewController+HTRouter.h"
[self pushViewControllerWithURL:@"app://aviewcontroller"];
```

###详细的接口
用push方式打开一个单例页面，如果已经存在这个页面，将该页面从页面栈中取出，不影响其他页面栈中的页面
```
HTControllerRouteParam *param = [[HTControllerRouteParam alloc] initWithURL:@"app://singleinstance/12" launchMode:HTControllerLaunchModePush];
//支持配置单例页面的
param.singleInstanceShowMode = HTControllerInstanceShowModeMoveToTop;
[[HTControllerRouter sharedRouter] route:param];
```

安装
---
###	CocoaPods

1. `pod 'UniversalRouter' , :git=>'https://g.hz.netease.com/HTIOSUI/UniversalRouter.git'`
2. `pod install`或`pod update`
3. \#import "UniversalRouter.h"
	
系统要求
---

该项目最低支持`iOS 7.0`和`Xcode 7.0`

许可证
---

UniversalRouter，详情见LICENSE文件。