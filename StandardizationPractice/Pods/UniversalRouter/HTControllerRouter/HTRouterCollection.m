//
//  HTRouterCollection.m
//  HTUIDemo
//
//  Created by zp on 15/8/28.
//  Copyright (c) 2015年 HT. All rights reserved.
//

#import "HTRouterCollection.h"

#import <dlfcn.h>
#import <objc/message.h>
#import <objc/runtime.h>

#import <mach-o/dyld.h>
#import <mach-o/getsect.h>

NSString *extractClassName(NSString *methodName)
{
    // Parse class and method
    NSArray *parts = [[methodName substringWithRange:NSMakeRange(2, methodName.length - 3)] componentsSeparatedByString:@" "];
    if (parts.count > 0)
        return parts[0];
    
    return nil;
}

NSArray *HTExportedMethodsByModuleID(void)
{
    static NSMutableArray *classes;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!classes){
            classes = [NSMutableArray new];
        }
        
        Dl_info info;
        //这里可能要外部传进来，用来支持动态库导出router信息
        dladdr(&HTExportedMethodsByModuleID, &info);
        
#ifdef __LP64__
        typedef uint64_t HTExportValue;
        typedef struct section_64 HTExportSection;
#define HTGetSectByNameFromHeader getsectbynamefromheader_64
#else
        typedef uint32_t HTExportValue;
        typedef struct section HTExportSection;
#define HTGetSectByNameFromHeader getsectbynamefromheader
#endif
        
        const HTExportValue mach_header = (HTExportValue)info.dli_fbase;
        const HTExportSection *section = HTGetSectByNameFromHeader((void *)mach_header, "__DATA", "HTExport");
        
        if (section == NULL) {
            return;
        }
        
        for (HTExportValue addr = section->offset;
             addr < section->offset + section->size;
             addr += sizeof(const char **)) {
            
            // Get data entry
            const char **entries = (const char **)(mach_header + addr);
            NSString *className = extractClassName(@(entries[0]));
            Class class = className ? NSClassFromString(className) : nil;
            if (class){
                [classes addObject:class];
            }
        }
    });
    
    return classes;
}