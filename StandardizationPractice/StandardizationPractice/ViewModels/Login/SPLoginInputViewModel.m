//
//  SPLoginInputViewModel.m
//  StandardizationPractice
//
//  Created by Baitianyu on 01/11/2016.
//  Copyright © 2016 Netease. All rights reserved.
//

#import "SPLoginInputViewModel.h"

@implementation SPLoginInputViewModel

- (instancetype)initWithImageName:(NSString *)imageName placeholder:(NSString *)placeholder optionString:(NSString *)optionString {
    if (self = [super init]) {
        _iconImage = [UIImage imageNamed:imageName];
        _placeholder = placeholder;
        _optionString = optionString;
    }
    
    return self;
}

@end
