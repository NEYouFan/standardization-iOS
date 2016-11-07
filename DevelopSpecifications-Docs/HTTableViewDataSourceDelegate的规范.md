# UITableView dataSource和delegate的规范
`UITableView`使用委托模式，使用时需要配置`dataSource`和`delegate`，一般会写在`UIViewController`中：

	- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
	{
	    return rowNum;
	}
	- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
	{
	    NSString *identifier = @"cellIdentifier";
	    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	    //cell model set
	    return cell;
	} 
这种写法存在两点问题： 
 
1. 每次配置table view都要写重复代码  
2. 增加了 view controller 的代码量  

本规范目是介绍`HTTableViewDataSourceDelegate`简化`UITableView`的代码。

## CocoaPods

1. 在Podfile中添加 `pod 'HTTableViewDataSourceDelegate', :git => 'https://g.hz.netease.com/HeartTouchOpen/HTTableViewDataSourceDelegate.git', :branch => 'master'`
2. 执行`pod install`或`pod update`

## 用法

导入头文件

	#import "HTTableViewDataSourceDelegate.h"
	#import "NSArray+DataSource.h" //数据列表在这里完成协议的遵守，参考下面对model参数的解释
	#import "MyCellStringModel.h"	//cell model类型
	#import "MyTableViewCell.h"		//cell类型，遵守协议HTTableViewCellModelProtocol
	
构造数据集合

	- (id <HTTableViewDataSourceDataModelProtocol>)arrayCellModels
	{
	    NSMutableArray * models = [NSMutableArray new];
	    for (NSString * arg in @[@"A", @"B", @"C", @"D", @"E", @"F"]) {
	        [models addObject:[MyCellStringModel modelWithTitle:arg]];
	    }
	    return models;
	}
构造 dataSourceDelegate实例

		[_tableview  registerClass:UITableViewCell.class forCellReuseIdentifier:@"UITableViewCell"];
		id <HTTableViewDataSourceDataModelProtocol> cellModels = [self arrayCellModels];//用户的数据列表
	    id <UITableViewDataSource, UITableViewDelegate> dataSource
	    = [HTTableViewDataSourceDelegate dataSourceWithModel:cellModels
	                                     cellTypeMap:@{@"MyCellStringModel" : @"MyTableViewCell"}// 数据类到cell类名的映射
	                               tableViewDelegate:self
	                               cellConfiguration:
	       ^(UITableViewCell *cell, MyCellStringModel * model, NSIndexPath *indexPath) {
	        if (indexPath.row % 2 == 0) {
	            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	        }
	    }];
	    
使用dataSourceDelegate

		self.demoDataSource = dataSource;//持有 dataSource
	    _tableview.dataSource = dataSource;
	    _tableview.delegate = dataSource;
	    [_tableview reloadData]; 
	    

## 详细介绍

使用方法`+ [HTTableViewDataSourceDelegate dataSourceWithModel: cellTypeMap: tableViewDelegate: cellConfiguration:]`完成了原先需要在`UIViewController`中书写的大量代码，下面详细解释这个方法

*	model         
数据列表，需要遵守 `HTTableViewDataSourceDataModelProtocol` 协议。   
下面演示一个`NSArray`类对这个协议的实现：

NSArray+DataSource.h
	
		#import <Foundation/Foundation.h>
		#import "HTTableViewDataSourceDataModelProtocol.h"
		@interface NSArray (DataSource) <HTTableViewDataSourceDataModelProtocol>
		@end
NSArray+DataSource.m  

		@implementation NSArray (DataSource)
		- (NSUInteger)ht_sectionCount
		{
	    	return 1;
		}
		- (NSUInteger)ht_rowCountAtSectionIndex:(NSUInteger)section
		{
	    	return self.count;
		}
		- (id)ht_itemAtSection:(NSUInteger)section rowIndex:(NSUInteger)row
		{
	    	return self[row];
		}
		@end
建议为数据列表添加一个遵守该协议的分类，将遵守协议的代码独立出来。
		
*	cellTypeMap   
	描述cell model 到cell identifier 或 cell class的对应关系。规范cell identifier和cell class一致。    
	[UITableViewCell设置数据的规范](https://g.hz.netease.com/mobile/heartouch/blob/master/specification/ios/UITableViewCell%E8%AE%BE%E7%BD%AE%E6%95%B0%E6%8D%AE%E7%9A%84%E8%A7%84%E8%8C%83.md)规定这里用到的UITableViewCell类都应该实现`model`属性。

*	tableViewDelegate  
	`UITableViewDelegate`接口中除了`tableView:heightForRowAtIndexPath:`的方法需要在view controller中配置时，设为view controller，在view controller中完成配置。

*	cellConfiguration   
在 cell 设置 model 结束后额外的设置cell属性的机会，可根据 indexPath 配置 cell。下面会提到高度计算有可能需要在这里设置cell。

[HTTableViewDataSourceDemo]((https://g.hz.netease.com/HeartTouchOpen/HTTableViewDataSourceDelegate.git))演示了更多HTTableViewDataSourceDelegate的使用方式。
		
### 扩展HTTableViewDataSourceDelegate
`HTTableViewDataSourceDelegate`只实现了  `tableView:numberOfRowsInSection:`  
`tableView: cellForRowAtIndexPath:`  
`numberOfSectionsInTableView`  
三个方法，如果需要扩展更多的`UITableViewDataSource`和`UITableViewDelegate`接口，可以继承`HTTableViewDataSourceDelegate`，然后添加实现。

### Cell的高度计算
`HTTableViewDataSourceDelegate`默认实现了cell的高度计算处理，实现细节参照[UITableViewCell高度计算接口规范](https://g.hz.netease.com/mobile/heartouch/blob/master/specification/ios/UITableViewCell%E9%AB%98%E5%BA%A6%E8%AE%A1%E7%AE%97%E6%8E%A5%E5%8F%A3%E8%A7%84%E8%8C%83.md)。

## 使用HTCompositeDataSourceDelegate 
如果一个 table view 需要展示超过一个的数据集合时，计算cell位置会变得复杂起来。  
`HTCompositeDataSourceDelegate`解决了这一问题。 

使用方法如下  
导入头文件
	
	#import "HTTableViewDataSourceDelegate.h"
	#import "HTTableViewCompositeDataSourceDelegate.h"

准备多个数据集合

		//自定义 dataSource
	    HTTableViewDataSourceDelegate * dataSource1;
	    HTTableViewDataSourceDelegate * modelDataSource;
	    //data source array
	    NSMutableArray < UITableViewDataSource, UITableViewDelegate >* dataSourceList = @[].mutableCopy;
	    [dataSourceList addObject:dataSource1];
	    [dataSourceList addObject:modelDataSource];

构造 composite dataSource 对象

	    id <UITableViewDataSource, UITableViewDelegate> dataSource
	    = [HTTableViewCompositeDataSourceDelegate dataSourceWithDataSources:dataSourceList];
		
使用dataSourceDelegate

		//use for table view
	    self.demoDataSource = dataSource;//VC持有 dataSource
		_tableview.dataSource = dataSource;
	    _tableview.delegate = dataSource;
	    [_tableview reloadData];

[HTTableViewDataSourceDemo]((https://g.hz.netease.com/HeartTouchOpen/HTTableViewDataSourceDelegate.git))演示了更多HTTableViewDataSourceDelegate的使用方式。

## UITableView 的规范总结

-	使用`HTTableViewDataSourceDelegate`实例实现`UITableView`的`dataSource` 和 `delegate`。

-	[UITableViewCell设置数据的规范](https://g.hz.netease.com/mobile/heartouch/blob/master/specification/ios/UITableViewCell%E8%AE%BE%E7%BD%AE%E6%95%B0%E6%8D%AE%E7%9A%84%E8%A7%84%E8%8C%83.md)规定自定义`UITableViewCell` 要遵守 `HTTableViewCellModelProtocol`：cell访问数据的接口为 `model`。

-	table view cell 的类名和 cell identifier 相同。

-	[UITableViewCell高度计算接口规范](https://g.hz.netease.com/mobile/heartouch/blob/master/specification/ios/UITableViewCell%E9%AB%98%E5%BA%A6%E8%AE%A1%E7%AE%97%E6%8E%A5%E5%8F%A3%E8%A7%84%E8%8C%83.md)。
