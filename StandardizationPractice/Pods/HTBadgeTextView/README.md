HTBadgeTextView
---
HTBadgeTextView一个封装红点功能的控件。  
![image](images/redpoint.gif)
特性
---
* 支持红点设置边框以及自动增长的红点宽度（暂不支持高度的自动增长）
* 红点背景通过图片进行设置

用法
---

###显示文本的红点

![image](images/red.jpg =200x)

	_badgeTextView = [[HTBadgeTextView alloc] initWithInnerSize:CGSizeMake(20, 20) outerSize:CGSizeMake(22, 22) isRound:YES];
     //可以这样设置背景
	//_badgeTextView.innerImage = [UIImage imageWithColor:[UIColor redColor] size:CGSizeMake(20, 20)];
     //也可以这样设置
    _badgeTextView.innerBackground.backgroundColor = [UIColor redColor];
    //设置文本与innerBackground的padding
    _badgeTextView.padding = 10;
    //设置outerBackground与innerBackground的padding
    _badgeTextView.innerOuterPadding = 1;
    //设置是否需要根据文本宽度自动增长宽度
    _badgeTextView.needWidthAutoIncrement = YES;
    _badgeTextView.frame = CGRectMake(180, 110, 0, 0);
    _badgeTextView.outerBackground.backgroundColor = [UIColor randomRGBColor];
    [_badgeTextView setCount:0];
    [self.view addSubview:_badgeTextView];

###显示文本红点

	_badgeView = [[HTBadgeTextView alloc] init];
    _badgeView.text = _texts[0];
    _badgeView.needWidthAutoIncrement = YES;
    _badgeView.innerSize = CGSizeMake(30, 30);
    _badgeView.isRound = NO;
    _badgeView.innerImage = [UIImage imageWithColor:[UIColor randomRGBColor] size:CGSizeMake(30, 30)];
    _badgeView.padding = 10;
    _badgeView.origin = CGPointMake(180, 225);
    [self.view addSubview:_badgeView];


安装
---
###	CocoaPods

1. `pod 'HTBadgeTextView' , :git=>'https://g.hz.netease.com/HTIOSUI/HTBadgeTextView.git'`
2. `pod install`或`pod update`
3. \#import "HTBadgeTextView.h"
	
系统要求
---

该项目最低支持`iOS 7.0`和`Xcode 7.0`

许可证
---

HTBadgeTextView，详情见LICENSE文件。
     

	
	