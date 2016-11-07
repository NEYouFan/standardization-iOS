//
//  HTRouterCollection.h
//  HTUIDemo
//
//  Created by zp on 15/8/28.
//  Copyright (c) 2015年 HT. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 *  收集所有实现了configureRouter，这个函数内部必须调用了HT_EXPORT宏
 *
 *  @return 类的数组
 */
NSArray *HTExportedMethodsByModuleID();