# UITableViewCell高度计算接口规范
UITableViewCell的高度获取，有多种实现方式：

1. 当UITableViewCell高度固定的时候，我们可能写出这样的代码：
	
	```	
	- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
		if (0 == indexPath.row){
		    return [SomeTableViewCell cellHeight];
		} else {
		    return 100;
		}
	}
	```
1. 当UITableViewCell高度会随着屏幕尺寸或者数据发生变化的时候，我们可能写出这样的代码：

		-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
			if (0 == indexPath.row){
				//protoCell在何处创建也有不同方式
		    	static SomeTableViewCell *protoCell;
		    	static dispatch_once_t onceToken;
    			dispatch_once(&onceToken, ^{
        			protoCell = [SomeTableViewCell new];
    			});
				protoCell.model = self.datas[indexPath.row];
			
				return [protoCell sizeThatsFits:CGSizeMake(ScreenWidth, FLOAT_MAX)].height;
			} else {
				return 100;
			}
		}

    如果采用约束布局，我们还要使用`-systemLayoutSizeFittingSize:`.

本规范目的为了统一获取UITableViewCell高度的接口。


## 适用范围
UITableViewCell高度计算。
	
### 计算Cell高度
规范使用[FDTemplateLayoutCell](https://github.com/forkingdog/UITableView-FDTemplateLayoutCell.git)第三方库计算UITableViewCell高度，pods的使用方式是在Podfile文件添加

	pod 'UITableView+FDTemplateLayoutCell', '~> 1.4'
更新Pod`pod update --verbose --no-repo-update`  
没有用Pods则需要下载[源码](https://github.com/forkingdog/UITableView-FDTemplateLayoutCell.git)，将Classes文件夹下所有的文件拖动到工程中。  

计算高度的方法是`-[UITableView(FDTemplateLayoutCell) fd_heightForCellWithIdentifier: configuration:]`，下面演示使用的步骤： 

#### 示例
 
导入头文件

	#import "UITableView+FDTemplateLayoutCell.h"

选择下列方法中的一种，注册TableViewCell  

1. UITableView在 storyboard 中设置了原型cell的 identifier
2. 使用`-registerNib:forCellReuseIdentifier:`注册cell
3. 使用`-registerClass:forCellReuseIdentifier:`注册cell

在协议`UITableViewDelegate`方法`tableView:heightForRowAtIndexPath:`中调用高度计算方法

	- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
		NSString *identifier = [self tableView:tableView identifierForRowAtIndexPath:indexPath];//用户自定义获取identifer的接口，identifer对应不同类型的cell的一种
		
		id model = [self modelForIndexPath:indexPath];//table view cell model
		
		return [tableView fd_heightForCellWithIdentifier:identifier configuration:^(id cell){
			//这个block负责配置 cell 的数据源，和'cellForRow'做的事情一致，如
			cell.model = model;
			cell.accessoryType = UITableViewCellAccessoryCheckmark;//cell样式
			cell.fd_enforceFrameLayout = YES;//未使用Autolayout的布局需要手动设置此开发，否则会得到错误的cell高度
		}];
	}

参数的详细解释：

identifier  必填，原型cell的identifier，规范上要求和cell类名一致，这个规范是为了多种cell类型的table view的代码优化;     
configuration 可选，配置cell的数据源，和`cellForRow`中做的事情一致。这个cell只是用于计算高度，不会真的显示；如果是静态cell，不需要这个block，设为nil。  

注意，采用非Autolayout布局时，TableViewCell需要实现`-sizeThatFits:`方法，并且必须在configuration的block中调用`cell.fd_enforceFrameLayout = YES;`，否则会得到错误的cell高度。使用约束布局，没有此要求。  
`-sizeThatFits:`的实现如下

	@MyTableViewCell
	- (CGSize)sizeThatFits:(CGSize)size {
    	CGFloat totalHeight = 0;
    	totalHeight += [self.contentLabel sizeThatFits:size].height;
    	totalHeight += 10; // margins
    	return CGSizeMake(size.width, totalHeight);
	}
	@end
如果是静态cell，在该方法中直接返回常量。

### 缓存Cell高度
为避免UITableViewCell高度的重复计算，需要缓存高度计算结果，将`- (CGFloat)fd_heightForCellWithIdentifier:(NSString *)identifier
                            configuration:(void (^)(id cell))configuration`替换成`- (CGFloat)fd_heightForCellWithIdentifier:(NSString *)identifier
                         cacheByIndexPath:(NSIndexPath *)indexPath
                            configuration:(void (^)(id cell))configuration`或者`- (CGFloat)fd_heightForCellWithIdentifier:(NSString *)identifier cacheByKey:(id<NSCopying>)key configuration:(void (^)(id cell))configuration`即可。
                            
#### 示例
	                
	- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
		NSString *identifier = [self tableView:tableView identifierForRowAtIndexPath:indexPath];//用户自定义获取identifer的接口，identifer对应不同类型的cell的一种。使用多种cell的情况下，这个方法可以合并cellForRow和heightForRow中的代码。
		
		id model = [self modelForIndexPath:indexPath];//table view cell model
		
		return [tableView fd_heightForCellWithIdentifier:identifier cacheByIndexPath:indexPath configuration:^(MyTableViewCell * cell){
			//这个block负责配置 cell 的数据源，和'cellForRow'做的事情一致，如
			cell.model = model;//MyTableViewCell类包含一个属性 model，用于访问数据
			cell.accessoryType = UITableViewCellAccessoryCheckmark;//cell样式
			cell.fd_enforceFrameLayout = YES;//未使用Autolayout的布局需要手动设置此开发，否则会得到错误的cell高度
		}];
	}

两个方法中新出现参数的详细解释：

indexPath  使用与cell对应的indexPath记录cell高度;  
key  使用用户自定义cell的model的唯一标识符记录对应的 cell 的高度;   

如果需要清理缓存，需要主动调用UITableView的reload相关接口，譬如`reloadData`。并且当调用如`-deleteRowsAtIndexPaths:withRowAnimation:`等任何一个触发 UITableView 刷新机制的方法时，已有的高度缓存也将更新。


	