//
//  UITableView+MCRegisterCellClass.h
//  MultiCellTypeTableViewOC
//
//  Created by Baitianyu on 8/26/16.
//  Copyright © 2016 Baitianyu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableView (MCRegisterCellClass)

- (void)registerCellClasses:(NSArray<Class> *)classes;
- (UITableViewCell *)dequeueReusableCellWithClassType:(Class)classType;

@end
