//
//  NSURLRequest+RKRequest.m
//  Pods
//
//  Created by Wang Liping on 15/10/10.
//  Copyright (c) 2009-2012 RestKit. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
//  This file is added to RestKit by WangLiping to support different transfer protocol rather than HTTP/HTTPS.

#import <RestKit/Network/NSURLRequest+RKRequest.h>
#import <objc/runtime.h>

static const void *keyRKRequestTypeName = &keyRKRequestTypeName;

@implementation NSURLRequest (RKRequest)


- (NSString *)rk_requestTypeName {
    return objc_getAssociatedObject(self, keyRKRequestTypeName);
}

- (void)setRk_requestTypeName:(NSString *)requestTypeName {
    objc_setAssociatedObject(self, keyRKRequestTypeName, requestTypeName, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end
