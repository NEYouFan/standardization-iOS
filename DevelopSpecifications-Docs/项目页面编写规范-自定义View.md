# 自定义 View 编写规范 #

由于目前尚未深入调研 **xib** 以及 **storyboard** ，所以本文档中未描述使用 **xib** 或 **storyboard** 编写自定义 View 的规范(目前团队内尚不推荐使用 **xib** 或 **storyboard** )。本文档根据苹果有关规范以及实际项目开发中的经验，明确了使用代码编写 **UIView** 控件时的规范。


## 一、UIView 初始化 ##

编写 **UIView** 子类时，在初始化实例时如果需要传入参数设置 View，则需要构建自己的 **指定初始化方法** 。 **指定初始化方法** 的编写规范应属于 **Objective-C** 语言规范，但鉴于实际项目中在编写 UIView 子类时犯错误较多，所以此处参考 **Objective-C** 构建 **指定初始化方法** 的规范，针对 **编写 UIView 子类的初始化方法** 给出如下规范：

1. 在自己的 **指定初始化方法** 中一定要调用父类的 **指定初始化方法** ，并且在初始化时需要做的其他工作应在 **指定初始化方法** 中执行(如加载子视图)。 **UIView** 的 **指定初始化方法** 是： `- (instancetype _Nonnull)initWithFrame:(CGRect)aRect` 。

1. 在明确 **指定初始化方法** 后，自定义类的 **其他** 初始化方法均应调用 **指定初始化方法** ， 包括 `initWithFrame:` 方法。由于 `init` 方法会调用 `initWithFrame:` 方法，所以 `init` 方法可不重写。

1. 自定义 **UIView** 子类的所有初始化方法返回类型均应为 `instancetype` ，不要返回 `id` 。

1. **UIView** 子类中的其他方法(即非初始化方法)不应该以 `init` 作为开头。

1. 自定义的初始化方法应该以 `init` 开头，init 后应紧跟大写字母。例如： `initWithName:` 正确，而 `initwithName:` 错误。

下面给出具体示例说明以上规范在实际使用中的应用。其中： **ClassA** 继承自 **UIView**

`ClassA interface` ：

	@interface ClassA : UIView
	@property (nonatomic, assign) NSInteger age;
	@property (nonatomic, copy) NSString *name;

	- (instancetype)initWithName:(NSString *)name; // 自定义初始化方法
	- (instancetype)initWithAge:(NSInteger)age; // 自定义初始化方法
	- (instancetype)initWithName:(NSString *)name age:(NSInteger)age; // ClassA 的指定初始化方法

	// 规范3规定：如将上一个方法以如下方式声明则不正确：返回类型不正确，应该返回instancetype
	- (id)initWithName:(NSString *)name age:(NSInteger)age; 
	// 规定5规定：init后的第一个字母应该大写，所以此声明不正确。
	- (instancetype)initwithName:(NSString *)name age:(NSInteger)age;
	@end

`ClassA implementation` ：

	@implementation PSLoadingView

	// ClassA 的指定初始化方法
	- (instancetype)initWithName:(NSString *)name age:(NSInteger)age {
		// 规范1规定：一定要调用父类的指定初始化方法
		if (self = [super initWithFrame:CGRectZero]) {
			// 规范1规定：初始化实例时需要做的工作在指定初始化方法中执行
			[self loadSubViews];
		}
		return self;
	}

	// 规范2规定：除init方法外的所有初始化方法均需要调用本类的指定初始化方法
	- (instancetype)initWithFrame:(CGRect)frame {
		if (self = [self initWithName:nil age:0]) {}
		return self;
	}

	- (instancetype)initWithName:(NSString *)name {
		if (self = [self initWithName:name age:0]) {}
		return self;
	}

	- (instancetype)initWithAge:(NSInteger)age {
		if (self = [self initWithName:nil age:age]) {}
		return self;
	}

	// 规范4规定：非初始化方法，不应以init开头。需更换方法名，例如本方法可改名字为：getInitialValues:.
	- (void)initValues {}

	@end

以上示例清晰展示了如何编写 **UIView** 子类的初始化方法。更进一步，如果有一个类 **ClassB** 继承自 **ClassA** ，那么也需按照规范进行定义初始化方法，只不过与上面示例不同的是 **ClassB** 的指定初始化方法需要调用 **ClassA** 的指定初始化方法 `- (instancetype _Nonnull)initWithFrame:(CGRect)aRect` 而不是 `initWithFrame:` 。


## 二、添加子View ##

在为View添加子视图时请遵守如下规范：

1. 应在 **指定初始化方法** 中为 View 添加子视图。

1. 添加子视图的代码应该封装在 `- (void)loadSubViews` 私有方法中。

1. 一般无需为每个子视图创建私有方法进行创建及一些视图属性赋值等操作，放在 `- (void)loadSubViews` 私有方法中即可。但是，也有例外情况，如下条所述。

1. 当一个子视图创建及初始化代码较多时(比如超过15行)，可以考虑将该子视图的相关代码从 `- (void)loadSubViews` 中分离到一个新的私有方法中。新的私有方法采用 `loadXXX` 规则命名。

1. 对新添加的子视图的布局请参考 **布局子View** 规范。

1. 如无需要，不要将子视图在 `@interface` 中声明，应该在 `extension` 中声明。也就是说，自定义 View 时尽可能减少与外界的接口，降低控件与外界耦合度。


## 三、布局子View ##

对子View进行布局时，使用如下两种方案：

* 基于 frame 布局
* 基于 Auto Layout 约束布局


### 基于 frame 布局 ###

在使用 **frame** 进行子View的布局时请遵守以下规范：

1. 在初始化子视图时，不要设置子视图的 **frame** ，设置子视图 **frame** 的过程应该全部放在 `layoutSubViews` 方法中。

1. `layoutSubViews` 中一定要调用父类的 `layoutSubViews` 方法，有两种方式：

	* 当子类需要自定义父类已有的某些子视图布局时，应在方法开始处调用父类 `layoutSubViews` 。这样会先按照父类方法布局，再进行子类布局。
	* 当子类希望保持父类已有的子视图布局时，应在方法结尾处调用父类 `layoutSubViews` 。这样会先按照子类布局，再进行父类布局，子类布局不会覆盖父类的布局。

1. [HTCommonUtility](https://git.hz.netease.com/mobile/HTCommonUtils/tree/master/HTCommonUtility) 中有一个 **Category** ： UIView+Frame 可以简化通过 **frame** 进行布局的代码。 **推荐使用** 。

1. `layoutSubViews` 会在自身 **bounds** 变化时调用，当 **UIScrollView** 滚动时会频繁调用 `layoutSubViews` 方法进行子视图布局，如果自定义了 **UIScrollView** 的子类，而且在布局时做了较多布局，则可能影响性能。此处给出一种常用的优化方案：如果子视图只有在 **scrollView** 的 **size** 变化时才需要布局，则可以把前一次 **size** 缓存，在 `layoutSubViews` 中先判断 **size** 是否更新，如果更新则重新布局，否则无需重新布局。

1. 如果你的控件需要根据内容自适应调整大小，则需要重写 `- (CGSize)sizeThatFits:(CGSize)size` 方法。在该方法依据子视图的布局和大小，计算并返回符合子视图布局的最佳视图大小。重写该方法后，便可在 View 外部设置了内容后调用 `sizeToFit` 方法进行 View 自适应大小的调整。

1. 如果某些操作导致 View 的视图需要重新布局，则可调用 `- (void)setNeedsLayout` 或 `- (void)layoutIfNeeded` 方法。注意一定不能手动调用 `-(void)layoutSubviews` 方法来重新布局。


### 基于 Auto Layout 约束布局 ###

在使用 **Auto Layout** 进行子视图布局时请遵守以下规范：

1. 为了代码简洁统一，目前团队进行约束布局均使用 [Masonry开源库](https://github.com/SnapKit/Masonry) ，请首先学习如何使用 **Masonry库** 并在实际约束布局中使用该库。

1. 使用约束布局子视图，只需要在子视图创建时加入约束即可。不要在 `layoutSubViews` 方法中重新布局已经加入约束的布局，否则会引发布局混乱或者代码维护成本提高。

1. 在对自定义控件与其他控件进行约束布局时，需要在约束条件中指定自定义控件的大小或者重写自定义控件的 `- (CGSize)intrinsicContentSize` 方法。

1. 约束更新规范：当视图变化导致需要更新各个子视图的约束条件时，请调用 `- (void)setNeedsUpdateConstraints` 方法，并在 `- (void)updateConstraints` 方法中重写约束条件。

1. 为了应用的性能，在使用约束布局时，请认真考虑以下关键点：
   
		* 子视图之间的约束关系是否可转换为子视图与父视图之间的约束；

		* 当自定义 View 是需要快速滚动的 UITableView 的Cell子视图时，尽量不要使用约束进行布局。


## 总结 ##

本文档依据 **Objective-C** 以及 **UIKit** 相关规范，结合项目中实际经验，对如何使用代码进行自定义 **View** 给出了规范。由于编写 View 涉及到较多方面，所以本文档不会对所有行为进行规范，仅针对常用易出错的点进行了规范，本规范持续更新。
