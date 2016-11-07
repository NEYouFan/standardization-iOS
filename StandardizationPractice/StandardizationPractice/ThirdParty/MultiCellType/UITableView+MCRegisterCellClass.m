//
//  UITableView+MCRegisterCellClass.m
//  MultiCellTypeTableViewOC
//
//  Created by Baitianyu on 8/26/16.
//  Copyright © 2016 Baitianyu. All rights reserved.
//

#import "UITableView+MCRegisterCellClass.h"

@implementation UITableView (MCRegisterCellClass)

- (void)registerCellClasses:(NSArray<Class> *)classes {
    for (Class classType in classes) {
        [self registerClass:classType forCellReuseIdentifier:NSStringFromClass(classType)];
    }
}

- (UITableViewCell *)dequeueReusableCellWithClassType:(Class)classType {
    return [self dequeueReusableCellWithIdentifier:NSStringFromClass(classType)];
}

@end
