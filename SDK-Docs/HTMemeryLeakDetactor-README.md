### HTMemoryLeakDetector
`HTMemoryLeakDetector`是一个基于`FBRetainCycleDetector`自动检测iOS是否存在内存泄露以及引用循环的库。

### 特性
1. 实时的内存反馈，能在页面退出的时候检测对象有没有内存泄露。
2. 针对性的内存检查，对未被controller持有的变量（例如request）可以通过配置单独检查其是否释放；
3. 对于没有正常释放的类，打印出引用循环和ViewController-View堆栈。
4. 对于单个对象的释放进行延迟检测

### 用法
#### 自动检测
`HTMemoryLeakDetector`只要在初始化调用`enable`接口，即可在运行中自动检测ViewController、View的内存泄露。

```objectivec
[[HTMemoryLeakDetector sharedInstance] enable];
```

#### 白名单
如果某个对象被其它对象持有，可以实现协议`HTMemoryLeakProtocol`并在`isNeedDetectLeak`返回NO，程序将不会对其进行泄露检测。

```objectivec
@interface MyViewController : UIViewController<HTMemoryLeakProtocol>

@end
@implementation PopedViewController
-(BOOL)isNeedDetectLeak{
    return NO;
}
@end
```

如果是系统类本身就不会释放，也可以通过以下接口增加白名单：

```
-(void)addWhiteList:(nonnull NSArray *) whiteList;

[[HTMemoryLeakDetector sharedInstance] addWhiteList:@[@"UINavigationBar"]]
```

#### 绑定检测
对于未被ViewController持有的对象或者其它属性，如:request请求，可以调用接口绑定到指定的ViewController，在该ViewController被销毁时，会自动检测这些对象有没有被正常销毁。

```objectivec
@implementation MyViewController

-(void)loadContent{
	NSMutableURLRequest* request = [NSMutableURLRequest new];
	......
	[[HTMemoryLeakDetector sharedInstance] setSpecifyObject:request viewController:self];
}
@end
```

#### 延迟检测
如果你已经确定某个对象在一段时间后肯定会被释放，也可以调用如下接口进行检测，如下接口，3秒后会检测该对象有没有被释放。

```objectivec
    [[HTMemoryLeakDetector sharedInstance] detectObject:request afterDelay:3];
```

### 安装
CocoaPods

1. 在Podfile中添加

```
source 'https://g.hz.netease.com/HeartTouchOpen/HTSpecRepo.git'

pod 'HTMemoryLeakDetector'
```

### 系统要求
该项目最低支持`iOS 7.0`