HTSegmentsView
---

HTSegmentsView 对一组子控件进行“单选”状态管理，并且支持选中状态的切换与动画。

![](images/demo.gif)
![](images/demo2.gif)


特性
---

* 支持自定义子控件排版、样式
* 支持状态切换过渡动画
* 提供常见子控件及过渡动画

用法
---


#### (1)创建SegmentsView,并设置其代理
```
HTSegmentsView *segmentsView = [[HTHorizontalSegmentsView alloc] initWithSelectedIndex:0];
segmentsView.frame = CGRectMake(30,100,260,50);
segmentsView.segmentsDelegate = self;
```

#### (2)创建并设置DataSource
`注意：segmentsView内部对datasource是弱引用，使用者需要保证datasource的生命周期。`

```
HTStringToLabelDataSource *dataSource = [[HTStringToLabelDataSource alloc] initWithArray:@[@"button1",@"button2",@"button3"] segmentCellClass:nil];
segmentsView.segmentsDataSource = dataSource;
```


#### (3)创建并设置过渡动画HTSegmentsViewAnimator
```
HTSublineSegmentViewAnimator *animator = [[HTSublineSegmentViewAnimator alloc] initWithSegmentsView:segmentsView backgroundColor:[UIColor lightGrayColor] lineColor:[UIColor greenColor] lineHeight:5];
segmentsView.animator = animator;
```

### 注意：
HTSegmentsView是继承自UIScrollView，为了避免NavigationController导致的`-64`的contentOffset问题，需要将HTSegmentsView所在的ViewController的automaticallyAdjustsScrollViewInsets属性设置为NO,或者在合适的时间将修改掉HTSegmentsView的contentOffset值。


安装
---
###	CocoaPods

1. pod 'HTSegmentsView' , :git=>'https://g.hz.netease.com/HTIOSUI/HTSegmentsView.git'
2. pod install
3. \#import "HTSegmentsView.h"
	

系统要求
---

该项目最低支持`iOS 7.0`和`Xcode 7.0`

许可证
---

HTSegmentsView使用MIT许可证，详情见LICENSE文件。