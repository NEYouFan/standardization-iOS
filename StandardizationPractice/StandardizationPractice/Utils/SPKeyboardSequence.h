//
//  SPKeyboardSequence.h
//  StandardizationPractice
//
//  Created by Baitianyu on 01/11/2016.
//  Copyright © 2016 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SPKeyboardSequence : NSObject

@property(nonatomic, weak) id <UITextFieldDelegate, UITextViewDelegate> delegate;

-(void)removeTextFieldView:(UIView *)textField;

-(void)addTextFieldView:(UIView *)textField;

-(void)addTextFieldView:(UIView *)textFieldView returnKeyType:(UIReturnKeyType)returnKeyType;

-(void)replaceTextFieldViewAtIndex:(NSInteger)index withTextFieldView:(UIView *)textFieldView returnKeyType:(UIReturnKeyType)returnKeyType;

@end
