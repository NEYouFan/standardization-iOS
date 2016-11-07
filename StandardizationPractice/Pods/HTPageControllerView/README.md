HTPageControllerView
---
HTPageControllerView管理多个Controller，使得他们可以以整页的方式左右滚动。

![Mou icon](yx.gif)

特性
---
* 可配置Controller的最大缓存个数
* 在快速滑动Controller来不及显示时，可定制Controller的占位控件
* 接口类似UITableView，提供HTPageControllerViewDataSource和HTPageControllerViewDataDelegate

用法
---
HTPageControllerView使用类似于UITableView：

1. 创建HTPageControllerView

	```
	_pageControllerView = [[HTPageControllerView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    _pageControllerView.pageDataSource = self;
    _pageControllerView.pageDelegate = self;
    [self.view addSubView:_pageControllerView];
	```

2. 实现协议`HTPageControllerViewDataSource`

	```
	- (NSUInteger)numberOfControllersInPageControllerView
	{
    	return 4;
	}

	- (UIViewController*)pageControllerView:(HTPageControllerView*)pageControllerView viewControllerForIndex:(NSUInteger)index
	{
    	UIViewController *vc = [[TestPageViewController alloc] initWithNibName:nil bundle:nil withIndex:index];
    	return vc;
	}
	```

安装
---
###	CocoaPods

1. `pod 'HTPageControllerView' , :git=>'https://g.hz.netease.com/HTIOSUI/HTPageControllerView.git'`
2. `pod install`或`pod update`
3. \#import "HTPageControllerView.h"
	
系统要求
---

该项目最低支持`iOS 7.0`和`Xcode 7.0`

许可证
---

HTPageControllerView，详情见LICENSE文件。
