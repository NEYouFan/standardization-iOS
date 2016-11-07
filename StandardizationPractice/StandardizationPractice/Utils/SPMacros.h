//
//  SPMacros.h
//  StandardizationPractice
//
//  Created by Baitianyu on 18/10/2016.
//  Copyright © 2016 Netease. All rights reserved.
//

#ifndef SPMacros_h
#define SPMacros_h

/// 使用 PerformSelector 时忽略编译器的泄露警告
#define SPIgnorePerformSelectorLeakWarning(PerformSelectorCode) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
PerformSelectorCode; \
_Pragma("clang diagnostic pop") \
} while(0)


/// 弱引用 self
#define SPWeakSelf(self) autoreleasepool{} __weak typeof(self) weakSelf = self;

/// 判断版本
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

#define IsGreaterIOS8 SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")

#endif /* SPMacros_h */
