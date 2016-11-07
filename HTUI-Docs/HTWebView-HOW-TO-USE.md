# HTWebView使用文档

## 一、简介

HTWebView是一套对WebView进行功能扩展的解决方案。集成了WebViewJavascriptBridge用于提供JavaScript与Navitve的通信，集成HTUniversalRouter支持页面导航，提供加载进度的反馈以及默认的加载进度条的实现，支持页面的滑动后退。

### 1. API介绍

* 构造函数

```objc
/**
 *  工厂方法，返回HTWebViewDelegate对象，支持设置自定义UIWebViewDelegate/启用JavascriptBridge/Web页加载进度显示/页面滑动返回
 *
 *  @param webView           UIWebView控件对象，用户负责维护其生命周期，即delegate对其为弱引用
 *  @param webviewDelegate   用户自行的实现了UIWebViewDelegate协议的对象
 *  @param bridgeEnabled     是否启用JavascriptBridge
 *  @param defaultHandler    对Javascript调用消息的默认响应block
 *  @param progressEnabled   是否启用web页加载进度显示
 *  @param progressView      用户自定义进度条，若progressEnabled为YES,则不能传入nil。
 *  @param navigationEnabled 是否启动滑动返回上一浏览页面功能；需注意，启用同时webView对象的scalesPageToFit属性会为设置为YES。非整屏宽度的webView暂不支持。
 *
 *  @return HTWebViewDelegate类型对象，需用户维护其生命周期
 */
+ (instancetype)delegateForWebView:(UIWebView*)webView
                   webviewDelegate:(id<UIWebViewDelegate>)webviewDelegate
            enableJavascriptBridge:(BOOL)bridgeEnabled
      withJavascriptDefaultHandler:(WVJBHandler)defaultHandler
                    enableProgress:(BOOL)progressEnabled
                  withProgressView:(UIView <HTWebViewProgressViewProtocol>*)progressView
           enableGestureNavigation:(BOOL)navigationEnabled;
```

* 获取JavascriptBridge

```
/**
 *  获取HTWebViewDelegate对象持有的WebViewJavascriptBridge对象，可通过该对象进行JavaScript与Navitve的通信机制
 *
 *  @return WebViewJavascriptBridge类型对象，用户不需要维护其生命周期
 */
- (WebViewJavascriptBridge*)javascriptBridge;
```

关于WebViewJavascriptBridge的使用文档，参考其[使用文档](https://github.com/marcuswestin/WebViewJavascriptBridge)。

### 2. 功能扩展和自定义说明

* 自定义UIWebViewDelegate

HTWebView兼容用户自定义UIWebViewDelegate，用户可以通过构造函数接口传入自定义UIWebViewDelegate， HTWebViewDelegate会负责通知代理事件。

```
/*ViewContrller遵循UIWebViewDelegate*/
MyViewContrller: UIViewController <UIWebViewDelegate>
```

* 自定义进度条

HTWebView提供了一种进度条的实现（HTWebViewProgressView），用户也可以根据需要，自定义进度条，自定义进度条需要遵循HTWebViewProgressViewProtocol，并实现进度变更通知方法，如下：

```
/*自定义进度条，需要遵循HTWebViewProgressViewProtocol*/
MyProcessView : UIView <HTWebViewProgressViewProtocol>

// liuchang 把上面的说明移到了代码里

/* 实现协议中的进度变更通知方法 */
- (void)setProgress:(float)progress animated:(BOOL)animated;

```

* 自定义页面返回

创建HTWebViewDelegate时，如果navigationEnabled参数传入YES，则开启了滑动页面返回功能，在webview页面中，通过自左向右滑动手势，可以实现页面的后退功能。用户也可以通过导航栏返回按钮进行返回按钮的功能定制，来决定是webview页面返回还是native页面返回，实现代码类似：

```
- (void)backButtonClicked:(id)sender
{    
    if ([_webView canGoBack]) {
        [_webView goBack];
    } else {  
		[self.navigationController popViewControllerAnimated:YES];
    }
}

```

* 与HTUniversalRouter结合使用，实现WebView到Native页面的跳转

HTWebViewDelegate中集成了HTUniversalRouter进行页面导航管理，可以实现WebView到Native页面的跳转。如若需要HTWebView与HTUniversalRouter 结合使用，使得WebView有跳转到本地页面的能力，需要定义全局宏开关`SUPPORT_CONTROLLER_ROUTER`，这样，当构造函数传入的WebViewDelegate，JavascriptBridge，ProgressView对跳转请求都响应（没有实现`webView:shouldStartLoadWithRequest:navigationType:`方法）或者响应请求且返回YES时，HTWebView会将跳转请求发送给HTUniversalRouter处理，如果HTUniversalRouter能够找到对应的页面资源，则可以实现到Native页面的跳转。关于HTUniversalRouter的使用，参考其[使用文档](https://g.hz.netease.com/mobile-ios/Standardization/blob/master/HTUI-Docs/HTRouter-README.md)。
