//
//  SPKeyboardSequence.m
//  StandardizationPractice
//
//  Created by Baitianyu on 01/11/2016.
//  Copyright © 2016 Netease. All rights reserved.
//

#import "SPKeyboardSequence.h"

@interface SPKeyboardSequence () <UITextFieldDelegate,UITextViewDelegate>

@property (nonatomic, strong) NSMutableArray *textFieldsStack;

@end

@implementation SPKeyboardSequence

#pragma mark - Life cycle.

- (instancetype)init {
    if (self = [super init]) {
        _textFieldsStack = [[NSMutableArray alloc] init];
    }
    return self;
}


#pragma mark - Public methods.

-(void)removeTextFieldView:(UIView *)textFieldView {
    [_textFieldsStack removeObject:textFieldView];
}

-(void)replaceTextFieldViewAtIndex:(NSInteger)index withTextFieldView:(UIView *)textFieldView returnKeyType:(UIReturnKeyType)returnKeyType {
    [_textFieldsStack replaceObjectAtIndex:index withObject:textFieldView];
    if ([textFieldView isKindOfClass:[UITextField class]]) {
        ((UITextField *)textFieldView).delegate = self;
        ((UITextField *)textFieldView).returnKeyType = returnKeyType;
    } else if ([textFieldView isKindOfClass:[UITextView class]]) {
        ((UITextView *)textFieldView).delegate = self;
        ((UITextView *)textFieldView).returnKeyType = returnKeyType;
    }
}

-(void)addTextFieldView:(UIView *)textFieldView {
    if (textFieldView) {
        [_textFieldsStack addObject:textFieldView];
        if ([textFieldView isKindOfClass:[UITextField class]]) {
            ((UITextField *)textFieldView).delegate = self;
            ((UITextField *)textFieldView).returnKeyType = UIReturnKeyNext;
        } else if ([textFieldView isKindOfClass:[UITextView class]]) {
            ((UITextView *)textFieldView).delegate = self;
            ((UITextView *)textFieldView).returnKeyType = UIReturnKeyNext;
        }
    }
}

-(void)addTextFieldView:(UIView *)textFieldView returnKeyType:(UIReturnKeyType)returnKeyType{
    if (textFieldView) {
        [_textFieldsStack addObject:textFieldView];
        if ([textFieldView isKindOfClass:[UITextField class]]) {
            ((UITextField *)textFieldView).delegate = self;
            ((UITextField *)textFieldView).returnKeyType = returnKeyType;
        } else if ([textFieldView isKindOfClass:[UITextView class]]) {
            ((UITextView *)textFieldView).delegate = self;
            ((UITextView *)textFieldView).returnKeyType = returnKeyType;
        }
    }
}

- (void)goToNextResponderOrResign:(UIView *)textFieldView {
    NSInteger count = _textFieldsStack.count;
    if (textFieldView == _textFieldsStack[count - 1]) {
        [textFieldView resignFirstResponder];
        return;
    }
    
    if (((UITextField *)textFieldView).returnKeyType == UIReturnKeyNext) {
        for (int i = 0; i < _textFieldsStack.count; i++) {
            UIView *view = _textFieldsStack[i];
            if (view == textFieldView) {
                [textFieldView resignFirstResponder];
                [_textFieldsStack[i+1] becomeFirstResponder];
                return;
            }
        }
    }
}


#pragma mark - TextField delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(textFieldShouldBeginEditing:)])
        return [self.delegate textFieldShouldBeginEditing:textField];
    else
        return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(textFieldDidBeginEditing:)])
        [self.delegate textFieldDidBeginEditing:textField];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(textFieldShouldEndEditing:)])
        return [self.delegate textFieldShouldEndEditing:textField];
    else
        return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(textFieldDidEndEditing:)])
        [self.delegate textFieldDidEndEditing:textField];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([self.delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)])
        return [self.delegate textField:textField shouldChangeCharactersInRange:range replacementString:string];
    else
        return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(textFieldShouldClear:)])
        return [self.delegate textFieldShouldClear:textField];
    else
        return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    BOOL shouldReturn = YES;
    
    if ([self.delegate respondsToSelector:@selector(textFieldShouldReturn:)])
        shouldReturn = [self.delegate textFieldShouldReturn:textField];
    
    if (shouldReturn) {
        [self goToNextResponderOrResign:textField];
    }
    
    return shouldReturn;
}


#pragma mark - TextView delegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    if ([self.delegate respondsToSelector:@selector(textViewShouldBeginEditing:)])
        return [self.delegate textViewShouldBeginEditing:textView];
    else
        return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    if ([self.delegate respondsToSelector:@selector(textViewShouldEndEditing:)])
        return [self.delegate textViewShouldEndEditing:textView];
    else
        return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if ([self.delegate respondsToSelector:@selector(textViewDidBeginEditing:)])
        [self.delegate textViewDidBeginEditing:textView];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if ([self.delegate respondsToSelector:@selector(textViewDidEndEditing:)])
        [self.delegate textViewDidEndEditing:textView];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    BOOL shouldReturn = YES;
    
    if ([self.delegate respondsToSelector:@selector(textView:shouldChangeTextInRange:replacementText:)])
        shouldReturn = [self.delegate textView:textView shouldChangeTextInRange:range replacementText:text];
    
    if (shouldReturn && [text isEqualToString:@"\n"]) {
        [self goToNextResponderOrResign:textView];
    }
    
    return shouldReturn;
}

- (void)textViewDidChange:(UITextView *)textView {
    if ([self.delegate respondsToSelector:@selector(textViewDidChange:)])
        [self.delegate textViewDidChange:textView];
}

- (void)textViewDidChangeSelection:(UITextView *)textView {
    if ([self.delegate respondsToSelector:@selector(textViewDidChangeSelection:)])
        [self.delegate textViewDidChangeSelection:textView];
}

@end
