//
//  HTRuntimeHelper.h
//  Pods
//
//  Created by Wangliping on 15/11/9.
//
//

#import <Foundation/Foundation.h>

@interface HTRuntimeHelper : NSObject

/**
 *  获取类自定义的属性列表. Note: 仅包含在自己类中定义的属性名，不包含在父类中定义的属性名.
 *
 *  @param theClass 类名.
 *
 *  @return 返回一个属性列表的数组, 每一项是属性名.
 */
+ (NSArray<NSString *> *)getPropertyList:(Class)theClass;

@end
