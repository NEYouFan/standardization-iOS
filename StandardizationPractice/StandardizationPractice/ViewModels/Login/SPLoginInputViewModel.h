//
//  SPLoginInputViewModel.h
//  StandardizationPractice
//
//  Created by Baitianyu on 01/11/2016.
//  Copyright © 2016 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SPLoginInputViewModel : NSObject

@property (nonatomic, copy) UIImage *iconImage;
@property (nonatomic, copy) NSString *placeholder;
@property (nonatomic, copy) NSString *optionString;

- (instancetype)initWithImageName:(NSString *)imageName placeholder:(NSString *)placeholder optionString:(NSString *)optionString;

@end
