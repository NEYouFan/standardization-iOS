//
//  UIScrollView+MSControllerAssociation.m
//  HTUI
//
//  Created by Bai_tianyu on 9/11/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import <objc/runtime.h>
#import "UIScrollView+MSControllerAssociation.h"
#import "HTRefreshView.h"
#import "HTRefreshViewLogger.h"

const char *tableKey = "NSMapTable";

static NSString *controllerKey = @"MsPullToRefreshController";

@implementation UIScrollView (MSControllerAssociation)

- (void)ht_setMSPullToRefreshController:(MSPullToRefreshController *)controller {
    // Use weak reference
    if (![self ht_getMSPullToRefreshController]) {
        NSMapTable *table = [NSMapTable strongToWeakObjectsMapTable];
        [table setObject:controller forKey:controllerKey];
        objc_setAssociatedObject(self, tableKey, table, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (id)ht_getMSPullToRefreshController {
    NSMapTable *table = objc_getAssociatedObject(self, tableKey);
    if (table) {
        return [table objectForKey:controllerKey];
    }
    return nil;
}

- (void)ht_setOriginalContentInset:(UIEdgeInsets)originalContentInset {
    MSPullToRefreshController *controller = [self ht_getMSPullToRefreshController];
    if (!controller) {
        HTRefreshViewLogError(@"MSPullToRefreshController does not exists.");
        return;
    }
    // Set Original contentInset for every direction's refreshview.
    id<MSPullToRefreshDelegate> delegate;
    for (MSRefreshDirection direction = MSRefreshDirectionTop;
                           direction <= MSRefreshDirectionRight;
                                                    direction++) {
        // Get the specified direction's refreshview.
        delegate = [controller delegateWithDirection:direction];
        if (delegate) {
            [(HTRefreshView *)delegate setOriginalContentInset:originalContentInset];
        }
    }
}

@end
