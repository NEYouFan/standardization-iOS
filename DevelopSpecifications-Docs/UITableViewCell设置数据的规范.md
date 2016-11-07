# UITableViewCell设置数据的规范

UITableViewCell 的使用很常见，本文规范 UITableViewCell 设置数据的方法。  

## UITableViewCell 使用 model 访问数据
首先规范 UITableViewCell 用 model 属性访问数据，比如：  

	@property (nonatomic, strong) HTTestCellModel * model;
	
## UITableViewCell setModel的规范
只有一种 model 时，这样设置：

	-(void)setModel:(HTTestCellModel *)aModel
	{
		if (_model == aModel) {
        	return;
    	}
	    _model = aModel;
	    self.titleLabel.text = aModel.title;
	    //more attribute set...
	}

### 处理多种类型的model
实际开发中，一个 cell 可能需要处理不止一种类型的 model，以达到复用cell的目的。例如商品详情，订单信息等复杂的 cell ，其 subview 可能有5，6个，布局繁琐，这些 cell 之间的界面差异往往不大，只需要隐藏一个控件，修改一下背景色，就可以当成另一个 cell 使用。这就需要一个既能处理商品详情 cell model，又能处理订单信息 cell model 的 cell。  

复用的 cell 使用`id`类型的 model，在设置 model 方法中使用 `isKindOfClass:`方法确定 model 类型，一般的写法是这样的:

	-(void)setModel:(id)aModel
	{
		if (_model == aModel) {
        	return;
    	}
	    _model = aModel;
	    if ([aModel isKindOfClass:[HTTestCellModel class]]) {
	        HTTestCellModel * theModel = (HTTestCellModel *)aModel;
	        self.titleLabel.text = theModel.title;
	        //more attribute set...
	    } else if ([aModel isKindOfClass:[HTTestCellModelSec class]]) {
	        HTTestCellModelSec * theModel = (HTTestCellModelSec *)aModel;
	        self.titleLabel.text = theModel.title;
	        //more attribute set...
	    }
	}  
这样的写法存在两个问题。首先 `id` 类型在使用时一定要做强制转换，机械又重复。其次随着 model 类型增多，`if else` 越来越多，方法将变得越来越长，越来越臃肿。  

下面演示 HeartTouch 的解决方案：  
使用`id`类型的 model

	@property (nonatomic, strong) id model;
设置 model

	-(void)setModel:(id)aModel
	{
		if (_model == aModel) {
        	return;
    	}
	    NSMutableString * selectorName = [@"set" mutableCopy];
	    [selectorName appendString:NSStringFromClass([aModel class])];
	    [selectorName appendString:@":"];
	    SEL selector = NSSelectorFromString(selectorName);
	    
	    if ([self respondsToSelector:selector]) {
	#pragma clang diagnostic push //解除可能的内存泄露的警告
	#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
	        [self performSelector:selector withObject:aModel];
	#pragma clang diagnostic pop
	    } else {
	        NSAssert1(NO, @"unsupport cell class :%@", [aModel class]);
	    }
	}

要求开发者每添加一种 model 类型，都要实现一个设置新类型 model 的方法，这个方法的命名规则是 `"set" + model类名 + ":"` 。  
比如添加两个model类型， `HTTestCellModel` 和 `HTTestCellModelSec` ，需要分别实现 `setHTTestCellModel:` 和 `setHTTestCellModelSec:` 方法。  
首先，导入需要添加的model的头文件

	#import "HTTestCellModel.h"
	#import "HTTestCellModelSec.h"
再实现设置model方法
	
	-(void)setHTTestCellModel:(HTTestCellModel*)aModel
	{
	    _model = aModel;
	    self.titleLabel.text = aModel.title;
	    //more attribute set...
	}
	-(void)setHTTestCellModelSec:(HTTestCellModelSec*)aModel
	{
	    _model = aModel;
	    self.titleLabel.text = aModel.title;
	    //more attribute set...
	} 
这样不仅解决了 `id` 类型强制转换的问题，还将不同 model 的处理分散在不同的方法实现中，使得代码结构更加清晰。