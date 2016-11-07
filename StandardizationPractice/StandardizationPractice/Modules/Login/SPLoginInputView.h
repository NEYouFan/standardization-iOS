//
//  SPLoginInputView.h
//  StandardizationPractice
//
//  Created by Baitianyu on 01/11/2016.
//  Copyright © 2016 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SPLoginInputViewModel;

@interface SPLoginInputView : UIView

@property (nonatomic, strong) SPLoginInputViewModel *viewModel;
@property (nonatomic, strong) UITextField *inputTextField;

@property (nonatomic, copy) NSString *text;

@end
