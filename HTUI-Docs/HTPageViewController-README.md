# HTPageControllerView

HTPageControllerView管理多个Controller，使得他们可以以整页的方式左右滚动。

![image](Resources/HTPageViewController/HTPageControllerView.gif)

## 一、特性

* 可配置Controller的最大缓存个数
* 在快速滑动Controller来不及显示时，可定制Controller的占位控件
* 接口类似UITableView，提供HTPageControllerViewDataSource和HTPageControllerViewDataDelegate

## 二、用法

HTPageControllerView使用类似于UITableView：

### 1. 创建HTPageControllerView

	```
	_pageControllerView = [[HTPageControllerView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    _pageControllerView.pageDataSource = self;
    _pageControllerView.pageDelegate = self;
    [self.view addSubView:_pageControllerView];
	```

### 2. 实现协议`HTPageControllerViewDataSource`

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
	
## 三、安装

###	CocoaPods
pod 'HTPageControllerView'

## 四、系统要求

iOS 7.0及以上

## 五、许可证

HTBadgeTextView使用MIT许可证，详情见LICENSE文件。
