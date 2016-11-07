//
//  HTObserverInformation.m
//  Pods
//
//  Created by Bai_ty on 12/28/15.
//
//

#import "HTObserverInformation.h"

@implementation HTObserverInformation

- (BOOL)isEqual:(id)object {
    if ([self class] == [object class]) {
        if ((_observer == [(HTObserverInformation *)object observer]) &&
            (_target == [(HTObserverInformation *)object target]) &&
            [_keyPath isEqualToString:[(HTObserverInformation *)object keyPath]] &&
            (_options == [(HTObserverInformation *)object options]) &&
            (_context == [(HTObserverInformation *)object context])) {
            return YES;
        } else {
            return NO;
        }
    } else {
        return [super isEqual:object];
    }
}

- (BOOL)isEqualWithoutOptions:(HTObserverInformation *)info {
    if ((_observer == info.observer) &&
        (_target == info.target) &&
        [_keyPath isEqualToString:info.keyPath] &&
        (_context == info.context)) {
        return YES;
    } else {
        return NO;
    }
}


@end
